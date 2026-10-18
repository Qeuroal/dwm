#!/bin/bash

brightnessctl -d intel_backlight -n set +1% || exit $?
current=$(brightnessctl -d intel_backlight get) || exit $?
maximum=$(brightnessctl -d intel_backlight max) || exit $?
brightness=$(( (current * 100 + maximum / 2) / maximum ))
notify-send -a dwm-brightness -u low -t 1500 \
    -h "int:value:$brightness" -h string:x-dunst-stack-tag:dwm-brightness \
    -h boolean:transient:true "Brightness ${brightness}%"
