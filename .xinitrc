#!/bin/bash

# Redirect stdout and stderr to system log
exec 1> >(xargs -rL 1 logger -p debug -s -- "xinitrc:" 2>&1)
exec 2> >(xargs -rL 1 logger -p error -s -- "xinitrc:" )

# Source .bash_profile, if existing, to get PATH and other vars
[ -f "${HOME}/.bash_profile" ] && . "${HOME}/.bash_profile"

WORKINGPIDS=""

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
# screenlocker
if ! cmdexists xss-lock; then
	xmessage "xss-lock not available. You will not be able to lock the screen" &
	BGPIDS="$BGPIDS $!"
elif [ -x "$HOME/.local/bin/screenlocker" ]; then
	xss-lock --transfer-sleep-lock -- "$HOME/.local/bin/screenlocker" &
	BGPIDS="$BGPIDS $!"
elif cmdexists xscreensaver; then
	xscreensaver -no-splash &
	BGPIDS="$BGPIDS $!"
	xss-lock -- xscreensaver -lock &
	BGPIDS="$BGPIDS $!"
else
	xmessage "Neither custom screenlocker nor xscreensaver available. You will not be able to lock the screen" &
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
