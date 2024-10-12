#!/bin/bash

# Redirect stdout and stderr to system log
exec 1> >(xargs -rL 1 logger -p info  -- "xinitrc:" )
exec 2> >(xargs -rL 1 logger -p error -- "xinitrc:" )
BASH_XTRACEFD=3
exec 3> >(xargs -rL 1 logger -p debug -- "xinitrc:" )
set -x

# Shorthand to check if a command exists
cmdexists()
{
	type "$1" 1>/dev/null 2>&1
}

# Xresources
[ -f "${HOME}/.Xresources" ] && xrdb -merge "${HOME}/.Xresources"
[ -f "${HOME}/.Xresources.local" ] && xrdb -merge "${HOME}/.Xresources.local"

# A simple black background, unless anything overrides it
xsetroot -solid black &

# Touchpad configuration
cmdexists synclient && synclient \
	TapButton1=1 \
	TapButton2=3 \
	TapButton3=2 \
	VertTwoFingerScroll=0 \
	VertEdgeScroll=1 \
	PalmDetect=1 \
	MaxTapTime=200 \
	MaxSpeed=3 \
	LockedDrags=1 \

# This seems necessary to make scrolling by touch screen work in Firefox
export MOZ_USE_XINPUT2=1

# Using Firefox in sensible-browser
export BROWSER=firefox

# For easy switching between different keyboard input methods such as Japanese
if cmdexists ibus-daemon; then
	export GTK_IM_MODULE='ibus'
	export QT_IM_MODULE='ibus'
	export XMODIFIERS='@im=ibus'
	ibus-daemon --xim --daemonize --replace &
fi

# Custom disper setting up monitor layout, keyboard layout and a bunch more stuff
cmdexists mydisper && mydisper &

# Finally, the window manager
if cmdexists i3; then
	if cmdexists dbus-run-session; then
		dbus-run-session i3 &
	else
		i3 &
	fi
else
# .. or just a terminal if we dont have i3
	xterm &
fi
WMPID="$!"

# Do not blank/turn off the monitor automatically. I want manual control
xset s off dpms 0 0 0 &
# screenlocker
if ! cmdexists xss-lock; then
	xmessage "xss-lock not available. You will not be able to lock the screen" &
elif [ -x "$HOME/.local/bin/screenlocker" ]; then
	xss-lock --transfer-sleep-lock -- "$HOME/.local/bin/screenlocker" &
elif cmdexists xscreensaver; then
	xscreensaver -no-splash &
	xss-lock -- xscreensaver -lock &
else
	xmessage "Neither custom screenlocker nor xscreensaver available. You will not be able to lock the screen" &
fi

# NetworkManager tray
cmdexists nm-tray && nm-tray &

# Pulseaudio tray
cmdexists pasystray && pasystray --notify=all --symbolic-icons &

xsetroot -cursor_name top_left_arrow &

# Wait for the window manager to stop
wait $WMPID

