# LazyVim prerequisites on Neovim 0.12 (macOS)

Research for rleer/vim#2 (parent map rleer/vim#1). Gathered 2026-10-21.

## Answer in brief

```sh
brew install neovim fd tree-sitter-cli
```

That is the only required install on this machine. Everything else LazyVim checks for (git, rg, fzf, lazygit, curl, tar, a C compiler) is already present. Then copy the LazyVim starter (minus `.git`) into this repo, symlink the repo to `~/.config/nvim`, start `nvim`, and run `:LazyHealth`. There are no known incompatibilities between current LazyVim and Neovim 0.12.

## Versions this applies to

| Component | Version / commit | Date | Source |
|---|---|---|---|
| Neovim (Homebrew `neovim`) | 0.12.6, formula depends on `luajit` | released 2026-10-09 | [neovim releases](https://github.com/neovim/neovim/releases/tag/v0.12.6), [neovim.rb](https://github.com/Homebrew/homebrew-core/blob/main/Formula/n/neovim.rb) |
| LazyVim | v16.0.1 (main `9997009`) | 2026-09-08 | [releases](https://github.com/LazyVim/LazyVim/releases) |
| LazyVim starter | `803bc18` | 2024-12-11 (old, still current) | [LazyVim/starter](https://github.com/LazyVim/starter) |
| nvim-treesitter | `main` branch | last push 2026-10-19 | [README](https://github.com/nvim-treesitter/nvim-treesitter/blob/main/README.md) |
| tree-sitter-cli (brew) | 0.27.1 | | `brew info tree-sitter-cli` |
| fd (brew) | 10.5.0 | | `brew info fd` |
| git (system) | 2.54.0 (Apple Git-157) | | local |
| fzf (brew, installed) | 0.74.5 | | local |

## Requirements

### What LazyVim itself requires

From the [LazyVim docs home page](https://www.lazyvim.org/) and [README](https://github.com/LazyVim/LazyVim#%EF%B8%8F-requirements):

| Requirement | Status on this machine |
|---|---|
| Neovim >= 0.11.2, built with LuaJIT | Missing. brew `neovim` 0.12.6 links `luajit`, so that requirement is met |
| Git >= 2.19.0 (partial clones) | OK, 2.54.0 |
| Nerd Font v3.0 or later (optional, for icons) | OK. `~/Library/Fonts/JetBrainsMonoNerdFont-*.ttf` uses the v3 file naming (v2 used `... Nerd Font Complete.ttf`) |
| lazygit (optional) | OK |
| tree-sitter-cli and a C compiler, for nvim-treesitter | `cc` OK, **tree-sitter-cli missing** |
| curl (blink.cmp completion engine) | OK, `/usr/bin/curl` |
| fzf >= 0.25.1, ripgrep, fd (for fzf-lua, optional) | fzf and rg OK, **fd missing** |
| A terminal with true color and undercurl (kitty, WezTerm, Alacritty, iTerm2, Ghostty) | OK, `TERM_PROGRAM=ghostty` |

`:LazyHealth` runs the `lazyvim` healthcheck ([`lua/lazyvim/health.lua`](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/health.lua)), which checks exactly these:

- Neovim >= 0.11.2. An older version is an **error**.
- Executables `git`, `rg`, `fd` (or `fdfind`), `lazygit`, `fzf` and `curl`. Each missing one is a **warning**.
- The "LazyVim nvim-treesitter" section ([`util/treesitter.lua` `M.check`](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/treesitter.lua)) checks `tree-sitter` (CLI), a C compiler (`$CC` or `cc`), `tar` and `curl`. Each missing one is an **error**.

fd is listed as optional for fzf-lua, but LazyVim's default picker is snacks.picker, which also uses fd for file finding. The healthcheck warns without it, so install it.

### Is tree-sitter-cli required? Yes.

1. LazyVim pins nvim-treesitter to the `main` branch. It only pins a fixed commit when Neovim is older than 0.12 (`commit = vim.fn.has("nvim-0.12") == 0 and "7caec27..." or nil` in [`plugins/treesitter.lua`](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/treesitter.lua)). The v15.15.0 changelog says nvim-treesitter no longer supports nvim-0.11. So on 0.12 you get the latest `main`.
2. The nvim-treesitter `main` README lists the requirements: Neovim 0.12.0 or later, `tar` and `curl`, **`tree-sitter-cli` 0.26.1 or later, installed via your package manager, not npm**, and a C compiler. The `main` branch builds parsers with the CLI. The old `master` branch is frozen for Nvim 0.11.
3. When it builds, LazyVim runs `ensure_treesitter_cli`. If `tree-sitter` is not on PATH, it tries to install the `tree-sitter-cli` package through mason.nvim. That is only a fallback. The brew install is the recommended path, and with it the binary is also visible outside Neovim.

**Formula-name trap:** the Homebrew `tree-sitter` formula is only the *library* (a Neovim dependency), and its caveats point to `brew install tree-sitter-cli`. The `tree-sitter` binary comes from **`tree-sitter-cli`** ([formula](https://github.com/Homebrew/homebrew-core/blob/main/Formula/t/tree-sitter-cli.rb)).

### Optional extras (not needed for a clean LazyVim)

- `wget`: mason's healthcheck lists it as optional because it falls back to curl. It shows up as a warning only.
- `imagemagick` (`magick`), `ghostscript`, `tectonic`: used only by snacks.nvim image rendering. Their checks *may* appear in `:checkhealth snacks` (I did not confirm whether LazyVim enables `snacks.image` by default). Ignore them unless you want inline images.
- Python provider: Neovim 0.12 simplifies this to `uv tool install pynvim` ([news-0.12](https://github.com/neovim/neovim/blob/v0.12.6/runtime/doc/news.txt), PLUGINS). LazyVim does not need it. Install it only if a remote Python plugin needs it.
- Language tooling for Python and C# (LSPs, formatters) comes from the language extras through mason. That is covered by the language-tooling ticket, not here. mason needs `unzip`, `gzip`, `tar`, `curl` and `bash`, all present in macOS.

## Bootstrap

### Official steps (lazyvim.org/installation)

From the [installation page](https://www.lazyvim.org/installation):

1. Back up `~/.config/nvim`, and optionally `~/.local/share/nvim`, `~/.local/state/nvim` and `~/.cache/nvim`.
2. `git clone https://github.com/LazyVim/starter ~/.config/nvim`
3. `rm -rf ~/.config/nvim/.git` "so you can add it to your own repo later".
4. `nvim`
5. Then run `:LazyHealth`. The page recommends it after install because it loads all plugins and checks that everything works.

On this machine `~/.config/nvim` and `~/.local/share/nvim` do not exist yet, so step 1 does nothing.

### Adapted for this repo (symlinked as `~/.config/nvim`)

```sh
git clone --depth 1 https://github.com/LazyVim/starter /tmp/lazyvim-starter
rsync -a --exclude .git /tmp/lazyvim-starter/ <repo>/       # or cp, skipping .git
ln -s <repo> ~/.config/nvim
nvim                                                     # lazy.nvim bootstraps itself, installs plugins and parsers
# then inside nvim: :LazyHealth
```

The starter contains `.gitignore`, `.neoconf.json`, `LICENSE`, `README.md`, `init.lua`, `lua/config/{autocmds,keymaps,lazy,options}.lua`, `lua/plugins/example.lua` and `stylua.toml`.

- **Keep:** `init.lua`, `lua/` (`lua/plugins/example.lua` is fully disabled by an early `return {}`, so you can keep it as a reference or delete it), `.gitignore`, `.neoconf.json` (lazydev/neoconf project settings), `stylua.toml` (Lua formatting).
- **Drop or replace:** the starter `.git` (required, per the official step 3), and the starter `README.md`, which you can replace with your own. `LICENSE` (Apache-2.0, the starter's) is optional for a personal config.
- **Lockfile:** lazy.nvim writes `lazy-lock.json` to `stdpath("config")` (the [lazy.nvim config.lua](https://github.com/folke/lazy.nvim/blob/main/lua/lazy/core/config.lua) default), which resolves through the symlink into the repo. The starter `.gitignore` does not exclude it, so it can be committed as the map wants.
- **How the starter bootstraps:** [`lua/config/lazy.lua`](https://github.com/LazyVim/starter/blob/main/lua/config/lazy.lua) clones lazy.nvim (`--branch=stable`) into `stdpath("data")/lazy/lazy.nvim` if it is missing. It then calls `require("lazy").setup` with `{ "LazyVim/LazyVim", import = "lazyvim.plugins" }` plus `{ import = "plugins" }`, `defaults.version = false`, and `checker.enabled = true, notify = false`. There is no `rocks` setting, so the lazy.nvim default applies.

### Leftover Vim files in this repo (decision for the map, not made here)

The repo still holds `vimrc` and the `pack/bundle/start/{lightline,vim-surround}` git submodules.

- **Vim is unaffected** if they are removed: `~/.vim -> ~/dotfiles/vim` and `~/.vimrc -> ~/dotfiles/.vimrc`, so nothing reads this repo.
- **Neovim would not load them** even if they stay. `stdpath("config")/pack` is normally on `packpath`, but lazy.nvim's default `performance.reset_packpath = true` sets `packpath` to `$VIMRUNTIME` only. They are just clutter.
- Removing them means `git rm` on both submodules plus `vimrc`. Whether to do that is for the map or the bootstrap ticket to decide.

## Neovim 0.12 compatibility and caveats

- **No known incompatibilities.** No open LazyVim issues target 0.12. LazyVim v16.0.0 (2026-05-27) already ships fixes for *nvim-0.13* (the `vim.hl.on_yank` to `vim.hl.hl_op` switch and a version-check fix), so 0.12 is the mainstream target.
- **0.12 is the minimum for nvim-treesitter `main`.** nvim-treesitter supports only the latest stable and nightly Neovim. Staying on the brew stable formula fits that, but expect to update Neovim and the plugin together.
- **Built-in `vim.pack` (new in 0.12)** is a separate plugin manager. Don't mix it with lazy.nvim. LazyVim uses lazy.nvim only.
- **0.12 breaking changes** ([news-0.12](https://github.com/neovim/neovim/blob/v0.12.6/runtime/doc/news.txt), BREAKING CHANGES) affect plugin authors, not a stock LazyVim config. Examples are removed `vim.diagnostic.disable()`, `vim.diff` renamed to `vim.text.diff`, `:sign-define` no longer configuring diagnostic signs, and `'shelltemp'` defaulting to false. Watch for them only in custom snippets copied from older blog posts.
- **Updating:** after a plugin update, nvim-treesitter needs `:TSUpdate`, which LazyVim's `build` hook runs. The nvim-treesitter README warns that parsers must match the plugin version.
- 0.12 `:checkhealth` now shows a summary in the header of each healthcheck and checks for a `vim.ui.open()` handler (on macOS, `open` covers this).

## What a clean `:LazyHealth` / `:checkhealth` should look like

After `brew install neovim fd tree-sitter-cli` and a first start that has finished installing plugins.

**Certain (from LazyVim's health code):**

- `LazyVim`: OK for "Using Neovim >= 0.11.2", and OK for each of `git`, `rg`, `fd`, `lazygit`, `fzf` and `curl`.
- `LazyVim nvim-treesitter`: OK for `C compiler`, `curl`, `tar` and `tree-sitter (CLI)`.

**Expected, harmless warnings:**

- `mason`: warnings for optional language runtimes that are not installed (Go, cargo, luarocks, Ruby/gem, PHP/Composer, Java/javac, Julia) and for `wget`. Only the runtimes needed by mason packages you actually use matter. For Python and C#, those are python3/pip (present) and dotnet (present).
- `vim.provider`: warnings for missing Python, Ruby, Perl and Node providers. Opt-in, not needed by LazyVim.

**May appear (not verified):**

- `lazy`: luarocks/hererocks notes, since the starter leaves `rocks` at the default. These are harmless unless a plugin needs rocks.
- `snacks`: image tool warnings (`magick`, `gs`, `tectonic`/`pdflatex`), if snacks.image health is checked.

Any **error** under `LazyVim` or `LazyVim nvim-treesitter` means a real missing prerequisite.

## Sources

- LazyVim docs, requirements: https://www.lazyvim.org/
- LazyVim docs, installation: https://www.lazyvim.org/installation
- LazyVim repo (v16.0.1, main `9997009`): README, `lua/lazyvim/health.lua`, `lua/lazyvim/plugins/treesitter.lua`, `lua/lazyvim/util/treesitter.lua`, release notes for v15.15.0, v16.0.0 and v16.0.1. https://github.com/LazyVim/LazyVim
- LazyVim starter (`803bc18`): https://github.com/LazyVim/starter
- lazy.nvim default config (`lockfile`, `performance.reset_packpath`): https://github.com/folke/lazy.nvim/blob/main/lua/lazy/core/config.lua
- nvim-treesitter `main` README: https://github.com/nvim-treesitter/nvim-treesitter/blob/main/README.md
- Neovim 0.12.6 `news.txt` (changes since 0.11): https://github.com/neovim/neovim/blob/v0.12.6/runtime/doc/news.txt
- mason.nvim healthcheck: https://github.com/mason-org/mason.nvim/blob/main/lua/mason/health.lua
- Homebrew formulas `neovim`, `tree-sitter`, `tree-sitter-cli`: https://github.com/Homebrew/homebrew-core
