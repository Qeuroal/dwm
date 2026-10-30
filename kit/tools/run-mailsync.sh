#!/bin/bash

command -v mailsync >/dev/null 2>&1 || exit 0

if [[ ${1:-} != --locked ]]; then
    exec flock -n -E 0 --close "${XDG_RUNTIME_DIR:-/run/user/$UID}/dwm-mailsync.lock" /bin/bash "$0" --locked
fi

while :; do
	mailsync
	sleep 300
done
