#!/bin/bash

# Source .bash_profile, if existing, to get PATH and other vars
[ -f "${HOME}/.bash_profile" ] && . "${HOME}/.bash_profile"

WORKINGPIDS=""

# Redirect stdout and stderr to a file
exec 1>"$XDG_RUNTIME_DIR/xinit-output-$$.log"
exec 2>&1
#set -x

# A quick function to check if a command exists
cmdexists()
{
	type "$1" 1>/dev/null 2>&1
}

# Xresources
if [ -f "${HOME}/.Xresources" ]; then
	xrdb -merge "${HOME}/.Xresources"
fi
if [ -f "${HOME}/.Xresources.local" ]; then
	xrdb -merge "${HOME}/.Xresources.local"
fi

# Set the cursor to be the watch, to indicate that we're working
xsetroot -cursor_name watch

# A simple black background, unless anything overrides it
xsetroot -solid black

# Move cache and such to RAM medium
#if cmdexists unburden-home-dir; then
#	unburden-home-dir > /dev/null
#fi

# Select an X terminal
# Preferably urxvt, alternatively plain xterm
if cmdexists urxvt; then
	export XTERM="urxvt"
else
	export XTERM="xterm"
fi

# Touchpad configuration
if cmdexists synclient; then
	synclient \
		TapButton1=1 \
		TapButton2=3 \
		TapButton3=2 \
		VertTwoFingerScroll=0 \
		VertEdgeScroll=1 \
		PalmDetect=1 \
		MaxTapTime=200 \
		MaxSpeed=3 \
		LockedDrags=1 \
		LockedDragTimeout=1000
	#if cmdexists syndaemon; then
	#	# Disables the touch pad for 0.5 second after typing
	#	syndaemon -i 0.5 -d
	#fi
fi

# Seems that the default java toolkit doesn't like ratpoison. The menu bar
# doesn't show up in programs like josm and yaac. This var fixes it:
export AWT_TOOLKIT=MToolkit
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=508650
export _JAVA_AWT_WM_NONREPARENTING=y

# This seems necessary to make scrolling by touch screen work in Firefox
export MOZ_USE_XINPUT2=1
export BROWSER=firefox

# For Japanese input
export GTK_IM_MODULE='ibus'
export QT_IM_MODULE='ibus'
export XMODIFIERS='@im=ibus'
ibus-daemon --xim --daemonize --replace

# Disper handles multihead situations, with a hook to run feh for setting the background/wallpaper
if cmdexists mydisper; then
	mydisper
fi

if [ -x "$HOME/bin/yoga-disable-ts-on-pen-proximity.sh" ] && cmdexists xinput && xinput|grep 'Wacom ISDv4 EC Pen stylus'; then
	"$HOME/bin/yoga-disable-ts-on-pen-proximity.sh" &
	BGPIDS="$BGPIDS $!"
fi

# https://support.zoom.us/hc/en-us/articles/202082128-Black-Screen-During-Screen-Sharing
cmdexists && xcompmgr -c -l0 -t0 -r0 -o.00 &
BGPIDS="$BGPIDS $!"

# Finally, the window manager
if cmdexists i3; then
	if cmdexists dbus-run-session; then
		dbus-run-session i3 &
	else
		i3 &
	fi
	WM="i3"
else
# .. or just a terminal if we dont have i3
	"$XTERM" &
	WM="$XTERM"
fi
WMPID="$!"

# Do not blank/turn off the monitor automatically. I want manual control
xset s off dpms 0 0 0
# screensaver
if cmdexists xss-lock && cmdexists i3lock; then
	if [ -x "$HOME/bin/myi3lock" ]; then
		xss-lock --transfer-sleep-lock -- "$HOME/bin/myi3lock" --ignore-empty-password --color=000000 --show-failed-attempts --nofork &
	else
		xss-lock --transfer-sleep-lock -- i3lock --ignore-empty-password --color=000000 --show-failed-attempts --nofork &
	fi
	BGPIDS="$BGPIDS $!"
elif cmdexists xscreensaver; then
	xscreensaver -no-splash &
	if cmdexists xss-lock; then
		xss-lock -- xscreensaver -lock &
		BGPIDS="$BGPIDS $!"
	fi
else
	xmessage "i3lock and xss-lock or xscreensaver not available. You will likely not be able to lock this machine" &
	BGPIDS="$BGPIDS $!"
fi

# Parcellite syncs copy/paste selection buffers
#if cmdexists parcellite; then
#	parcellite --no-icon &
#	BGPIDS="$BGPIDS $!"
#fi

#if cmdexists redshift; then
#	redshift > /dev/null &
#	BGPIDS="$BGPIDS $!"
#fi

#if cmdexists wpa_gui; then
#	wpa_gui -t -i wlp4s0 &
#	BGPIDS="$BGPIDS $!"
#fi

if cmdexists nm-tray; then
	nm-tray &
	BGPIDS="$BGPIDS $!"
fi

if cmdexists pasystray; then
	pasystray --notify=all --symbolic-icons &
	BGPIDS="$BGPIDS $!"
fi

# Wait until working pids are done, then set the cursor to be the usual arrow, instead of a cross
if [ "$WORKINGPIDS" != "" ]; then
	wait $WORKINGPIDS
fi
xsetroot -cursor_name top_left_arrow
unset WORKINGPIDS

cmdexists unclutter && unclutter -idle 5 -noevents -reset -root
BPPIDS="$BGPIDS $!"

# If anything was logged, display it
#if [ -s "/tmp/$USER-xerrors.log" ]; then
#	xmessage -file "/tmp/$USER-xerrors.log" &
#fi

# Wait for the window manager to stop
wait $WMPID

# Kill any backgrounded pids
if [ "${BGPIDS}" != "" ]; then
	kill ${BGPIDS}
fi

if cmdexists unburden-home-dir; then
	unburden-home-dir -u > /dev/null # Undo/reverse
fi
