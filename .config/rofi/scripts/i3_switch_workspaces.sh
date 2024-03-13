#!/bin/bash
if [ $# -eq 0 ]; then
	i3-msg -t get_workspaces|jq -r '.[].name'|sort -n
else
	i3-msg workspace "$*" >/dev/null
fi
