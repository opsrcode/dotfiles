" VIM compilation
" git clone https://github.com/vim/vim.git
" ./configure --with-features=huge \
"       --enable-multibyte \
"       --enable-rubyinterp=yes \
"       --enable-python3interp=yes \
"       --with-python3-command=$PYTHON_VER \
"       --with-python3-config-dir=$(python3-config --configdir) \
"       --enable-perlinterp=yes \
"       --enable-luainterp=yes \
"       --with-lua-prefix=/usr/local \
"       --enable-gui=gtk2 \
"       --prefix=/usr/local
" make && sudo make install

filetype plugin on
filetype indent on

" Plugins
runtime! ftplugin/man.vim

" Global variables
let mapleader=','
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25
let g:tex_flavor = "latex"

" Autocommands/Functions
autocmd!

" open the last edited file at the last edited line
autocmd BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal! g'\"" |
      \ endif

"  open files with fzf
function! FZF() abort
  let l:tempname = tempname()
  execute 'silent !fzf --multi ' . ' --preview="cat {}"
        \--bind ctrl-k:preview-page-up,ctrl-j:preview-page-down
        \| awk ''{ print $1":1:0" }'' > ' . fnameescape(l:tempname)
  try
    execute 'cfile ' . l:tempname
    redraw!
  finally
    call delete(l:tempname)
  endtry
endfunction
command! -nargs=* Files call FZF()

" Show syntax highlighting groups for word under cursor
function! s:SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction

" Show differences between buffer and saved versions of a file
function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction

" Clean code function
function! s:CleanCode()
  norm mygg=G`y
  %retab
  %s= *$==e
  %s/\r//eg
endfunction

" Environment configuration
set path+=/etc/** backup term=$TERM mouse= t_Co=256 termencoding=utf-8 lazyredraw
set encoding=utf-8 shell=/bin/bash nocompatible hidden autoread ttyfast ttybuiltin
set ttyscroll=3 noeb vb t_vb=
set directory=~/.vim/tmp,/var/tmp,/tmp
set backupdir=~/.vim/tmp,/var/tmp,/tmp

" Tab/Window configuration
set textwidth=80 cc=+1 showcmd cmdheight=1 showtabline=1 ruler background=dark
set winwidth=80 winheight=25 scrolloff=8 sidescrolloff=8 laststatus=2
hi ColorColumn ctermbg=white ctermfg=black
colorscheme quiet
syntax enable

" Statusline configuration
set statusline=%<%f%m\ \[%{&ff}:%{&fenc}:%Y]\ %{getcwd()}\ \ \
      \[%{strftime('%Y/%b/%d\ %a\ %I:%M\ %p')}\]\ %=\

" Mechanisms configuration
set history=1000 undolevels=1000 magic wildmenu wildmode=longest,list,full
set backspace=indent,eol,start hlsearch incsearch ignorecase smartcase
set omnifunc=syntaxcomplete#Complete nostartofline

" Editor configuration
set expandtab smarttab showmatch matchtime=1 autoindent copyindent preserveindent
set smartindent smarttab nowrap foldmethod=indent foldlevel=99 foldnestmax=10
set foldenable foldcolumn=1 foldopen=search,tag,block,percent quickfixtextfunc=printf

" Remaps

" expand the current directory
cnoremap %% <C-r>=expand('%:h').'/'<CR>

" edit/view a file in the current directory or the alternate file
map <leader>e :edit %%
map <leader>v :view %%
map <tab> :e#<CR>

" open the current directory in a tree view
map <leader>, :Lexplore<CR>
nmap <silent> <C-e> :Lexplore<CR>

" nnoremap <leader>ch :%s/\<<C-R><C-W>\>/
nnoremap <leader>ch :%s/<C-r><C-w>//gc<C-f>$F/i
vnoremap <leader>ch y:%s/<C-r>=escape(@", '/\')<CR>//gc<C-f>$F/i

" easy switch for indent spaces
nmap <leader>2 :setlocal tabstop=2<CR>:setlocal shiftwidth=2<CR>:setlocal softtabstop=2<CR>
nmap <leader>4 :setlocal tabstop=4<CR>:setlocal shiftwidth=4<CR>:setlocal softtabstop=4<CR>

nnoremap <C-l> :nohl<CR><C-l>
nnoremap <leader>ss :call <SID>SynStack()<CR>
nmap <leader>= :call <SID>CleanCode()<CR>
nnoremap <silent> <leader>fz :Files<CR>
nnoremap <leader>df :call <SID>DiffWithSaved()<CR>
nmap <leader>h :botright vert help<CR>:vert resize 80<CR>:help<space>

" Search for selected text, forwards or backwards.
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
