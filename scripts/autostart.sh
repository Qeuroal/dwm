#!/bin/bash

/bin/bash ~/.dwm/scripts/dwm-status.sh &
/bin/bash ~/.dwm/scripts/wp-autochange.sh &
#picom -o 0.95 -i 0.88 --detect-rounded-corners --vsync --blur-background-fixed -f -D 5 -c -b
picom -b
/bin/bash ~/.dwm/scripts/tap-to-click.sh &
/bin/bash ~/.dwm/scripts/inverse-scroll.sh &
/bin/bash ~/.dwm/scripts/setxmodmap-colemak.sh &
nm-applet &
xfce4-power-manager &
#xfce4-volumed-pulse &
/bin/bash ~/.dwm/scripts/run-mailsync.sh &
# ~/.dwm/scripts/autostart_wait.sh &
