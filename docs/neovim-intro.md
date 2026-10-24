# Neovim and LazyVim for a Vim user

This guide covers what Neovim and this LazyVim config add or change compared to Vim. Motions, text objects, registers and macros work as before and are not explained here.

Every keymap below was checked against this config (LazyVim with the `dap.core`, `lang.python`, `lang.dotnet` and `test.core` extras). For anything not listed, press `<leader>` (Space) and wait for which-key, run `<leader>sk` to search all keymaps, or `<leader>?` for the current buffer's keymaps. The full upstream list is on the [LazyVim keymaps page](https://www.lazyvim.org/keymaps).

## Vim keys that behave differently

These are the surprises. Read this section first.

| Key | In Vim | Here |
| --- | --- | --- |
| `s` / `S` | substitute char / line | Flash jump / Flash Treesitter select. Use `cl` / `cc` instead. |
| `H` / `L` | top / bottom of screen | previous / next buffer |
| `<C-h/j/k/l>` | various | move to the window left / below / above / right |
| `]c` / `[c` | next / previous diff hunk | next / previous class in code buffers. In diff mode they still jump hunks. |
| `]]` / `[[` | next / previous section | next / previous LSP reference of the word under the cursor (when an LSP is attached) |
| `]a` / `[a` | `:next` / `:previous` | next / previous parameter in code buffers |
| `Y` | yank line | yank to end of line, like `y$` (Neovim default, `:help Y-default`) |
| `<C-s>` | (terminal flow control) | save file, in normal, visual and insert mode |
| `<M-j>` / `<M-k>` | | move the line or selection down / up |
| `<Esc>` | | also clears search highlighting |

Options that change how familiar things feel: the unnamed register is synced with the system clipboard (`clipboard=unnamedplus`, off over SSH), so every `y`, `d` and `x` lands on the macOS clipboard; `relativenumber`, `ignorecase` + `smartcase`, `nowrap` and `undofile` are on; `timeoutlen` is 300 ms so which-key pops up quickly; `confirm` asks before quitting a modified buffer.

## Neovim defaults worth knowing

Neovim ships some mappings Vim doesn't have. Each has a `:help` tag.

- `gc{motion}`, `gcc`, visual `gc`: toggle comments (`:help commenting`). LazyVim adds `gco` / `gcO` to add a comment below / above.
- Visual `*` / `#`: search for the selection (`:help v_star-default`).
- Visual `@` / `Q`: run a macro on every selected line (`:help v_@-default`).
- `&`: repeat the last `:s` with its flags (`:help &-default`).
- `[d` / `]d`, `[D` / `]D`: previous / next / first / last diagnostic. `<C-w>d` shows the diagnostic under the cursor in a float.
- `[<Space>` / `]<Space>`: add an empty line above / below.
- `gx`: open the path or URL under the cursor with macOS `open`.
- `grn`, `grr`, `gra`, `gri`, `grt`, `gO`: Neovim's built-in LSP keys (rename, references, code action, implementation, type definition, document symbols). LazyVim's keys below cover the same ground and are the ones this guide uses.

`:checkhealth` (or `:LazyHealth` for the plugin side) is the first stop when something seems broken. `:terminal` opens a terminal in a normal window; for day-to-day use the floating terminal below is quicker.

## How the config is laid out

Vim's single `vimrc` becomes a Lua tree under `~/.config/nvim` (a symlink to this repo):

