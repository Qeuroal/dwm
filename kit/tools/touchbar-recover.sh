#!/bin/bash
set -euo pipefail

(( EUID == 0 )) || { echo 'Run this script with sudo' >&2; exit 1; }
exec 9>/run/lock/touchbar-recover.lock
flock -n 9 || { echo 'Another Touch Bar recovery is running' >&2; exit 1; }

find_touchbar() {
    local candidate
    for candidate in /sys/bus/usb/devices/*; do
        [[ -r "$candidate/idVendor" && -r "$candidate/idProduct" ]] || continue
        if [[ $(<"$candidate/idVendor") == 05ac && $(<"$candidate/idProduct") == 8302 ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    return 1
}

driver_ready() {
    local driver card
    for driver in "$device":*/driver; do
        [[ -L $driver && $(basename "$(readlink -f "$driver")") == appletbdrm ]] || continue
        for card in "${driver%/driver}"/drm/card[0-9]*; do
            [[ -r "$card/dev" && -c /dev/dri/${card##*/} ]] && return 0
        done
    done
    return 1
}

wait_for_driver() {
    local seconds=$1 attempt
    for ((attempt = 0; attempt <= seconds; attempt++)); do
        driver_ready && return 0
        (( attempt == seconds )) || sleep 1
    done
    return 1
}

settle_devices() {
    udevadm settle --timeout=10 || echo 'udev settle timed out; checking the Touch Bar directly' >&2
}

start_touchbar() {
    local action=${1:-start}
    if [[ $action == start ]] && systemctl is-active --quiet tiny-dfr.service; then
        echo 'tiny-dfr is already running; leaving it unchanged'
        return 0
    fi
    systemctl reset-failed tiny-dfr.service
    if ! systemctl "$action" tiny-dfr.service; then
        echo "tiny-dfr failed to $action" >&2
        return 1
    fi
    if ! systemctl is-active --quiet tiny-dfr.service; then
        echo 'tiny-dfr is not running after the start request' >&2
        return 1
    fi
    echo 'tiny-dfr is running'
}

write_configuration() {
    timeout --kill-after=2 10 /bin/bash -c 'printf "%s\n" "$2" > "$1"' \
        -- "$device/bConfigurationValue" "$1"
}

restore_configuration() {
    local result=$?
    trap - EXIT INT TERM
    if [[ $restore_needed == yes ]]; then
        # Only restore the same device; never recreate a vanished sysfs path.
        if [[ -r "$device/devnum" && -r "$device/bConfigurationValue" \
            && $(<"$device/devnum") == "$devnum" \
            && -r "$device/idVendor" && $(<"$device/idVendor") == 05ac \
            && -r "$device/idProduct" && $(<"$device/idProduct") == 8302 ]]; then
            if [[ $(<"$device/bConfigurationValue") != "$config" ]]; then
                echo "Attempting to restore USB configuration $config after interruption" >&2
                if ! write_configuration "$config"; then
                    echo 'Could not restore Touch Bar USB configuration' >&2
                    result=1
                fi
            fi
        else
            echo 'Touch Bar disappeared or changed; configuration cannot be restored safely' >&2
            result=1
        fi
    fi
    exit "$result"
}

device=''
for ((attempt = 0; attempt < 15; attempt++)); do
    if device=$(find_touchbar); then
        break
    fi
    sleep 1
done
[[ -n $device ]] || { echo 'Touch Bar USB display not found' >&2; exit 1; }

settle_devices
if wait_for_driver 5; then
    echo 'Touch Bar display driver is ready; skipping reset'
    start_touchbar
    exit 0
fi

config=$(<"$device/bConfigurationValue")
if [[ ! $config =~ ^[1-9][0-9]{0,2}$ ]] || (( config > 255 )); then
    echo "Invalid or unconfigured USB configuration: $config; refusing to guess a replacement" >&2
    exit 1
fi
devnum=$(<"$device/devnum")
restore_needed=no
trap restore_configuration EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

echo "Recovering Touch Bar display: $device (configuration $config)"
restore_needed=yes
write_configuration 0
sleep 2
if [[ ! -r "$device/devnum" || ! -e "$device/bConfigurationValue" \
    || $(<"$device/devnum") != "$devnum" ]]; then
    echo 'Touch Bar USB path disappeared or changed during reset' >&2
    exit 1
fi
write_configuration "$config"
restore_needed=no
settle_devices

if wait_for_driver 15; then
    echo 'Touch Bar display driver and DRM device recovered'
    start_touchbar restart
    exit 0
fi
echo 'Touch Bar display recovery failed; check kernel and tiny-dfr logs' >&2
exit 1
