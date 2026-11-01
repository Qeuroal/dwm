#!/bin/bash

/usr/bin/pactl set-sink-volume @DEFAULT_SINK@ -5% || exit $?
/usr/bin/pactl set-sink-mute @DEFAULT_SINK@ 0 || exit $?
state=$(LC_ALL=C /usr/bin/pactl get-sink-volume @DEFAULT_SINK@) || exit $?
volume=$(printf '%s\n' "$state" | grep -oE '[0-9]+%' | tr -d '%' | sort -n | tail -n 1)
[[ $volume =~ ^[0-9]+$ ]] || exit 1
mute=$(LC_ALL=C /usr/bin/pactl get-sink-mute @DEFAULT_SINK@) || exit $?
label="Volume ${volume}%"
value=$volume
if [[ $mute == 'Mute: yes' ]]; then
    label="Muted (${volume}%)"
    value=0
fi
notify-send -a dwm-volume -u low -t 1500 \
    -h "int:value:$value" -h string:x-dunst-stack-tag:dwm-volume \
    -h boolean:transient:true "$label"
bash ~/.dwm/kit/status/dwm-status-refresh.sh