- `init.lua` only loads `lua/config/lazy.lua`, which bootstraps lazy.nvim and LazyVim.
- `lua/config/options.lua`, `keymaps.lua`, `autocmds.lua`: your additions on top of LazyVim's defaults.
- `lua/plugins/*.lua`: plugin specs that add plugins or override LazyVim's (`python.lua` and `dotnet.lua` here).
- `lazyvim.json`: which LazyVim extras are enabled. `:LazyExtras` toggles them.
- `lazy-lock.json`: the exact plugin commits. It is committed; see [Plugins, tools and updates](#plugins-tools-and-updates).

`<leader>fc` finds a file in this config.

## Everyday tasks

### Open a file

| Vim | Here |
| --- | --- |
| `:e path`, `:find` | `<leader><leader>` (or `<leader>ff`): fuzzy find files in the project root |
| | `<leader>fr`: recent files. `<leader>fg`: git-tracked files only |
| `:ls`, `:b` | `<leader>,` (or `<leader>fb`): pick an open buffer. `H` / `L` cycle buffers, `<leader>bd` closes one |
| netrw, `:Ex` | `<leader>e`: file explorer for the project root (`<leader>E` for the cwd) |

"Root" means the project root detected from the LSP or `.git`; the uppercase variants (`<leader>fF`, `<leader>E`, `<leader>sG`, …) use the current working directory instead.

Inside a picker, type to filter, `<C-j>` / `<C-k>` to move, `<CR>` to open. `<leader>sR` reopens the last picker where you left it.

### Grep the project

| Vim | Here |
| --- | --- |
| `:grep`, `:vimgrep` | `<leader>/` (or `<leader>sg`): live grep in the project root, using ripgrep |
| `*` then `:grep` | `<leader>sw`: grep the word under the cursor (or the visual selection) |
| `/` in one buffer | `<leader>sb`: fuzzy search lines of the current buffer |
| `:%s` across files | `<leader>sr`: search and replace across the project (grug-far) |

Other `<leader>s` pickers replace things you'd do with ex commands: `<leader>sh` help, `<leader>sk` keymaps, `<leader>s"` registers, `<leader>sm` marks, `<leader>sj` jumplist, `<leader>sc` command history, `<leader>su` undo tree.

### Jump around code

`s` followed by one or two characters labels every match on screen; press the label to jump there. It works after an operator too: `ds` plus a label deletes up to that spot. `S` labels Treesitter nodes around the cursor so you can select a whole expression or block in one go.

`<C-Space>` starts incremental selection: each further `<C-Space>` grows the selection to the enclosing node, `<BS>` shrinks it.

Treesitter adds text objects and motions on top of Vim's:

- `af` / `if` function, `ac` / `ic` class, `ao` / `io` block (if, loop), `au` function call, `ag` the whole buffer. `vif`, `dac`, `yau` behave as you'd expect.
- `]f` / `[f` next / previous function start, `]F` / `[F` end. The same pattern with `c` for classes and `a` for parameters.

### Jump to definition, references, rename

These work in any buffer with an LSP attached (Python and C# here).

| Task | Key |
| --- | --- |
| Hover documentation | `K` |
| Signature help | `gK` (or `<C-k>` in insert mode) |
| Go to definition / declaration | `gd` / `gD` |
| References | `gr` |
| Implementation / type definition | `gI` / `gy` |
| Incoming / outgoing calls | `gai` / `gao` |
| Next / previous reference of the symbol | `]]` / `[[` (also `<M-n>` / `<M-p>`) |
| Rename symbol | `<leader>cr` |
| Rename file (updates imports) | `<leader>cR` |
| Code action / source action | `<leader>ca` / `<leader>cA` |
| Document symbols / workspace symbols | `<leader>ss` / `<leader>sS` |
| Format buffer or selection | `<leader>cf` |
| Which servers are attached | `<leader>cl` |

`<C-o>` and `<C-i>` take you back and forth after a jump, as in Vim.

Files are formatted on save. `<leader>uf` toggles that globally, `<leader>uF` only for the current buffer (useful in a repo that doesn't use the project's formatter).

### See errors

Diagnostics appear inline and in the sign column.

- `]d` / `[d` next / previous diagnostic, `]e` / `[e` errors only, `]w` / `[w` warnings only.
- `<leader>cd` shows the diagnostic on the current line in a float.
- `<leader>xx` opens all diagnostics in a Trouble list; `<leader>xX` only the current buffer's. `]q` / `[q` step through Trouble or quickfix items.
- `<leader>sd` / `<leader>sD`: the same as a fuzzy picker.
- `<leader>cs` shows a symbol outline in Trouble.
- `<leader>ud` hides diagnostics; `<leader>uh` toggles inlay hints.

### Git

`<leader>gg` opens lazygit in a floating window over the project root. Stage, commit, push and rebase from there; `q` closes it.

Without leaving the buffer: `<leader>gb` blames the current line, `<leader>gf` shows the history of the current file, `<leader>gs` git status, `<leader>gl` the log, `<leader>gd` changed hunks as a picker. `<leader>gB` opens the current line on GitHub, `<leader>gY` copies the link. `<leader>gi` / `<leader>gp` list open GitHub issues / pull requests (uses `gh`).

### Terminal

`<C-/>` toggles a floating terminal in the project root, from normal mode or from inside the terminal. Press `<Esc>` twice quickly (within 200 ms) to get to normal mode inside it, for scrolling or yanking output. `<leader>fT` opens one in the cwd instead.

### Windows, tabs and sessions

`<leader>|` and `<leader>-` split right / below, `<leader>wd` closes the window, `<leader>wm` zooms it. `<C-w>` still works and, after `<C-w><Space>`, stays active for repeated window commands. Tab pages live under `<leader><Tab>`.

`<leader>qs` restores the session for the current directory, `<leader>ql` the last one, `<leader>qq` quits everything.

## Plugins, tools and updates

Two package managers are involved:

- **lazy.nvim** manages Neovim plugins. `<leader>l` opens it. Plugin versions are pinned in `lazy-lock.json`.
- **Mason** installs external tools: language servers, formatters, debug adapters. `<leader>cm` opens it.

The first time `nvim` starts in a UI after a fresh clone, lazy.nvim installs the plugins and Mason installs the servers and tools the config asks for (basedpyright, ruff, debugpy, roslyn, csharpier, …). Give it a minute and restart.

Updating:

1. `:Lazy update` (or `U` inside `<leader>l`) updates plugins and rewrites `lazy-lock.json`.
2. Restart, check `:LazyHealth`, use it for a bit.
3. Commit `lazy-lock.json`. If an update breaks something, `git checkout lazy-lock.json` and `:Lazy restore` puts every plugin back on the pinned commit.
4. `:MasonUpdate` refreshes the Mason registries; then `U` inside `<leader>cm` updates installed tools. Mason tools are not pinned by the lockfile.

lazy.nvim checks for updates in the background but doesn't notify; the count shows in the `<leader>l` window.

## Python

basedpyright (type checking in `standard` mode) and ruff (lint, format, organize imports) attach to `.py` files. Formatting with ruff happens on save.

**Virtual environments.** basedpyright picks up a uv project's `./.venv` automatically, so imports from installed packages resolve without doing anything. For other layouts, `<leader>cv` picks a venv.

**Tests.** neotest runs pytest:

| Task | Key |
| --- | --- |
| Run the nearest test / the file / all test files | `<leader>tr` / `<leader>tt` / `<leader>tT` |
| Rerun the last run | `<leader>tl` |
| Summary tree / output of the nearest test | `<leader>ts` / `<leader>to` |
| Debug the nearest test | `<leader>td` |

**Debugging** uses debugpy:

1. `<leader>db` sets a breakpoint (`<leader>dB` with a condition).
2. `<leader>dc` starts or continues; pick a launch configuration (e.g. the current file). To debug a test, use `<leader>td`, or `<leader>dPt` / `<leader>dPc` for the test method / class under the cursor.
3. Step with `<leader>di` (into), `<leader>dO` (over), `<leader>do` (out), `<leader>dC` (run to cursor).
4. `<leader>de` evaluates the expression under the cursor or the selection. `<leader>du` toggles the debug UI, `<leader>dt` terminates.

`<leader>co` organizes imports with ruff.

**Gotcha: Python on PATH.** Mason builds debugpy (and any other pip-installed tool) with the first suitable `python3` it finds. macOS's `/usr/bin/python3` is 3.9 and too old; uv's Python in `~/.local/bin` works. That path is only on PATH in a zsh shell, so start `nvim` from a terminal, not from a GUI launcher.

## C#/.NET

roslyn.nvim provides the language server (the same Roslyn server VS Code uses) and handles .NET 10 `.slnx` as well as `.sln` solutions. CSharpier formats on save.

**Opening a solution.** `cd` into the solution directory and start `nvim` there. Roslyn picks the solution automatically when you open a `.cs` file; with several solutions, `:Roslyn target` switches between them. The first load of a big solution takes a while: wait for the progress messages to finish before trusting diagnostics or go-to-definition. The Roslyn server keeps running for 15 minutes after the last Neovim closes, so reopening is fast.

All LSP keys from [Jump to definition, references, rename](#jump-to-definition-references-rename) work. C# adds codelens (reference counts above members): `<leader>cc` runs the one on the current line, `<leader>cC` refreshes them.

**Tests.** neotest runs tests through neotest-vstest with the same keys as Python: `<leader>tr`, `<leader>tt`, `<leader>tT`, `<leader>ts`, `<leader>to`. neotest finds the solution from the working directory, so if it shows no tests, check that `nvim` was started in the solution directory.

**Debugging** is not set up for C#: there is no working arm64 netcoredbg in Mason, so `<leader>d*` and `<leader>td` do nothing in `.cs` files.

**Formatting in repos that don't use CSharpier.** Toggle format-on-save for the buffer with `<leader>uF`, and format by hand with `<leader>cf` if needed.

`:checkhealth roslyn` warns that `vscode-html-language-server` is missing. That only matters for Razor/Blazor and can be ignored.

## Keymap cheat sheet

`<leader>` is Space. `<leader>sk` searches everything not listed here.

| Area | Keys |
| --- | --- |
| Files | `<leader><leader>` find, `<leader>fr` recent, `<leader>,` buffers, `<leader>e` explorer, `<leader>fc` config file |
| Search | `<leader>/` grep, `<leader>sw` word, `<leader>sb` buffer lines, `<leader>sr` replace, `<leader>sR` resume picker, `<leader>sk` keymaps, `<leader>sh` help |
| Buffers | `H` / `L` prev / next, `<leader>bd` delete, `<leader>bo` delete others, `` <leader>` `` other buffer |
| Motion | `s` Flash, `S` Flash Treesitter, `<C-Space>` / `<BS>` grow / shrink selection |
| Text objects | `af` `if` function, `ac` `ic` class, `ao` `io` block, `au` call, `ag` buffer |
| Code motions | `]f` `[f` function, `]c` `[c` class, `]a` `[a` parameter, `]]` `[[` reference |
| LSP | `K` hover, `gd` definition, `gr` references, `gI` implementation, `gy` type, `<leader>cr` rename, `<leader>ca` action, `<leader>cf` format, `<leader>ss` symbols |
| Diagnostics | `]d` `[d` any, `]e` `[e` errors, `<leader>cd` line, `<leader>xx` Trouble, `<leader>sd` picker |
| Git | `<leader>gg` lazygit, `<leader>gb` blame line, `<leader>gf` file history, `<leader>gB` open on GitHub |
| Terminal | `<C-/>` toggle, `<Esc><Esc>` normal mode |
| Tests | `<leader>tr` nearest, `<leader>tt` file, `<leader>tT` all, `<leader>ts` summary, `<leader>to` output |
| Debug (Python) | `<leader>db` breakpoint, `<leader>dc` continue, `<leader>di` / `<leader>dO` / `<leader>do` step, `<leader>td` debug test, `<leader>du` UI |
| Toggles | `<leader>uf` / `<leader>uF` format on save (global / buffer), `<leader>ud` diagnostics, `<leader>uh` inlay hints, `<leader>uw` wrap |
| Language | `<leader>cv` Python venv, `<leader>co` organize imports, `<leader>cc` C# codelens |
| Tools | `<leader>l` Lazy, `<leader>cm` Mason, `<leader>qq` quit all |
