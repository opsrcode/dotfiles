filetype plugin indent on
let mapleader=','
set tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab smarttab encoding=utf-8
set backspace=indent,eol,start history=10 autoindent laststatus=2 showmatch
set matchtime=1 hlsearch incsearch cmdheight=1 cursorline shell=bash showcmd
set textwidth=78 cursorlineopt=number ignorecase showtabline=1 numberwidth=2
set winwidth=80 wildmode=longest,list smartcase background=dark t_Co=256 magic
set nocompatible backup path+=/etc/** hidden autoread colorcolumn=+2 lazyredraw
set copyindent preserveindent nowrap so=5 ruler
hi ColorColumn ctermbg=black ctermfg=white guibg=black guifg=white
set statusline=%<%f%m\ \[%{&ff}:%{&fenc}:%Y]\ %{getcwd()}\ \ \
		\[%{strftime('%Y/%b/%d\ %a\ %I:%M\ %p')}\]\ %=\
		 \ %l\/%L\ %c%V\ %P
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
autocmd!
autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \       exe "normal g`\"" |
        \ endif
cnoremap %% <c-r>=expand('%:h').'/'<cr>
map <leader>e :edit %%
map <leader>v :view %%
map <tab> :e#<cr>
map <leader>, :Lexplore<cr>
nmap <silent> <C-e> :Lexplore<CR>
nnoremap <Leader>c :%s/\<<C-r><C-w>\>/<C-r><C-w>
vnoremap <Leader>c y:%s/<C-r>"/<C-r>"
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25
colorscheme paige-dark-system
syntax enable
runtime! ftplugin/man.vim
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
nnoremap <silent> <leader>f :Files<cr>
autocmd Filetype html,javascript,php,python,css setlocal ts=2 sw=2
