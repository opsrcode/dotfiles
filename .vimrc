" VIM compilation
" git clone https://github.com/vim/vim.git
" ./configure --with-features=huge \
" 	--enable-multibyte \
" 	--enable-rubyinterp=yes \
" 	--enable-python3interp=yes \
" 	--with-python3-command=$PYTHON_VER \
" 	--with-python3-config-dir=$(python3-config --configdir) \
" 	--enable-perlinterp=yes \
" 	--enable-luainterp=yes \
" 	--with-lua-prefix=/usr/local \
" 	--enable-gui=gtk2 \
" 	--prefix=/usr/local
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
	\ 	exe "normal! g'\"" |
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
nnoremap <silent> <leader>fzf :Files<cr>

" Environment configuration
set path+=/etc/** backup term=$TERM mouse= t_Co=256 termencoding=utf-8 lazyredraw
set encoding=utf-8 shell=/bin/bash nocompatible hidden autoread ttyfast
set ttybuiltin ttyscroll=3
set backupdir=~/.vim/vimswap,/var/tmp,/tmp
set directory=~/.vim/vimswap,/var/tmp,/tmp

" Tab/Window configuration
set textwidth=80 cc=+1 showcmd cmdheight=1 showtabline=1 ruler background=dark
set winwidth=80 winheight=25 scrolloff=5 sidescrolloff=5 laststatus=2
hi ColorColumn ctermbg=white ctermfg=black
colorscheme quiet
syntax enable

" Statusline configuration
set statusline=%<%f%m\ \[%{&ff}:%{&fenc}:%Y]\ %{getcwd()}\ \ \
		\[%{strftime('%Y/%b/%d\ %a\ %I:%M\ %p')}\]\ %=\
		 \ %l\/%L\ %c%V\ %P

" Mechanisms configuration
set history=1000 undolevels=1000 magic wildmenu wildmode=longest,list,full
set backspace=indent,eol,start hlsearch incsearch ignorecase smartcase
set omnifunc=syntaxcomplete#Complete

" Editor configuration
set tabstop=4 shiftwidth=4 expandtab softtabstop=4 smarttab showmatch matchtime=1
set autoindent copyindent preserveindent smartindent smarttab nowrap
set foldmethod=indent foldlevel=99 foldnestmax=10 foldenable foldcolumn=1
set foldopen=search,tag,block,percent quickfixtextfunc=printf

" Remaps
 
" expand the current directory
cnoremap %% <c-r>=expand('%:h').'/'<cr>

" edit/view a file in the current directory or the alternate file
map <leader>e :edit %%
map <leader>v :view %%
map <tab> :e#<cr>

" open the current directory in a tree view
map <leader>, :Lexplore<cr>
nmap <silent> <C-e> :Lexplore<CR>

" change all occurrences of the word under the cursor or the selected text
nnoremap <Leader>ch :%s/\<<C-r><C-w>\>/<C-r><C-w>
vnoremap <Leader>ch y:%s/<C-r>"/<C-r>"
