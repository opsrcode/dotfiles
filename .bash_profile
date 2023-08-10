# Variáveis de ambiente do TexLive (LaTeX)
# export PATH="$PATH:/usr/local/texlive/2023/bin/x86_64-linux"
# export MANPATH="$MANPATH:/usr/local/texlive/2023/texmf-dist/doc/man"
# export INFOPATH="$INFOPATH:/usr/local/texlive/2023/texmf-dist/doc/info"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source aliases configuration file 
if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

# History configurations
shopt -s histappend
HISTCONTROL=ignoredups
export HISTIGNORE="&:ls:ll:la:l:lsd:[bf]g:exit:clear:history"

# More bash optional configurations
shopt -s cmdhist
shopt -s cdspell
shopt -s checkwinsize
set -o noclobber            # if you need, use this: >| filename
unset safe_term match_lhs

# Vi command line [ESC], Vim command Editor [ESC+v]
set -o vi
export EDITOR="/usr/local/bin/vim"

# change to parents, ex: 'up 2'
up() { cd $(eval printf '../'%.0s {1..$1}); }

# Colors for prompt
CYAN="\[$(tput setaf 6)\]"
RESET="\[$(tput sgr0)\]"

# Prompt configuration
PS1="[\u@\h ${CYAN}\W${RESET} \$?]${CYAN}\$${RESET} "
PS2="> "
PS3="> "
PS4="+ "

# Use bash-completion, if available
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion
