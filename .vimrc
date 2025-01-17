if &compatible
  set nocompatible
endif

if has('reltime')
  set incsearch ignorecase smartcase
endif

if has('mouse')
  if &term =~ 'xterm'
    set mouse=a
  else
    set mouse=nvi
  endif
endif

if &t_Co > 2
  syntax on
  let c_comment_strings=1
  set hlsearch
endif

if has('syntax') && has('eval')
  packadd! matchit
endif

if !exists(':DiffOrig')
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
	\ | wincmd p | diffthis
endif

if has('langmap') && exists('+langremap')
  set nolangremap
endif

filetype plugin indent on
augroup vimStartup
  autocmd!
  autocmd BufReadPost *
	\ let line = line("'\"")
	\ | if line >= 1 && line <= line("$") && &filetype !~# 'commit'
	\      && index(['xxd', 'gitrebase', 'tutor'], &filetype) == -1
	\ |   execute "normal! g`\""
	\ | endif
  autocmd TermResponse * if v:termresponse == "\e[>0;136;0c" | set background=dark | endif
augroup END

set path+=/etc/** backup directory=~/.vim/tmp,/var/tmp,/tmp
set backupdir=~/.vim/tmp,/var/tmp,/tmp termencoding=utf-8
set ruler showcmd display=truncate ttimeout ttimeoutlen=100 tabstop=8
set softtabstop=2 shiftwidth=2 noexpandtab autoindent smartindent
set omnifunc=syntaxcomplete#Complete wildmenu nowrap

colorscheme happy_hacking
setlocal textwidth=69 cc=+1
highlight ColorColumn term=reverse ctermbg=232 guibg=#393939

runtime! ftplugin/man.vim

let &runtimepath .= ',' . '/$HOME/.vim/'
let g:ft_man_open_mode = 'vert'
let mapleader=','

if has ('persistent_undo')
  let undoDir=expand('$HOME/.vim' . '/tmp')
  call system('mkdir -p ' . undoDir)
  let &undodir=undoDir
  set undolevels=100
  set undoreload=1000
  set undofile
endif

map <leader>, :Lexplore<CR>
map <leader>e :edit %%
map <leader>v :view %%
map <tab> :e#<CR>
map Q gq

sunmap Q

nmap <leader>h :botright vert help<CR>:vert resize 70<CR>:help<space>
nmap <leader>m :botright vert Man man<CR>:vert resize 70<CR>:Man<space>
nmap <leader>k <Plug>ManPreGetPage

nnoremap <leader>ch :%s/<C-r><C-w>/<C-r><C-w>/gc<C-f>$F/i
nnoremap <C-l> :noh<CR><C-l>
vnoremap <leader>ch y:%s/<C-r>=escape(@", '/\')<CR>/<C-r><C-w>/gc<C-f>$F/i
inoremap <C-U> <C-G>u<C-U>
cnoremap %% <C-r>=expand('%:h').'/'<CR>
