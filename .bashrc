# ~/.bashrc:
# This file is used for non-login interactive shell. Stuff that should be run every time a shell/terminal opens belongs here. This includes aliases, functions, custom prompts, history control.

# Shorthand to check if a command exists
cmdexists()
{
	type "${@}" 1>/dev/null 2>&1
}

cmdexists dircolors && eval "$(dircolors -b)"

# colors for ls, etc.
# Warning: This might break in non-GNU versions of ls
if [ "${LS_COLORS}" ]; then
	alias ls="ls -hF --color=auto"
	alias ip='ip -human -color -oneline -brief'
else
	alias ls="ls -hF"
	alias ip='ip -human -oneline -brief'
fi

alias l="ls -l" # One entry per line
alias ll="l -L" # Dereference links. Show information about the file referenced, rather than the link itself
alias la="l -A" # Include dot-files
alias lla="ll -A" # Include dot-files

alias netstat='netstat --wide'


if cmdexists lynx; then
	alias lynx="lynx -nopause"
fi

if cmdexists mosh; then
	# Enables more efficient use of ssh -oControlMaster
	alias mosh="mosh --experimental-remote-ip=remote"
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
	LP_ENABLE_SCREEN_TITLE=0
	LP_ENABLE_SSH_COLORS=1
	if [ -e "$HOME/.local/share/liquidprompt/liquidprompt" ]; then
		source "$HOME/.local/share/liquidprompt/liquidprompt"
	elif [ -e /usr/share/liquidprompt/liquidprompt ]; then
		source /usr/share/liquidprompt/liquidprompt
	fi
fi

unset cmdexists
