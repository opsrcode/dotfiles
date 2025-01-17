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

set ruler showcmd display=truncate ttimeout ttimeoutlen=100 tabstop=8
set softtabstop=2 shiftwidth=2 noexpandtab autoindent smartindent
set omnifunc=syntaxcomplete#Complete wildmenu nowrap termencoding=utf-8

colorscheme happy_hacking
setlocal textwidth=69 cc=+1
highlight ColorColumn term=reverse ctermbg=232 guibg=#393939

map Q gq
sunmap Q
