" Cursor Shape
if &term =~ "screen"
  let &t_SI = "\eP\e]50;CursorShape=1\x7\e\\"
  let &t_EI = "\eP\e]50;CursorShape=0\x7\e\\"
elseif &term =~ "xterm"
  let &t_SI = "\e]50;CursorShape=1\x7"
  let &t_EI = "\e]50;CursorShape=0\x7"
endif

" Font
set guifont=Ricty\ Discord:h14
set guifontwide=Ricty\ Discord:h14

" Map Leader
let mapleader = ","

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
      \ 'mode_map': { 'c': 'NORMAL' },
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ], ['ctrlpmark'] ],
      \   'right':[ [ 'syntastic', 'lineinfo' ], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'MyFugitive',
      \   'filename': 'MyFilename',
      \   'fileformat': 'MyFileformat',
      \   'filetype': 'MyFiletype',
      \   'fileencoding': 'MyFileencoding',
      \   'mode': 'MyMode',
      \   'ctrlpmark': 'CtrlPMark',
      \ },
      \ 'component_expand': {
      \   'syntastic': 'SyntasticStatuslineFlag',
      \ },
      \ 'component_type': {
      \   'syntastic': 'error',
      \ },
      \ 'separator':    { 'left': '⮀', 'right': '⮂' },
      \ 'subseparator': { 'left': '⮁', 'right': '⮃' }
      \ }

function! MyModified()
  return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyFugitive()
  try
    if expand('%:t') !~? 'Tagbar\|Gundo\|NERD' && &ft !~? 'vimfiler' && exists('*fugitive#head')
      let mark = '⭠ '  " edit here for cool mark
      let _    = fugitive#head()
      return strlen(_) ? mark._ : ''
    endif
  catch
  endtry
  return ''
endfunction

function! MyFilename()
  let fname = expand('%:t')
  return fname == 'ControlP' ? g:lightline.ctrlp_item :
        \ fname == '__Tagbar__' ? g:lightline.fname :
        \ fname =~ '__Gundo\|NERD_tree' ? '' :
        \ &ft   == 'unite' ? unite#get_status_string() :
        \ &ft   == 'vimshell' ? b:vimshell.current_dir :
        \ (''   != fname ? fname : '[No Name]') .
        \ (''   != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! MyFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! MyFileencoding()
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! MyMode()
  let fname = expand('%:t')
  return fname == '__Tagbar__' ? 'Tagbar' :
        \ fname == 'ControlP' ? 'CtrlP' :
        \ fname == '__Gundo__' ? 'Gundo' :
        \ fname == '__Gundo_Preview__' ? 'Gundo Preview' :
        \ fname =~ 'NERD_tree' ? 'NERDTree' :
        \ &ft   == 'unite' ? 'Unite' :
        \ &ft   == 'vimshell' ? 'VimShell' :
        \ winwidth(0) > 60 ? lightline#mode() : ''
endfunction

function! CtrlPMark()
  if expand('%:t') =~ 'ControlP'
    call lightline#link('iR'[g:lightline.ctrlp_regex])
    return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item
          \ , g:lightline.ctrlp_next], 0)
  else
    return ''
  endif
endfunction

let g:ctrlp_status_func = {
  \ 'main': 'CtrlPStatusFunc_1',
  \ 'prog': 'CtrlPStatusFunc_2',
  \ }

function! CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
  let g:lightline.ctrlp_regex = a:regex
  let g:lightline.ctrlp_prev  = a:prev
  let g:lightline.ctrlp_item  = a:item
  let g:lightline.ctrlp_next  = a:next
  return lightline#statusline(0)
endfunction

function! CtrlPStatusFunc_2(str)
  return lightline#statusline(0)
endfunction

let g:tagbar_status_func = 'TagbarStatusFunc'

function! TagbarStatusFunc(current, sort, fname, ...) abort
    let g:lightline.fname = a:fname
  return lightline#statusline(0)
endfunction

augroup AutoSyntastic
  autocmd!
  autocmd BufWritePost * call s:syntastic()
augroup END

