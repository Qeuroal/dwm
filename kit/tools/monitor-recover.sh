#!/bin/bash
set -euo pipefail

# Horizontal monitor behind the HDMI switch, using the current screen layout.
output=DP-5
mode=2560x1440
position=1400x0

state=$(xrandr --query)
if ! awk -v output="$output" '$1 == output { found = 1 } END { exit !found }' <<< "$state"; then
    echo "Display output $output does not exist" >&2
    exit 1
fi

xrandr --output "$output" --off
for ((attempt = 0; attempt < 10; attempt++)); do
    sleep 1
    state=$(xrandr --query)
    if awk -v output="$output" -v mode="$mode" '
        /^[^[:space:]]/ { selected = ($1 == output && $2 == "connected") }
        selected && $1 == mode { found = 1 }
        END { exit !found }
    ' <<< "$state"; then
        xrandr --output "$output" --mode "$mode" --pos "$position" --rotate normal
        echo "$output enabled at $mode"
        exit 0
    fi
done

echo "$output did not reconnect with mode $mode; check the switch input and cables" >&2
exit 1
