#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source aliases configuration file 
if [ -f ~/.bash_profile ]; then
	. ~/.bash_profile
fi
