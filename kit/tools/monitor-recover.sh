#!/bin/bash

layout=~/.screenlayout/dual.sh
internal=eDP-1
# External outputs enabled by dual.sh.
outputs=(DP-2 DP-5)
mode=2560x1440

if [[ ! -r "$layout" ]]; then
    echo "Cannot read screen layout: $layout" >&2
    exit 1
fi

state=$(xrandr --query) || exit 1
if ! awk -v output="$internal" '$1 == output && $2 == "connected" { found = 1 } END { exit !found }' <<< "$state"; then
    echo "$internal is not connected; leaving displays unchanged" >&2
    exit 1
fi

off_args=()
while read -r output; do
    off_args+=(--output "$output" --off)
done < <(awk -v internal="$internal" '
    ($2 == "connected" || $2 == "disconnected") && $1 != internal { print $1 }
' <<< "$state")

xrandr --output "$internal" --auto "${off_args[@]}" || exit 1

for ((attempt = 0; attempt < 15; attempt++)); do
    sleep 1
    state=$(xrandr --query) || exit 1
    ready=1
    for output in "${outputs[@]}"; do
        if ! awk -v output="$output" -v mode="$mode" '
            /^[^[:space:]]/ { selected = ($1 == output && $2 == "connected") }
            selected && $1 == mode { found = 1 }
            END { exit !found }
        ' <<< "$state"; then
            ready=0
            break
        fi
    done
    if ((ready)); then
        if source "$layout"; then
            exit 0
        fi

        echo "Failed to apply the saved layout; enabling $internal" >&2
        xrandr --output "$internal" --auto
        exit 1
    fi
done

echo "$output did not reconnect with mode $mode; $internal was left enabled" >&2
exit 1
