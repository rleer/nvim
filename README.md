# nvim

Neovim config based on the [LazyVim starter](https://github.com/LazyVim/starter), with Python and C#/.NET support.

New to Neovim or LazyVim coming from Vim? See [docs/neovim-intro.md](docs/neovim-intro.md).

## Prerequisites (macOS)

On a fresh Mac:

1. Install the Xcode Command Line Tools (git and the C compiler that builds Treesitter parsers): `xcode-select --install`. The Homebrew installer offers to do this too.
2. Install [Homebrew](https://brew.sh).
3. Install the tools:

   ```sh
   brew install neovim tree-sitter-cli ripgrep fd fzf lazygit gh uv
   brew install --cask dotnet-sdk font-jetbrains-mono-nerd-font
   ```

4. Install a Python that Mason can use for its pip-based tools, and put `~/.local/bin` on PATH:

   ```sh
   uv python install 3.14
   uv tool update-shell
   ```

   Open a new shell and check that `python3.14 --version` works.

5. Set your terminal's font to "JetBrainsMono Nerd Font". Use a terminal with true color support (Ghostty, kitty, WezTerm, iTerm2; not Terminal.app).

What each one is for:

| Tool | Needed for |
| --- | --- |
| `neovim` | Neovim itself (LazyVim needs 0.11.2 or newer) |
| `tree-sitter-cli` + C compiler | building the Treesitter parsers on first start |
| `ripgrep`, `fd` | grep and file pickers |
| `fzf` | checked by `:checkhealth lazyvim` |
| `lazygit` | `<leader>gg` |
| `gh` | GitHub issue and PR pickers (`<leader>gi`, `<leader>gp`); optional |
| `uv` + Python 3.14 | Mason installs basedpyright and debugpy with pip and needs Python 3.10 or newer; macOS's `/usr/bin/python3` is 3.9. uv also manages project venvs |
| `dotnet-sdk` | runs the Roslyn language server (.NET 10), installs CSharpier, runs C# tests |
| Nerd Font | icons in the explorer, statusline and pickers |

The `dotnet-sdk` cask is the latest SDK. Projects that pin an older SDK in `global.json` need that SDK installed as well (from [dotnet.microsoft.com](https://dotnet.microsoft.com/download/dotnet)).

curl, tar and unzip, which Mason and the parser installer use, ship with macOS.

## Install

```sh
git clone git@github.com:rleer/nvim.git ~/workspace/nvim
ln -s ~/workspace/nvim ~/.config/nvim
nvim
```

Move any existing `~/.config/nvim` out of the way first. On a machine without a GitHub SSH key, clone `https://github.com/rleer/nvim.git` instead.

On the first start lazy.nvim installs the plugins pinned in `lazy-lock.json`, nvim-treesitter builds the parsers, and Mason installs the language servers and tools (basedpyright, ruff, debugpy, roslyn, csharpier, lua-language-server, stylua, shfmt). Leave it running until `:Mason` shows nothing pending, then restart and run `:checkhealth`.

Expected `:checkhealth` warnings that need no action: lazy.nvim's luarocks (no plugin here needs it), Mason's missing toolchains for unused languages (Go, cargo, PHP, Java, …), conform's `fish_indent`, and roslyn's `vscode-html-language-server` (only used for Razor).

Start `nvim` from a shell, not a GUI launcher, so `~/.local/bin` is on PATH when Mason installs or updates its pip-based tools.

Vim keeps its own config in `~/dotfiles`, so both editors work side by side.
