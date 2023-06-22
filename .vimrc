filetype plugin on
filetype plugin indent on
let mapleader=','
set tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab smarttab encoding=utf-8
set backspace=indent,eol,start history=10 autoindent laststatus=2 showmatch
set matchtime=1 hlsearch incsearch cmdheight=1 shell=bash showcmd textwidth=78
set ignorecase showtabline=1 numberwidth=2 winwidth=80 wildmode=longest,list
set smartcase background=dark magic nocompatible backup path+=/etc/** t_Co=256 
set hidden autoread colorcolumn=+2 lazyredraw copyindent preserveindent nowrap
set so=5 ruler omnifunc=syntaxcomplete#Complete
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
let g:tex_flavor = "latex"
autocmd Filetype html,javascript,php,python,css,tex setlocal ts=2 sw=2
nnoremap <Leader>rs :set keymap=russian-jcukenmac<cr>
nnoremap <Leader>km :set keymap=<cr>