function! s:syntastic()
  SyntasticCheck
  call lightline#update()
endfunction

let g:unite_force_overwrite_statusline    = 0
let g:vimshell_force_overwrite_statusline = 0

if !has('gui_running')
  set t_Co=256
else
  :cd $HOME
endif
set noshowmode

" Fugitive
NeoBundle 'tpope/vim-fugitive'

" Tagbar
NeoBundle 'majutsushi/tagbar'
nnoremap <Leader>t :TagbarToggle<CR>

" Gundo
NeoBundle 'sjl/gundo.vim'
nnoremap <Leader>g :GundoToggle<CR>

" Unite
NeoBundle 'Shougo/unite.vim'
let g:unite_enable_start_insert = 0

" 大文字小文字を区別しない
let g:unite_enable_ignore_case  = 1
let g:unite_enable_smart_case   = 1

" grep検索
nnoremap <silent> ,a  :<C-u>Unite grep:. -buffer-name=search-buffer<CR>

" カーソル位置の単語をgrep検索
nnoremap <silent> ,cg :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W>

 " grep検索結果の再呼出
nnoremap <silent> ,r  :<C-u>UniteResume search-buffer<CR>

" unite grep に ag(The Silver Searcher) を使う
if executable('ag')
  let g:unite_source_grep_command       = 'ag'
  let g:unite_source_grep_default_opts  = '--nogroup --nocolor --column'
  let g:unite_source_grep_recursive_opt = ''
endif


" CtrlP
NeoBundle 'ctrlpvim/ctrlp.vim'
let g:ctrlp_map = '<C-f>'
let g:ctrlp_cmd = 'CtrlP'

" NERDTree
NeoBundle 'scrooloose/nerdtree'
let NERDSpaceDelims    = 1
let NERDShutUp         = 1
let NERDTreeShowHidden = 1
nnoremap <Leader>n :NERDTreeToggle<CR>

" Show NERDTree if No filename
let file_name = expand("%:p")
if has('vim_starting') && file_name == ''
  autocmd VimEnter * execute 'NERDTree ./'
endif

" VimShell
NeoBundle 'Shougo/vimshell', { 'rev' : '3787e5' }

" Syntastic
NeoBundle 'scrooloose/syntastic'
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list            = 1
let g:syntastic_check_on_open            = 1
let g:syntastic_check_on_wq              = 1
let g:syntastic_mode_map                 = { 'mode': 'passive', 'active_filetypes': ['ruby']}
let g:syntastic_ruby_checkers            = ['rubocop']
let g:syntastic_ruby_rubocop_exec        = '$HOME/.rbenv/shims/rubocop'

" NeoSnippet
NeoBundle 'Shougo/neosnippet.vim'
" Plugin key-mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)"
\: pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)"
\: "\<TAB>"

" For snippet_complete marker.
if has('conceal')
  set conceallevel=2 concealcursor=niv
endif
" Enable snipMate compatibility feature.
let g:neosnippet#enable_snipmate_compatibility = 1

" Tell Neosnippet about the other snippets
let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'

" NeoSnippet-Snippets
NeoBundle 'Shougo/neosnippet-snippets'

" Vim-Snippets
NeoBundle 'honza/vim-snippets'

" NeoComplecache
NeoBundle 'Shougo/neocomplcache.vim'
"Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length        = 3
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

" Enable heavy features.
" Use camel case completion.
"let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
"let g:neocomplcache_enable_underbar_completion = 1

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
    \ }

" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplcache#undo_completion()
inoremap <expr><C-l>     neocomplcache#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return neocomplcache#smart_close_popup() . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? neocomplcache#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h>  neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><BS>   neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplcache#close_popup()
inoremap <expr><C-e>  neocomplcache#cancel_popup()
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? neocomplcache#close_popup() : "\<Space>"

" For cursor moving in insert mode(Not recommended)
"inoremap <expr><Left>  neocomplcache#close_popup() . "\<Left>"
"inoremap <expr><Right> neocomplcache#close_popup() . "\<Right>"
"inoremap <expr><Up>    neocomplcache#close_popup() . "\<Up>"
"inoremap <expr><Down>  neocomplcache#close_popup() . "\<Down>"
" Or set this.
"let g:neocomplcache_enable_cursor_hold_i = 1
" Or set this.
"let g:neocomplcache_enable_insert_char_pre = 1

