#!/bin/sh
echo -ne '\033c\033]0;Simple FPS\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Simple FPS.x86_64" "$@"
