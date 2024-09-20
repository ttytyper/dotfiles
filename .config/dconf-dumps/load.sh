#!/bin/bash
set -e

cd "$(dirname "$0")"
shopt -s globstar
for file in **/*.dconf; do
	dconf_path="/${file%*.dconf}/"
	dconf load "$dconf_path" < "$file"
done