" AutoComplPop like behavior.
"let g:neocomplcache_enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplcache_enable_auto_select = 1
"let g:neocomplcache_disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

" Enable omni completion.
autocmd FileType css           setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript    setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python        setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml           setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplcache_force_omni_patterns')
  let g:neocomplcache_force_omni_patterns = {}
endif
let g:neocomplcache_force_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplcache_force_omni_patterns.c   = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplcache_force_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplcache_force_omni_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

" VimProc
NeoBundle 'Shougo/vimproc.vim', {
       \ 'build' : {
       \     'mac' : 'make -f make_mac.mak',
       \     'unix': 'make -f make_unix.mak'
       \    }
       \ }

" GitGutter
NeoBundle 'airblade/vim-gitgutter'
let g:gitgutter_max_signs = 1000

" Gist
NeoBundle 'mattn/gist-vim', {'depends': 'mattn/webapi-vim'}
let g:github_user = 'yhoshino11'

" Gitv
NeoBundle 'gregsexton/gitv'

" Tabular
NeoBundle 'godlygeek/tabular'
nmap <Leader>a= :Tabularize /=<CR>
vmap <Leader>a= :Tabularize /=<CR>
nmap <Leader>a: :Tabularize /:\zs<CR>
vmap <Leader>a: :Tabularize /:\zs<CR>
nmap <Leader>a{ :Tabularize /{<CR>
vmap <Leader>a{ :Tabularize /{<CR>

" Multiple-Cursors
NeoBundle 'terryma/vim-multiple-cursors'
let g:multi_cursor_use_default_mapping=0
let g:multi_cursor_next_key='<C-n>'
let g:multi_cursor_prev_key='<C-p>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<Esc>'

" Tagbar
NeoBundle 'majutsushi/tagbar'

" Better-Whitespace
NeoBundle 'ntpeters/vim-better-whitespace'

" NERDCommenter
NeoBundle 'scrooloose/nerdcommenter'
nmap <Leader>z <Plug>NERDCommenterToggle
vmap <Leader>z <Plug>NERDCommenterToggle

" Auto-Save
NeoBundle 'vim-scripts/vim-auto-save'
let g:auto_save                = 1
let g:auto_save_silent         = 1
let g:auto_save_in_insert_mode = 0
let g:auto_save_postsave_hook  = 'TagsGenerate'

" Tags
NeoBundle 'szw/vim-tags'
let g:vim_tags_use_vim_dispatch = 1
let g:vim_tags_auto_generate    = 1

" Alpaca-Tags
NeoBundle 'alpaca-tc/alpaca_tags', {
    \ 'depends'  : ['Shougo/vimproc.vim',  'Shougo/unite.vim'],
    \ 'autoload' : {
    \   'commands'      : ['AlpacaTags',  'AlpacaTagsUpdate',  'AlpacaTagsSet',  'AlpacaTagsBundle',  'AlpacaTagsCleanCache'],
    \   'unite_sources' : ['tags']
    \ }
    \ }
let g:alpaca_tags#config = {
    \   '_' : '-R --sort=yes',
    \   'ruby': '--languages=+Ruby',
    \ }

augroup AlpacaTags
  autocmd!
  if exists(':AlpacaTags')
    autocmd BufWritePost Gemfile AlpacaTagsBundle
    autocmd BufEnter     *       AlpacaTagsSet

    autocmd BufWritePost *       AlpacaTagsUpdate
  endif
augroup END

" DelimitMate
NeoBundle 'Raimondi/delimitMate'

" RSpec output
NeoBundle 'glidenote/rspec-result-syntax'

" QuickRun
NeoBundle 'thinca/vim-quickrun'
let g:quickrun_config                              = {}
let g:quickrun_config['split']                     = 'vertical'
let g:quickrun_config['close_on_empty']            = 1
let g:quickrun_config['runner']                    = 'vimproc'
let g:quickrun_config['runner/vimproc/updatetime'] = 40
let g:quickrun_config['ruby.rspec'] = {
      \ 'command'                  : 'rspec',
      \ 'cmdopt'                   : '-cfd',
      \ 'args'                     : "%{line('.')}",
      \ 'exec'                     : ['bundle exec %c %o %s:%a'],
      \ 'outputter/buffer/filetype': 'rspec-result',
      \ 'filetype'                 : 'rspec-result'
      \ }

augroup RSpec
  autocmd!
  autocmd BufWinEnter,BufNewFile *_spec.rb set filetype=ruby.rspec
augroup END 

set splitright

nnoremap <Leader>r :QuickRun<CR>

" Switch
NeoBundle 'AndrewRadev/switch.vim'
nnoremap ! :Switch<CR>

" Ag
NeoBundle 'rking/ag.vim'
let g:agprg = 'ag --nocolor --nogroup --column'

" Ref
NeoBundle 'thinca/vim-ref'
nmap R <Plug>(ref-keyword)
" let g:ref_open = 'vsplit'
" let g:ref_refe_cmd = "rurema"
" let g:ref_refe_version = 2
"
" nnoremap <Leader>rr :<C-U>Ref refe<Space>

" Ref-Ri
NeoBundle 'yuku-t/vim-ref-ri'

" Ruby-Matchit
NeoBundle 'vim-scripts/ruby-matchit'

" Monster
NeoBundle 'osyo-manga/vim-monster'

" Ruby-XmpFilter
NeoBundle 't9md/vim-ruby-xmpfilter'
augroup xmpfilters
  autocmd!
  autocmd FileType ruby nmap <Leader>a <Plug>(xmpfilter-run)
  autocmd FileType ruby xmap <Leader>a <Plug>(xmpfilter-run)
  autocmd FileType ruby imap <Leader>a <Plug>(xmpfilter-run)

  autocmd FileType ruby nmap <Leader>m <Plug>(xmpfilter-mark)
  autocmd FileType ruby xmap <Leader>m <Plug>(xmpfilter-mark)
  autocmd FileType ruby imap <Leader>m <Plug>(xmpfilter-mark)
augroup END

" Endwise
NeoBundle 'tpope/vim-endwise'

" RSpec
NeoBundle 'Keithbsmiley/rspec.vim'
map <Leader>c :call RunCurrentSpecFile()<CR>
map <Leader>s :call RunNearestSpec()<CR>
map <Leader>l :call RunLastSpec()<CR>
map <Leader>A :call RunAllSpecs()<CR>

NeoBundleLazy 'thoughtbot/vim-rspec', {
      \ 'depends'  : 'tpope/vim-dispatch',
      \ 'autoload' : { 'filetypes' : ['ruby'] }
      \ }
let s:bundle = neobundle#get('vim-rspec')
function! s:bundle.hooks.on_source(bundle)
  let g:rspec_command = 'Dispatch bundle exec rspec -cfd {spec}'
endfunction

" Ruby
NeoBundle 'vim-ruby/vim-ruby'
let ruby_operators = 1
let ruby_space_errors = 1
let ruby_fold = 1
let ruby_spellcheck_strings = 1
" When Code Volume Grows
" set foldlevel=1
" set foldnestmax=2

" augroup foldmethod-syntax
  " autocmd!
  " autocmd InsertEnter * if &l:foldmethod ==# 'syntax'
  " \                   |   setlocal foldmethod=manual
  " \                   | endif
  " autocmd InsertLeave * if &l:foldmethod ==# 'manual'
  " \                   |   setlocal foldmethod=syntax
  " \                   | endif
" augroup END

" set foldenable
" set foldmethod=syntax

" autocmd InsertEnter * if !exists('w:last_fdm')
            " \| let w:last_fdm=&foldmethod
            " \| setlocal foldmethod=manual
            " \| endif
" autocmd InsertLeave,WinLeave * if exists('w:last_fdm')
            " \| let &l:foldmethod=w:last_fdm
            " \| unlet w:last_fdm
            " \| endif

" Rails
NeoBundle 'tpope/vim-rails'

" Rake
NeoBundle 'tpope/vim-rake'

" AnsiEsc
NeoBundle 'vim-scripts/AnsiEsc.vim'

" RSense
NeoBundleLazy 'marcus/rsense', {
      \ 'autoload': { 'filetypes': ['ruby'] }
      \ }
let g:rsenseUseOmniFunc = 1
if !exists('g:neocomplcache_omni_patterns')
  let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'

" RSense-Completion
NeoBundle 'Shougo/neocomplcache-rsense.vim', {
      \ 'depends': ['Shougo/neocomplcache.vim', 'marcus/rsense'],
      \ }

" Jedi
NeoBundleLazy "davidhalter/jedi-vim", {
      \ "autoload": {
      \   "filetypes": [ "python", "python3", "djangohtml"],
      \ },
      \ "build": {
      \   "mac": "pip install jedi",
      \   "unix": "pip install jedi",
      \ }}

" Pyenv
NeoBundleLazy 'lambdalisue/vim-pyenv', {
      \ 'depends': ['davidhalter/jedi-vim'],
      \ 'autoload': {
      \   'filetypes': [ 'python', 'python3'],
      \ }}

" Surround
NeoBundle 'vim-scripts/surround.vim'
nmap ,( csw(
nmap ,) csw)
nmap ,{ csw{
nmap ,} csw}
nmap ,[ csw[
nmap ,] csw]
nmap ,' csw'
nmap ," csw"

call neobundle#end()

filetype plugin indent on

NeoBundleCheck

" Basic-----------------------------------------
" Syntax
syntax on

" Dracula Theme
color Dracula

" Encoding
set encoding=utf-8
scriptencoding utf-8

" Backspace
set bs=indent,eol,start

" Auto Indent
set autoindent

" Smart Indent
set smartindent

" Don't make backup file
set nobackup

" Don't make swap file
set noswapfile

" Keep 100 History
set history=100

" Show cursor info
set ruler

" Use hex
set display=uhex

" Keep 15 lines from cursor
set scrolloff=15

" Virtual Edit
set virtualedit=block

" Check if file has been changed from outside
set autoread

" No welcome message
set shortmess+=I

" Tab
set tabstop=2
set shiftwidth=2
set softtabstop=0
set expandtab

" Search
set ignorecase
set wrapscan
set hlsearch

" Number
set numberwidth=2
set nowrap

" Yaml
autocmd FileType yaml setlocal expandtab ts=2 sw=2 fenc=utf-8

autocmd InsertLeave * setlocal nocursorline
autocmd InsertEnter * setlocal cursorline
autocmd InsertLeave * highlight StatusLine ctermfg=145 guifg=#c2bfa5
autocmd InsertEnter * highlight StatusLine ctermfg=12  guifg=#1E90FF
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

" Window management
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l


" FileTypes
augroup file_type
  autocmd!
  autocmd BufNewFile,BufRead Gemfile   setlocal filetype=ruby
  autocmd BufNewFile,BufRead Guardfile setlocal filetype=ruby
  autocmd BufNewFile,BufRead Brewfile  setlocal filetype=ruby
  autocmd BufNewFile,BufRead *.md      setlocal filetype=markdown
augroup END

" Code Folding
autocmd FileType ruby   setlocal foldmethod=syntax
autocmd FileType python setlocal foldmethod=indent
nnoremap <space> za

" Relative Number
set nonumber
set relativenumber

" ClipBoard
set clipboard=unnamed

" Show title
set title

" Maps
nmap - dd
nmap t viw

nmap <Leader>y 0v$y
nmap <Leader>p o<ESC>p
nmap <Leader>d 0v$d

nmap <Leader><Leader> :w<CR>
nmap <Leader><Leader><Leader> :q!<CR>

cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<CR>
map <leader>ew :e %%
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

nnoremap <leader>sv :source $MYVIMRC<CR>

nmap H 0
nmap L $
nmap J <C-D>
nmap K <C-U>
nmap , :
