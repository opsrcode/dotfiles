filetype plugin on
filetype indent on

runtime! ftplugin/man.vim

let mapleader=','
let g:ft_man_open_mode = 'vert'

autocmd!

autocmd BufReadPost *
      \ if line("'\"") > 1 && line("'\"") <= line("$") |
      \   exe "normal! g'\"" |
      \ endif

let &runtimepath .= ',' . '/$HOME/.vim/'
if has ('persistent_undo')
  let undoDir=expand('$HOME/.vim' . '/tmp')
  call system('mkdir -p ' . undoDir)
  let &undodir=undoDir
  set undolevels=100
  set undoreload=1000
  set undofile
endif

function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction

function! s:ChangeIndentation(size) abort
  try
    exe 'setlocal tabstop=' . a:size 'shiftwidth=' . a:size 'softtabstop=' . a:size
    echo 'New indentation size: ' . a:size
  catch 
    echohl ErrorMsg
    echo 'Invalid value'
    echohl None
  endtry
endfunction

function! s:CleanCode()
  norm mygg=G`y
  %retab
  %s= *$==e
  %s/\r//eg
endfunction

colo quiet

set path+=/etc/** backup termencoding=utf-8 lazyredraw encoding=utf-8 nocompatible
set hidden autoread ttyfast ttybuiltin ttyscroll=3 noeb vb t_vb=
set directory=~/.vim/tmp,/var/tmp,/tmp
set backupdir=~/.vim/tmp,/var/tmp,/tmp

set textwidth=70 cc=+1 showcmd cmdheight=1 showtabline=1 ruler winwidth=70
hi ColorColumn ctermbg=white ctermfg=black

set history=100 undolevels=100 magic wildmenu wildmode=longest,list,full
set backspace=indent,eol,start hlsearch incsearch ignorecase smartcase
set omnifunc=syntaxcomplete#Complete nostartofline

set expandtab smarttab showmatch matchtime=1 autoindent copyindent preserveindent
set smartindent smarttab nowrap foldmethod=indent foldlevel=99 foldnestmax=10
set foldenable foldcolumn=1 foldopen=search,tag,block,percent shiftround

cnoremap %% <C-r>=expand('%:h').'/'<CR>

map <leader>e :edit %%
map <leader>v :view %%
map <tab> :e#<CR>

map <leader>, :Lexplore<CR>
nmap <silent> <C-e> :Lexplore<CR>

nnoremap <leader>ch :%s/<C-r><C-w>/<C-r><C-w>/gc<C-f>$F/i
vnoremap <leader>ch y:%s/<C-r>=escape(@", '/\')<CR>/<C-r><C-w>/gc<C-f>$F/i

autocmd FileType * setlocal shiftwidth=2 tabstop=2 softtabstop=2

nnoremap <C-l> :nohl<CR><C-l>
nnoremap <leader>ss :call <SID>SynStack()<CR>
nnoremap <leader>df :call <SID>DiffWithSaved()<CR>
nmap <leader>= :call <SID>CleanCode()<CR>

nmap <leader>ci :call <SID>ChangeIndentation(nr2char(getchar()))<CR>
nmap <leader>h :botright vert help<CR>:vert resize 70<CR>:help<space>
nmap <leader>m :botright vert Man man<CR>:vert resize 70<CR>:Man<space>
nmap <leader>k <Plug>ManPreGetPage

vnoremap <silent> * :<C-u>
      \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
      \gvy/<C-r><C-r>=substitute(
      \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
      \gV:call setreg('"', old_reg, old_regtype)<CR>

vnoremap <silent> # :<C-u>
      \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
      \gvy?<C-r><C-r>=substitute(
      \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
      \gV:call setreg('"', old_reg, old_regtype)<CR>
