#!/bin/bash

/usr/bin/amixer -qM set Master 5%- unmute || exit $?
state=$(LC_ALL=C /usr/bin/amixer -M get Master) || exit $?
volume=$(printf '%s\n' "$state" | sed -n 's/.*\[\([0-9][0-9]*\)%\].*/\1/p' | head -n 1)
[[ $volume =~ ^[0-9]+$ ]] || exit 1
label="Volume ${volume}%"
value=$volume
if [[ $state == *'[off]'* ]]; then
    label="Muted (${volume}%)"
    value=0
fi
notify-send -a dwm-volume -u low -t 1500 \
    -h "int:value:$value" -h string:x-dunst-stack-tag:dwm-volume \
    -h boolean:transient:true "$label"
bash ~/.dwm/scripts/dwm-status-refresh.sh
