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
