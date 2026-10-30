#!/bin/bash

wallpaper_dir="$HOME/.dwm/pictures"

if [ -d "$wallpaper_dir" ]; then
    feh --recursive --randomize --bg-fill "$wallpaper_dir"
fi
