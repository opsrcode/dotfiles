#
# ~/.bash_profile
#

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

HISTCONTROL=erasedups
shopt -s cdspell
let -o noclobber
set -o vi ; export EDITOR="/usr/local/bin/vim"

[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
  . /usr/share/bash-completion/bash_completion
