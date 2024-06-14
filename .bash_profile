# TexLive (LaTeX) variables
export PATH="$PATH:/usr/local/texlive/2024/bin/x86_64-linux"
export MANPATH="$MANPATH:/usr/local/texlive/2024/texmf-dist/doc/man"
export INFOPATH="$INFOPATH:/usr/local/texlive/2024/texmf-dist/doc/info"

# If not running interactively, don't do anything.
[[ $- != *i* ]] && return

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

HISTCONTROL=erasedups # Erase duplicated entries.
shopt -s cdspell      # Corret minor erros in the spelling of a directory.
set -o noclobber      # Prevents you from overwriting existing files. '>|' '-i'
set -o vi ; export EDITOR="/usr/local/bin/vim"

PS1="[\u@\h \W \$?]\$ " # Prompt style with error code
# Programmable completion for th bash shell.
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
  . /usr/share/bash-completion/bash_completion
