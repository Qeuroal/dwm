#!/bin/bash

/bin/bash ~/.dwm/kit/status/dwm-status.sh &
/bin/bash ~/.dwm/kit/wallpaper/wp-autochange.sh &
#picom -o 0.95 -i 0.88 --detect-rounded-corners --vsync --blur-background-fixed -f -D 5 -c -b
if command -v picom &> /dev/null; then
    picom --config ~/.dwm/kit/profiles/picom.conf -b
fi
/bin/bash ~/.dwm/kit/input/tap-to-click.sh &
/bin/bash ~/.dwm/kit/input/inverse-scroll.sh &
# /bin/bash ~/.dwm/kit/input/setxmodmap-colemak.sh &
if command -v nm-applet &> /dev/null; then
    nm-applet &
fi
if command -v xfce4-power-manager &> /dev/null; then
    xfce4-power-manager &
fi
#xfce4-volumed-pulse &
/bin/bash ~/.dwm/kit/tools/run-mailsync.sh &
# ~/.dwm/kit/tools/autostart_wait.sh &
if command -v clash-verge &> /dev/null; then
    clash-verge &
fi
if command -v fcitx5 &> /dev/null ; then
    fcitx5 -d
fi

