# LazyVim extras and tooling for Python and C#/.NET

Research for [rleer/vim#3](https://github.com/rleer/vim/issues/3), parent map [#1](https://github.com/rleer/vim/issues/1).
Researched 2026-10-21. Every version below is as of that date; Mason pins move weekly, so recheck before acting.

Machine facts checked (read-only, nothing installed): Apple Silicon (`uname -m` = arm64); `dotnet` is an arm64 binary with runtimes Microsoft.NETCore.App 8.0.30 and 10.0.13; `/usr/bin/python3` is 3.9.6; `python3.14` (uv-managed, 3.14.5) is on PATH via `~/.local/bin`; Homebrew `node`/`npm` present; `fd` is **not** installed; Neovim not yet installed.

## Sources

| Source | Version / ref |
|---|---|
| LazyVim `lua/lazyvim/plugins/extras/lang/python.lua`, `dotnet.lua`, `plugins/lsp/init.lua`, `extras/dap/core.lua`, `util/plugin.lua` | v16.0.1 (2026-09-08), commit `999700997f72` |
| mason-org/mason-registry `packages/*/package.yaml` | release `2026-10-21-dental-tree` |
| mason-org/mason.nvim `lua/mason-core/installer/managers/pypi.lua` | v2.3.1 (2026-06-11) |
| seblyng/roslyn.nvim README | main, pushed 2026-09-10 |
| dotnet/roslyn `Microsoft.CodeAnalysis.LanguageServer.csproj`, `eng/targets/TargetFrameworks.props` | main |
| NuGet `roslyn-language-server` version index | fetched 2026-10-21 |
| OmniSharp/omnisharp-roslyn releases, `OmniSharp.Stdio.Driver.csproj` | v1.39.15, v2.0.0 (2026-09-18) |
| razzmatazz/csharp-language-server README, releases | 0.28.0 (2026-09-13) |
| Samsung/netcoredbg releases, issue #174 | 3.1.3-1062, 3.2.0-1092 (2026-06-25) |
| mason-registry PR #15719 (netcoredbg bump), #17050 (omnisharp v2) | open |
| belav/csharpier releases; stevearc/conform.nvim `formatters/csharpier.lua` | 1.3.0 (2026-06-07) |
| dotnet/sdk `template_feed/.../Solution/.template.config/template.json` | release/10.0.1xx |
| DetachHead/basedpyright docs (`better-defaults.md`, `import-resolution.md`), PyPI metadata | v1.40.2 (2026-10-04) |
| PyPI `debugpy` metadata | 1.8.22 |
| astral-sh/ruff, astral-sh/ty releases and README | ruff 0.17.1 (2026-10-15), ty 0.0.90 (2026-10-20) |
| linux-cultist/venv-selector.nvim README | main, pushed 2026-05-20 |
| GustavEikaas/easy-dotnet.nvim README; easy-dotnet-server `NetCoreDbgLocator.cs` | pushed 2026-10-10 |

LazyVim requires Neovim >= 0.11.2 (README); planned 0.12.6 is fine. roslyn.nvim requires Neovim >= 0.12.0, also fine.

---

## Python

### What `lang.python` does (LazyVim v16.0.1)

- LSP: one type-checker server plus ruff. Selected by globals set in `lua/config/options.lua`:
  - `vim.g.lazyvim_python_lsp`: default `"pyright"`, set `"basedpyright"` to switch.
  - `vim.g.lazyvim_python_ruff`: default `"ruff"` (native server); `"ruff_lsp"` is the deprecated old one.
  - The extra enables exactly `lsp` and `ruff` and sets `enabled = false` on the others in `{pyright, basedpyright, ruff, ruff_lsp}`. Ruff's hover is disabled in favour of the type checker.
  - Servers are auto-installed through `mason-lspconfig` `ensure_installed` (LazyVim `plugins/lsp/init.lua`), so no explicit Mason list is needed for them.
- Formatting/linting: via ruff LSP (no conform entry in the extra).
- Debugging (only if the `dap.core` extra is enabled): `nvim-dap-python` set up with `require("dap-python").setup("debugpy-adapter")`, i.e. it expects the `debugpy-adapter` executable that Mason's `debugpy` package provides. mason-nvim-dap's own python handler is disabled. `debugpy` is not in any `ensure_installed` list in the extra, so plan to add it (`mason.nvim` `opts.ensure_installed`) or run `:MasonInstall debugpy`.
- Tests (if `test.core` extra): `neotest-python`.
- Venv: `linux-cultist/venv-selector.nvim`, `<leader>cv` / `:VenvSelect`. Requires `fd` (not installed here). Supports uv PEP-723 inline-script metadata (2026-02 changelog) and sets `VIRTUAL_ENV` for child terminals.

### Type checker options

| Option | Mason package (source) | Pros | Cons |
|---|---|---|---|
| **pyright** (LazyVim default) | `pyright` 1.1.414 (npm) | Default, zero config | Needs node/npm (present via Homebrew). Does **not** auto-detect `.venv`; without venv-selector or a `pyrightconfig.json` `venv`/`venvPath`, it resolves imports against the default `python` on PATH, which here is 3.9.6, so imports from a uv venv show unresolved. |
| **basedpyright** | `basedpyright` 1.40.2 (PyPI, built on pyright 1.1.414) | Auto-uses `./.venv` when no `pythonPath`/`venv` is set (documented in `better-defaults.md`), which is exactly where `uv` puts it. Ships extra rules, baseline support, inlay hints and pylance-like features. One-line switch in LazyVim. | Default `typeCheckingMode = "recommended"` enables all rules, so expect many warnings until you set `"standard"` in `pyproject.toml` or LSP settings. Mason install needs Python >= 3.10 (see below). |
| ty (Astral) | `ty` 0.0.90 (PyPI) | Very fast, same vendor as ruff/uv | Beta, `0.0.x`, no stable API (ty README). Not a documented LazyVim option, although the extra's enable/disable loop would technically accept `vim.g.lazyvim_python_lsp = "ty"`. Not recommended yet. |

Also in the registry: `pyrefly` (Meta). Not evaluated in depth; no LazyVim support.

### Ruff

`ruff` 0.17.1 in Mason is a standalone native binary (`ruff-aarch64-apple-darwin`), no Python needed. It handles lint and format through LSP. No real alternative worth weighing; black/isort/flake8 are subsumed.

### Venv handling with uv

- With basedpyright, a standard `uv sync` project (`.venv` in project root, Neovim started in that root) works without venv-selector.
- venv-selector is still useful for: projects whose venv is elsewhere, monorepos, PEP-723 scripts, and making `:terminal` and debugpy see the venv. It needs `fd`.
- debugpy: `nvim-dap-python` runs the debuggee with the interpreter it resolves (active `VIRTUAL_ENV`/venv-selector selection, or `.venv`). The adapter itself comes from Mason's isolated venv, so the project venv does not need `debugpy` installed.

### The Python 3.9 trap (Mason prerequisite)

Mason installs PyPI packages into a private venv built with a host Python. `basedpyright` 1.40.2 and `debugpy` 1.8.22 both declare `requires_python >= 3.10`. Mason's pypi installer (`pypi.lua`) first tries `python3`; if that version fails the package's `requires_python`, it searches `python3.6` ... `python3.14` on PATH and uses the first that satisfies it, otherwise it fails with "Failed to find a python3 installation in PATH that meets the required versions".

On this machine `python3` is 3.9.6, so Mason will fall back to `python3.14` in `~/.local/bin` (uv shim). That works **only if `~/.local/bin` is on Neovim's PATH**. Terminal-launched Neovim inherits the shell PATH; a GUI-launched Neovim might not. If it isn't, the fix is a Homebrew Python or ensuring the PATH entry, not installing anything into the system Python. (`ty` is also PyPI-packaged; `ruff` and `pyright` are not affected.)

### Python recommendation (not a decision)

`lang.python` with `vim.g.lazyvim_python_lsp = "basedpyright"`, ruff native server, `dap.core` + Mason `debugpy`, keep venv-selector (install `fd`, which LazyVim core wants anyway). Set basedpyright `typeCheckingMode` to `"standard"` if the default noise is unwelcome. Rationale: the `.venv` auto-detection removes the main friction of uv projects; everything else is LazyVim defaults.

---

## C#/.NET

### What LazyVim ships

LazyVim v16.0.1 has exactly one .NET extra: **`lang.dotnet`**. `lang.omnisharp` was renamed to `lang.dotnet` on 2025-10-20 (`util/plugin.lua` `renamed_extras`). There is **no Roslyn/roslyn.nvim extra** in LazyVim (the only "roslyn" string in the repo is OmniSharp's `enable_roslyn_analyzers`).

`lang.dotnet` contents:
- LSP: `omnisharp` (with `omnisharp-extended-lsp.nvim` for go-to-definition into decompiled metadata; `enable_roslyn_analyzers`, `organize_imports_on_format`, `enable_import_completion` set) and `fsautocomplete` for F#.
- Treesitter: `c_sharp`, `fsharp`.
- Formatting: conform `cs = { "csharpier" }`, `fsharp = { "fantomas" }`.
- Mason `ensure_installed`: `csharpier`, `netcoredbg`, `fantomas` (plus `omnisharp` and `fsautocomplete` via mason-lspconfig).
- DAP (if `dap.core`): `netcoredbg` adapter using `vim.fn.exepath("netcoredbg")`; one "Launch file" config that prompts for a DLL path.
- Tests (if `test.core`): `neotest-vstest`.
- "Recommended" root markers: `*.sln`, `*.csproj`, `*.fsproj`, ... (no `*.slnx`).

### Blocking caveats found

1. **.NET 10 creates `.slnx` by default; Mason's OmniSharp cannot read it.** The SDK 10 solution template has `Format` default `"slnx"` (dotnet/sdk `release/10.0.1xx`). OmniSharp added `.slnx` support only in v2.0.0 (2026-09-18, which also removed Mono/.NET Framework code). Mason still pins `omnisharp` v1.39.15; the bump to v2 (mason-registry PR #17050) is open, likely because v2 renamed its assets (no `-net6.0` suffix). With Mason's OmniSharp, a new SDK-10 solution would only work per project, or with `dotnet new sln --format sln`.
2. **Mason's roslyn-language-server is below roslyn.nvim's stated minimum.** roslyn.nvim requires Roslyn LS >= `5.12.0-1.26453.19`. Mason main registry pins `5.12.0-1.26426.8` (bumped 2026-08-29). NuGet already has `5.12.0-1.26475.2`, `5.13.0-1.26507.4`, `5.13.0-1.26514.10`, so a Renovate bump may land soon, but today the roslyn.nvim README itself recommends the `Crashdummyy/mason-registry` extra registry (`roslyn`, same version as VS Code; `roslyn-nightly`) or a `dotnet tool install -g roslyn-language-server --prerelease` from the Azure DevOps feed.
3. **Mason's netcoredbg is an x86_64 binary on Apple Silicon.** Mason pins netcoredbg 3.1.3-1062 and for `darwin_arm64` downloads `netcoredbg-osx-amd64.tar.gz` (that release has no osx-arm64 asset). Upstream added official `netcoredbg-osx-arm64.zip` only in 3.2.0-1092 (2026-06-25, issue #174), and 3.2.0 dropped the osx x64 asset. Mason's bump PR #15719 has been open since 2026-06-26 with darwin_arm64 and darwin_x64 package tests failing. An x86_64 debugger running under Rosetta is not expected to debug the arm64 `dotnet` processes this machine runs (the runtime here is arm64-only); I did not test this, so treat it as a strong expectation, not a verified failure. Workarounds: manual download of the 3.2.0 osx-arm64 build and point the adapter at it, or use easy-dotnet's bundled debugger (its locator selects an `osx-arm64` build).

### Language server options

| Option | How to get it | Pros | Cons |
|---|---|---|---|
| **OmniSharp** (stock `lang.dotnet`) | Mason `omnisharp` 1.39.15 (net6.0 build, `RollForward=LatestMajor` so it runs on the installed 8/10 runtimes) | Zero config in LazyVim; decompiled go-to-definition via omnisharp-extended | Mason's version can't open `.slnx` (default for SDK 10); older analysis engine than VS Code's; slower on big solutions. v2.0.0 upstream fixes slnx but isn't in Mason yet. |
| **Roslyn LS via roslyn.nvim** | Plugin `seblyng/roslyn.nvim` + server from Crashdummyy registry or `dotnet tool` (Mason main is currently too old, see caveat 2) | Same server as VS Code C# Dev Kit; supports `.sln`/`.slnx`, multiple solutions (`:Roslyn target`), source-generated files, Razor/CSHTML via cohosting, daemon mode sharing one server across Neovim instances | Not a LazyVim extra: you write a small spec and disable `omnisharp` in `lang.dotnet` (or skip the extra and copy the bits you want). Server needs the **.NET 10 runtime** (Roslyn `NetVSCode` = net10.0; you have 10.0.13). Project loading uses a BuildHost targeting net8.0, so SDK 8 projects and `global.json` pins to 8.x are fine. Possible duplicate client: if the server is installed from Mason main, LazyVim's mason-lspconfig `automatic_enable` may also start nvim-lspconfig's `roslyn_ls` alongside roslyn.nvim's `roslyn`; set `servers.roslyn_ls = { enabled = false }` (verify at setup). |
| **easy-dotnet.nvim** (wraps Roslyn LS) | Plugin + `dotnet tool install -g EasyDotnet` | Batteries included: Roslyn LS management, run/test/debug, NuGet and project-file tooling, bundled debugger (netcoredbg, dncdbg or sharpdbg) with an osx-arm64 build. Sidesteps caveats 2 and 3. | Large, opinionated plugin with its own server process that "may require more frequent updates" (README); overlaps LazyVim's dap/neotest wiring; not a LazyVim extra. |
| csharp-ls | Mason `csharp-language-server` 0.24.0 (upstream 0.28.0) | Lightweight Roslyn-based server; nvim-lspconfig supports `.slnx` | Needs .NET 10 SDK (have it). Fewer features than Roslyn LS; Mason lags upstream by four minors. No LazyVim wiring. |

### Formatting: CSharpier

Mason `csharpier` 1.2.6 (upstream 1.3.0, 2026-06-07), installed as a NuGet dotnet tool, so it needs `dotnet` on PATH. conform's formatter prefers a project-local tool (`dotnet csharpier --version` succeeds, i.e. listed in `.config/dotnet-tools.json`) and falls back to the global/Mason `csharpier`; it uses the 1.x CLI (`csharpier format --stdin-path`). Alternative: let the LSP format (OmniSharp/Roslyn honour `.editorconfig`). CSharpier is opinionated; whether to use it is a team/style choice more than a tooling one.

### Debugging: netcoredbg

The only open-source .NET debugger usable from nvim-dap (Microsoft's vsdbg is licensed for Microsoft tools only). See caveat 3 for the Apple Silicon problem with Mason. LazyVim's adapter config uses `vim.fn.exepath("netcoredbg")`, so a manually installed arm64 build on PATH, or an overridden `dap.adapters.netcoredbg`, takes over cleanly. LazyVim's launch config asks for a DLL path each time; easy-dotnet builds and picks the project for you.

### SDK 8 and SDK 10 together

- Runtimes needed by tools: Roslyn LS and csharp-ls need .NET 10; OmniSharp (Mason) runs on any >= 6 via roll-forward. Both 8 and 10 are installed.
- Which SDK builds a project is decided by `global.json` (or newest SDK if none). SDK 10 can build `net8.0` targets. Roslyn's net8.0 BuildHost means a repo pinned to SDK 8 still loads.
- Solutions vs single projects: Roslyn LS/roslyn.nvim searches upward for `.sln`/`.slnx` (and downward with `broad_search`), falling back to the `.csproj`. LazyVim's OmniSharp config works from `.sln`/`.csproj` roots but, as pinned in Mason, not `.slnx`.

### C# recommendation (not a decision)

Use `lang.dotnet` for treesitter, CSharpier and the neotest adapter, but replace OmniSharp with **roslyn.nvim** (disable `omnisharp` in `servers`), sourcing the server from the Crashdummyy Mason registry until Mason main reaches >= `5.12.0-1.26453.19`. For debugging, install the netcoredbg 3.2.0 osx-arm64 build manually and point the adapter at it until mason-registry #15719 lands. Rationale: Roslyn LS is what VS Code uses, handles `.slnx` (the SDK 10 default) and multi-solution repos, and runs on the installed .NET 10 runtime.

The strongest alternative is **easy-dotnet.nvim**: more moving parts and less "LazyVim-native", but it removes both Mason workarounds and adds run/test/NuGet tooling. Worth choosing if you want an IDE-like .NET workflow rather than LSP + DAP. Stock OmniSharp is only reasonable if all your solutions are `.sln` and you want zero custom config; that may change once Mason ships OmniSharp v2.

---

## Mason vs system-wide

**Mason installs (into `~/.local/share/nvim/mason`):** pyright (npm) or basedpyright (PyPI), ruff (native binary), debugpy (PyPI), ty (optional); omnisharp, csharpier, netcoredbg (x64 on arm64, see caveat), fantomas, fsautocomplete, csharp-language-server, roslyn-language-server (too old today) or `roslyn` from the Crashdummyy registry.

**Must exist system-wide (Mason does not provide them):**

| Requirement | Why | Status here |
|---|---|---|
| Python >= 3.10 reachable as `python3.1x` on Neovim's PATH | Mason builds venvs for basedpyright, debugpy, ty | `python3.14` via uv in `~/.local/bin`; `/usr/bin/python3` 3.9.6 too old |
| node + npm | Mason's `pyright` (only if staying on pyright) | Homebrew, present |
| `dotnet` SDK/runtime on PATH | runs OmniSharp, Roslyn LS, csharp-ls, CSharpier, fantomas, fsautocomplete; Mason's NuGet installs use `dotnet tool` | SDK 8.0.424 + 10.0.402, present |
| .NET 10 runtime | Roslyn LS, csharp-ls | 10.0.13, present |
| `fd` | venv-selector default search (and LazyVim pickers) | **missing** |
| `uv` | project venvs, PEP-723 scripts | present |
| arm64 netcoredbg (manual) or easy-dotnet tool | working .NET debugging on Apple Silicon | not installed |
| `dotnet tool install -g EasyDotnet` | only if choosing easy-dotnet | not installed |

## Open questions for the grilling ticket

- basedpyright strictness level (`recommended` default vs `standard`).
- roslyn.nvim + LazyVim pieces vs easy-dotnet vs stock OmniSharp.
- Accept an extra Mason registry (Crashdummyy) or install Roslyn LS as a global dotnet tool?
- Is CSharpier wanted, or LSP/`.editorconfig` formatting only?
- F#: keep `fsautocomplete`/`fantomas` from `lang.dotnet` or exclude them?
