# ~/.profile:
# This file is used for login interactive shells, such as ssh. Stuff that should run once per login belongs here, such as environment variables.

# Shorthand to check if a command exists
cmdexists()
{
	type "${@}" 1>/dev/null 2>&1
}

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
umask 022

# I want my ~/bin and various ~/sbin dirs to be part of my PATH
export PATH="$HOME/bin:$HOME/.local/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$PATH:/usr/X11R6/bin:/usr/X11R6/sbin"

if [ -z "$XDG_RUNTIME_DIR" ]; then
	if [ -d "/var/run/user/$UID" ]; then
		export XDG_RUNTIME_DIR="/var/run/user/$UID"
	elif mkdir -p "/tmp/user/$UID" && chown "$UID:$GID" "/tmp/user/$UID" && chmod 700 "/tmp/user/$UID"; then
		export XDG_RUNTIME_DIR="/tmp/user/$UID"
	fi
fi
[ -z "$XDG_CONFIG_HOME" ] && export XDG_CONFIG_HOME="$HOME/.config"
[ -z "$XDG_CACHE_HOME" ] && export XDG_CACHE_HOME="$HOME/.cache"
[ -z "$XDG_DATA_HOME" ] && export XDG_DATA_HOME="$HOME/.local/share"
[ -z "$XDG_STATE_HOME" ] && export XDG_STATE_HOME="$HOME/.local/state"

[ -f "$XDG_CONFIG_HOME/user-dirs.dirs" ] && . "$XDG_CONFIG_HOME/user-dirs.dirs"
[ -z "$XDG_DESKTOP_DIR" ] && export XDG_DESKTOP_DIR
[ -z "$XDG_DOWNLOAD_DIR" ] && export XDG_DOWNLOAD_DIR
[ -z "$XDG_DOCUMENTS_DIR" ] && export XDG_DOCUMENTS_DIR
[ -z "$XDG_MUSIC_DIR" ] && export XDG_MUSIC_DIR
[ -z "$XDG_PICTURES_DIR" ] && export XDG_PICTURES_DIR
[ -z "$XDG_VIDEOS_DIR" ] && export XDG_VIDEOS_DIR

[ -d "$XDG_CACHE_HOME" ] || mkdir -p "$XDG_CACHE_HOME"
[ -d "$XDG_DATA_HOME" ] || mkdir -p "$XDG_DATA_HOME"
[ -d "$XDG_STATE_HOME" ] || mkdir -p "$XDG_STATE_HOME"

# If we are working in a virtual console...
if [ "${TERM}" = "linux" ]; then
	# Change the beep frequency and length
	setterm -bfreq 400 -blength 100
	# Change the font to something more pleasing
	#setfont ka8x16thin-1
fi

# Don't log commands that begin with space, and also don't log repeated commands
export HISTCONTROL="ignoreboth"

if cmdexists locale; then
	if locale -a 2>/dev/null|grep -q '^en_DK\.utf8$'; then
		export LANGUAGE="en_DK.UTF-8"
		export LANG="en_DK.UTF-8"
		export LC_ALL="en_DK.UTF-8"
	elif locale -a 2>/dev/null|grep -q '^en_US\.utf8$'; then
		export LANGUAGE="en_US.UTF-8"
		export LANG="en_US.UTF-8"
		export LC_ALL="en_US.UTF-8"
	else
		# Fall back to POSIX locale if all preferred locales fail
		export LC_ALL="C"
	fi
fi
#export TZ="CET"

# I prefer vim, if available. Otherwise nano
if cmdexists vim; then
	export EDITOR="`which vim`"
elif cmdexists nano; then
	export EDITOR="`which nano`"
fi

# As pager, I prefer less, if available. Otherwise more
if cmdexists less; then
	export PAGER=less
elif cmdexists more; then
	export PAGER=more
fi

# I don't want less to log anything
export LESSHISTFILE="-"
export LESSHISTSIZE=0

# If an ecryptfs dir is present but locked, notify the user who might want a hint to unlock it
#if [ -d "$HOME/.Private" ] && [ -e "$HOME/.ecryptfs/Private.mnt" ] && cmdexists ecryptfs-mount-private && ! mountpoint -q "$(cat "$HOME/.ecryptfs/Private.mnt")"; then
#	echo "Note: ecryptfs is locked. Use ecryptfs-mount-private to unlock"
#fi

# gpg-agent, for managing my gpg key
if [ -d "${HOME}/.gnupg" ] && cmdexists gpg-agent; then
	# New way to start gpg-agent, implied by calling gpgconf.
	# If you get errors such as "inappropriate ioctl for device", try:
	# gpg-connect-agent /bye
	# Also check https://www.gnupg.org/documentation/manuals/gnupg-devel/Common-Problems.html
	export GPG_TTY=$(tty)
	echo UPDATESTARTUPTTY|gpg-connect-agent >/dev/null
	unset SSH_AGENT_PID
	if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
		export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
	fi
fi

# Use afuse and sshfs for auto mounting remote directories under ~/net
if cmdexists afuse; then
	if cmdexists sshfs && [ -d ~/net ] && ! mountpoint -q ~/net; then
	afuse -o mount_template='sshfs -oreconnect -oServerAliveInterval=15 -oServerAliveCountMax=3 -oControlMaster=no -oPasswordAuthentication=no -oConnectTimeout=3 -oIdentityFile=~/.ssh/sshfs.key %r: %m' -o unmount_template='fusermount -u -z %m' ~/net
	fi
fi

# Let Platform.io use the same build cache directory for all projects. This saves compilation time, particularly for Mbed projects.
# https://docs.platformio.org/en/latest/envvars.html#envvar-PLATFORMIO_BUILD_CACHE_DIR
# https://docs.platformio.org/en/latest/projectconf/section_platformio.html#projectconf-pio-build-cache-dir
export PLATFORMIO_BUILD_CACHE_DIR="$HOME/.cache/platformio/build_cache_dir"
export PLATFORMIO_BUILD_DIR="$HOME/.cache/platformio/build_dir"

if cmdexists mpd; then
	#export MPD_HOST="$XDG_RUNTIME_DIR/mpd/socket"
	export MPD_HOST="$HOME/.local/state/mpd.socket"
	[ ! -e "$MPD_HOST" ] && mpd
fi

# I want pass (password manager) to use the primary clipboard
export PASSWORD_STORE_X_SELECTION=primary
