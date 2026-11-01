#!/bin/sh

# A dwm_bar function to show the default audio output volume
# Joe Standring <git@joestandring.com>
# GNU GPLv3

# Dependencies: libpulse (pactl)

dwm_alsa () {
    STATE=$(LC_ALL=C pactl get-sink-volume @DEFAULT_SINK@) || return 1
    VOL=$(printf '%s\n' "$STATE" | grep -oE '[0-9]+%' | tr -d '%' | sort -n | tail -n 1)
    case "$VOL" in
        ''|*[!0-9]*) return 1 ;;
    esac
    MUTE=$(LC_ALL=C pactl get-sink-mute @DEFAULT_SINK@) || return 1

    LABEL=VOL
    if [ "$VOL" -eq 0 ] || [ "$MUTE" = 'Mute: yes' ]; then
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

