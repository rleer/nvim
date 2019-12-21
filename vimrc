" Basis settings
filetype plugin indent on
syntax on
set encoding=utf-8
set clipboard=unnamedplus

" Statusline
set laststatus=2
let g:lightline = {
		\ 'colorscheme': 'wombat',
		\ }
set noshowmode

" Show file stats
set ruler

" Show line numbers
set number

" Blink cursor on error instead of beeping (grr)
set visualbell

" Whitespace
set wrap
set textwidth=80
set formatoptions=tcqrn1
set tabstop=2
set shiftwidth=2
set softtabstop=2
" set expandtab
set noshiftround

" Keybindings
inoremap jk <ESC>

