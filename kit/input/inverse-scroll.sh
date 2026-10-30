#!/bin/bash

command -v xinput >/dev/null 2>&1 || exit 0

while read -r id; do
    properties=$(xinput list-props "$id") || continue
    if [[ $properties == *"libinput Natural Scrolling Enabled ("* ]]; then
        xinput --set-prop "$id" "libinput Natural Scrolling Enabled" 1
    fi
done < <(xinput list --short | sed -n '/[Tt]ouchpad/s/.*id=\([0-9][0-9]*\).*/\1/p')
