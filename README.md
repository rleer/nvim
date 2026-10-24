# nvim

Neovim config based on the [LazyVim starter](https://github.com/LazyVim/starter).

## Setup (macOS)

```sh
brew install neovim fd tree-sitter-cli
git clone git@github.com:rleer/nvim.git ~/workspace/vim
ln -s ~/workspace/vim ~/.config/nvim
nvim
```

lazy.nvim bootstraps itself on first start and installs the plugins pinned in `lazy-lock.json`. Run `:LazyHealth` afterwards.

Vim keeps its own config in `~/dotfiles`, so both editors work side by side.

### C# debugger (one-time manual step)

Mason only has an x86_64 build of netcoredbg for macOS, so the arm64 build is installed by hand. `lua/plugins/dotnet.lua` points the `netcoredbg` and `coreclr` DAP adapters at it.

```sh
gh release download 3.2.0-1092 -R Samsung/netcoredbg -p netcoredbg-osx-arm64.zip -D /tmp
unzip -q /tmp/netcoredbg-osx-arm64.zip -x '__MACOSX/*' -d ~/.local/share
~/.local/share/netcoredbg/netcoredbg --version
```

`:checkhealth dap` reports the adapter command as not executable until this is done. Switch back to Mason once it ships an arm64 build (mason-registry PR #15719).
