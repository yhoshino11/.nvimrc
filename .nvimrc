" Syntax
syntax on

" Dracula Theme
color Dracula

" Encoding
set encoding=utf-8
scriptencoding utf-8

" NeoBundle Scripts-----------------------------
if !1 | finish | endif

if has('vim_starting')
  if &compatible
    set nocompatible
  endif

  set runtimepath+=~/.nvim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.nvim/bundle/'))

NeoBundleFetch 'Shougo/neobundle.vim'

" LightLine-------------------------------------
NeoBundle 'itchyny/lightline.vim'
set laststatus=2
let g:lightline = {
      \ 'colorscheme': 'landscape',
      \ 'component': {
      \     'readonly': '%{&readonly?"⭤":""}',
      \   },
      \ 'separator': { 'left': '⮀', 'right': '⮂' },
      \ 'subseparator': { 'left': '⮁', 'right': '⮃' }
      \ }
if !has('gui_running')
  set t_Co=256
endif

call neobundle#end()

filetype plugin indent on

NeoBundleCheck
