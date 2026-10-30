#!/bin/bash

if [[ ${1:-} != --locked ]]; then
    exec flock -n -E 0 --close "${XDG_RUNTIME_DIR:-/run/user/$UID}/dwm-wallpaper.lock" /bin/bash "$0" --locked
fi

while true; do
	bash ~/.dwm/kit/wallpaper/wp-change.sh
	sleep 10m
done
