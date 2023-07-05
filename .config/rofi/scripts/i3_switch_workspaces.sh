#!/bin/bash
if [ $# -eq 0 ]; then
    i3-msg -t get_workspaces | tr ',' '\n' | grep "name" | sed 's/"name":"\(.*\)"/\1/g' | sort -n
else
	i3-msg workspace "$*" >/dev/null
fi
