#!/bin/sh

# A dwm_bar function to show the master volume of ALSA
# Joe Standring <git@joestandring.com>
# GNU GPLv3

# Dependencies: alsa-utils

dwm_alsa () {
    STATE=$(LC_ALL=C amixer -M get Master) || return 1
    VOL=$(printf '%s\n' "$STATE" | sed -n 's/.*\[\([0-9][0-9]*\)%\].*/\1/p' | head -n 1)
    case "$VOL" in
        ''|*[!0-9]*) return 1 ;;
    esac

    LABEL=VOL
    if [ "$VOL" -eq 0 ] || printf '%s\n' "$STATE" | grep -q '\[off\]'; then
        ICON="󰝟"
        LABEL=MUTE
    elif [ "$VOL" -le 33 ]; then
        ICON="󰕿"
    elif [ "$VOL" -le 66 ]; then
        ICON="󰖀"
    else
        ICON="󰕾"
    fi

    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
        printf "%s %s%%" "$ICON" "$VOL"
    else
        printf "%s %s%%" "$LABEL" "$VOL"
    fi
    printf "%s\n" "$SEP2"
}

