# ~/.bashrc:
# This file is used for non-login interactive shell. Stuff that should be run every time a shell/terminal opens belongs here. This includes aliases, functions, custom prompts, history control.

# Use git for managing dotfiles
# Source of idea: https://www.atlassian.com/git/tutorials/dotfiles
alias dotfiles='git --git-dir="$HOME/.dotfiles.git/" --work-tree="$HOME"'
# Initial setup (how it all started):
# git init --bare "$HOME/.dotfiles.git"
# 
# Clone via bundle:
# alice$ dotfiles bundle create dotfiles.bundle main
# alice$ scp dotfiles.bundle bob:
# bob$ git clone --branch main --bare dotfiles.bundle "$HOME/.dotfiles.git"
# This creates a 'remote' entry in ~/.dotfiles.git/config pointing to the dotfiles.bundle file. Future updates:
# alice$ dotfiles bundle create dotfiles.bundle main
# alice$ scp dotfiles.bundle bob:
# bob$ dotfiles pull origin main
#
# Clone from github:
# git clone --branch main --bare https://github.com/ttytyper/dotfiles.git "$HOME/.dotfiles.git"
#
# Final steps:
# dotfiles config --local status.showUntrackedFiles no
# dotfiles checkout main # Will tell you if you need to move any pre-existing files out of the way. Use --force to delete all of them
# dotfiles submodule update --init --recursive

# Shorthand to check if a command exists
cmdexists()
{
	type "${@}" 1>/dev/null 2>&1
}

# colors for ls, etc.
# Warning: This might break in non-GNU versions of ls
if [ "${LS_COLORS}" ]; then
	alias ls="ls -hF --color=auto"
else
	alias ls="ls -hF"
fi

alias l="ls -l"
alias ll="l -L" # Dereference links. Show information about the file referenced, rather than the link itself
alias lla="l -A"

alias netstat='netstat --wide'
alias ip='ip -human -color -oneline -brief'

if cmdexists lynx; then
	alias lynx="lynx -nopause"
fi

# Automatically cd into directories when entered as commands
shopt -s autocd

shopt -u nullglob

# Bash completion
[ -f /etc/bash_completion ] && . /etc/bash_completion

# Liquidprompt bling. Only runs in interactive shells, not from scripts, scp etc.
if [[ $- = *i* ]]; then
	LP_BATTERY_THRESHOLD=10
	LP_HOSTNAME_ALWAYS=1
	LP_USER_ALWAYS=0
	LP_ENABLE_TITLE=1
	if [ -e "$HOME/.local/share/liquidprompt/liquidprompt" ]; then
		source "$HOME/.local/share/liquidprompt/liquidprompt"
	elif [ -e /usr/share/liquidprompt/liquidprompt ]; then
		source /usr/share/liquidprompt/liquidprompt
	fi
fi

unset cmdexists
