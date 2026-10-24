#!/bin/bash

/bin/bash ~/.dwm/kit/status/dwm-status.sh &
/bin/bash ~/.dwm/kit/wallpaper/wp-autochange.sh &
#picom -o 0.95 -i 0.88 --detect-rounded-corners --vsync --blur-background-fixed -f -D 5 -c -b
picom --config ~/.dwm/kit/profiles/picom.conf -b
/bin/bash ~/.dwm/kit/input/tap-to-click.sh &
/bin/bash ~/.dwm/kit/input/inverse-scroll.sh &
# /bin/bash ~/.dwm/kit/input/setxmodmap-colemak.sh &
nm-applet &
xfce4-power-manager &
#xfce4-volumed-pulse &
/bin/bash ~/.dwm/kit/tools/run-mailsync.sh &
# ~/.dwm/kit/tools/autostart_wait.sh &
