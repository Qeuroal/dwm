#!/bin/bash

if [[ ${1:-} != --locked ]]; then
    exec flock -n -E 0 --close "${XDG_RUNTIME_DIR:-/run/user/$UID}/dwm-status.lock" /bin/bash "$0" --locked
fi

pid_file="${XDG_RUNTIME_DIR:-/run/user/$UID}/dwm-status.pid"
trap ':' USR1
trap 'rm -f "$pid_file"' EXIT
printf '%s\n' "$$" > "$pid_file" || exit 1

while true
do
	. ~/.dwm/kit/status/dwm-status-refresh.sh
	sleep 2 &
    timer=$!
    wait "$timer" || {
        kill "$timer" 2>/dev/null
        wait "$timer" 2>/dev/null
    }
done
