#!/bin/bash
set -e

dconf_paths=(
	/desktop/ibus/
)

for dconf_path in "${dconf_paths[@]}"; do
	file="$(dirname "$0")/${dconf_path%*/}.dconf"
	mkdir -pv "$(dirname "$file")"
	dconf dump "$dconf_path" > "$file"
done

