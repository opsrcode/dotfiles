alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias orphans='[[ -n $(pacman -Qdt) ]] && sudo pacman -Rs $(pacman -Qdtq) || echo "No orphans to remove"'
