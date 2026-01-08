#!/bin/bash

# Redirect stdout and stderr to system log
exec 1> >(logger --tag "${0##*/}" -p info  )
exec 2> >(logger --tag "${0##*/}" -p error )
exec 3> >(logger --tag "${0##*/}" -p debug )
BASH_XTRACEFD=3
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
xsetroot -solid black

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
		|| echo "synclient failed" >&2
fi

# This seems necessary to make scrolling by touch screen work in Firefox
export MOZ_USE_XINPUT2=1

# Using Firefox in sensible-browser
export BROWSER=firefox

# For easy switching between different keyboard input methods such as Japanese
if cmdexists ibus-daemon; then
	export GTK_IM_MODULE='ibus'
	export QT_IM_MODULE='ibus'
	export XMODIFIERS='@im=ibus'
	ibus-daemon --xim --daemonize --replace || echo "ibus-daemon failed" >&2
fi

# Custom disper setting up monitor layout, keyboard layout and a bunch more stuff
if cmdexists mydisper; then
	mydisper || echo "mydisper failed" >&2
fi

# Do not blank/turn off the monitor automatically. I want manual control
xset s off dpms 0 0 0
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

if cmdexists worksession-timer; then
	worksession-timer start
fi

# NetworkManager tray
if cmdexists nm-tray; then
	nm-tray &
fi

# Pulseaudio tray
cmdexists pasystray && pasystray --notify=all --symbolic-icons &

xsetroot -cursor_name top_left_arrow

# Finally, the window manager
if cmdexists i3; then
	if cmdexists dbus-run-session; then
		dbus-run-session i3
	else
		i3
	fi
else
# .. or just a terminal if we dont have i3
	xterm
fi
