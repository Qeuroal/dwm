#!/bin/bash
# Screenshot: http://s.natalian.org/2013-08-17/dwm_status.png
# Network speed stuff stolen from http://linuxclues.blogspot.sg/2009/11/shell-script-show-network-speed.html

# Volume keys notify the loop so its network samples stay in the same process.
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    pid_file="${XDG_RUNTIME_DIR:-/run/user/$UID}/dwm-status.pid"
    if read -r status_pid 2>/dev/null < "$pid_file" && [[ $status_pid =~ ^[1-9][0-9]*$ ]]; then
        status_args=()
        if [[ -r /proc/$status_pid/cmdline ]]; then
            mapfile -d '' -t status_args < "/proc/$status_pid/cmdline"
        fi
        if [[ ${status_args[1]:-} -ef "$HOME/.dwm/kit/status/dwm-status.sh" && ${status_args[2]:-} == --locked ]] &&
            kill -USR1 "$status_pid" 2>/dev/null; then
            exit 0
        fi
    fi
fi

get_bytes() {
    interface=$(ip route get 8.8.8.8 2>/dev/null | awk '{ for (i=1; i<NF; i++) if ($i == "dev") { print $(i+1); exit } }')
    [[ -n $interface ]] || return 1
    read -r received_bytes transmitted_bytes < <(
        awk -v iface="$interface" '$1 == iface ":" { print $2, $10; exit }' /proc/net/dev
    )
    [[ $received_bytes =~ ^[0-9]+$ && $transmitted_bytes =~ ^[0-9]+$ ]] || return 1
    now=$(date +%s%N)
}

get_velocity() {
    local delta=$(($1 - $2)) elapsed=$((now - old_time))
    ((delta >= 0 && elapsed > 0)) || { printf '0KB/s'; return; }
    awk -v delta="$delta" -v elapsed="$elapsed" 'BEGIN {
        rate = delta * 1000000000 / 1024 / elapsed
        if (rate >= 1024) printf "%.2fMB/s", rate / 1024
        else printf "%dKB/s", rate
    }'
}

print_volume() {
	volume="$(amixer get Master | tail -n1 | sed -r 's/.*\[(.*)%\].*/\1/')"
	if test "$volume" -gt 0
	then
		echo -e "\uE05D${volume}"
	else
		echo -e "Mute"
	fi
}

print_mem(){
	memfree=$(($(grep -m1 'MemAvailable:' /proc/meminfo | awk '{print $2}') / 1024))
	echo -e "$memfree"
}

print_temp(){
	test -f /sys/class/thermal/thermal_zone0/temp || return 0
	echo $(head -c 2 /sys/class/thermal/thermal_zone0/temp)C
}

#!/bin/bash

get_time_until_charged() {

	# parses acpitool's battery info for the remaining charge of all batteries and sums them up
	sum_remaining_charge=$(acpitool -B | grep -E 'Remaining capacity' | awk '{print $4}' | grep -Eo "[0-9]+" | paste -sd+ | bc);

	# finds the rate at which the batteries being drained at
	present_rate=$(acpitool -B | grep -E 'Present rate' | awk '{print $4}' | grep -Eo "[0-9]+" | paste -sd+ | bc);

	# divides current charge by the rate at which it's falling, then converts it into seconds for `date`
	seconds=$(bc <<< "scale = 10; ($sum_remaining_charge / $present_rate) * 3600");

	# prettifies the seconds into h:mm:ss format
	pretty_time=$(date -u -d @${seconds} +%T);

	echo $pretty_time;
}

get_battery_combined_percent() {
	LC_ALL=C acpi -b 2>/dev/null | awk '
		match($0, /[0-9]+%/) {
			total += substr($0, RSTART, RLENGTH - 1)
			count++
		}
		END { if (count) printf "%d\n", total / count }
	'
}

get_battery_charging_status() {
    local percent=$1 icon supply
    if ((percent >= 90)); then
        icon=$'\U000f0079'
    elif ((percent >= 65)); then
        icon=$'\U000f0080'
    elif ((percent >= 40)); then
        icon=$'\U000f007e'
    elif ((percent >= 15)); then
        icon=$'\U000f007b'
    else
        icon=$'\U000f008e'
    fi
    for supply in /sys/class/power_supply/*; do
        if [[ -r "$supply/online" && $(<"$supply/online") == 1 ]]; then
            icon=$'\U000f0084'
            break
        fi
    done
    printf '%s' "$icon"
    return 0
}



print_bat(){
	#hash acpi || return 0
	#onl="$(grep "on-line" <(acpi -V))"
	#charge="$(awk '{ sum += $1 } END { print sum }' /sys/class/power_supply/BAT*/capacity)%"
	#if test -z "$onl"
	#then
		## suspend when we close the lid
		##systemctl --user stop inhibit-lid-sleep-on-battery.service
		#echo -e "${charge}"
	#else
		## On mains! no need to suspend
		##systemctl --user start inhibit-lid-sleep-on-battery.service
		#echo -e "${charge}"
	#fi
	#echo "$(get_battery_charging_status) $(get_battery_combined_percent)%, $(get_time_until_charged )";

    # if [ "`lspci | grep -i notebook`" = "" -a "`lspci | grep -i laptop`" = "" ]; then
    #     return
    # fi

    ans=""
    combinePercent=$(get_battery_combined_percent)
    flag=0
    if [ "$combinePercent" != "" ]; then
        ans="$(get_battery_charging_status "$combinePercent") $combinePercent%"
    fi

    echo "$ans"
}

print_date(){
	date '+%m.%d %H:%M'
}

show_record(){
	test -f /tmp/r2d2 || return
	rp=$(cat /tmp/r2d2 | awk '{print $2}')
	size=$(du -h $rp | awk '{print $1}')
	echo " $size $(basename $rp)"
}


LOC=$(readlink -f "${BASH_SOURCE[0]}")
DIR=$(dirname "$LOC")
export IDENTIFIER="unicode"

#. "$DIR/dwmbar-functions/dwm_transmission.sh"
#. "$DIR/dwmbar-functions/dwm_cmus.sh"
#. "$DIR/dwmbar-functions/dwm_resources.sh"
#. "$DIR/dwmbar-functions/dwm_battery.sh"
#. "$DIR/dwmbar-functions/dwm_mail.sh"
#. "$DIR/dwmbar-functions/dwm_backlight.sh"
. "$DIR/dwmbar-functions/dwm_alsa.sh"
#. "$DIR/dwmbar-functions/dwm_pulse.sh"
#. "$DIR/dwmbar-functions/dwm_weather.sh"
#. "$DIR/dwmbar-functions/dwm_vpn.sh"
#. "$DIR/dwmbar-functions/dwm_network.sh"
#. "$DIR/dwmbar-functions/dwm_keyboard.sh"
#. "$DIR/dwmbar-functions/dwm_ccurse.sh"
#. "$DIR/dwmbar-functions/dwm_date.sh"

memInfo=""
if [ -f ~/.dwm/status_config -a `cat ~/.dwm/status_config | grep -c "set show_mem true"` -gt 0 ]; then
    memInfo=" 💿 $(print_mem)M"
fi

velInfo=""
if grep -qx 'set show_vel true' "$HOME/.dwm/status_config" 2>/dev/null; then
    if get_bytes; then
        if [[ ${old_interface:-} == "$interface" && -n ${old_time:-} ]]; then
            velInfo=" ⬇️ $(get_velocity "$received_bytes" "$old_received_bytes") ⬆️ $(get_velocity "$transmitted_bytes" "$old_transmitted_bytes")"
        else
            velInfo=" ⬇️ 0KB/s ⬆️ 0KB/s"
        fi
        old_interface=$interface
        old_received_bytes=$received_bytes
        old_transmitted_bytes=$transmitted_bytes
        old_time=$now
    else
        unset old_interface old_time
    fi
else
    unset old_interface old_time
fi

# xsetroot -name "  💿 $(print_mem)M ⬇️ $vel_recv ⬆️ $vel_trans $(dwm_alsa) [ $(print_bat) ]$(show_record) $(print_date) "
#

alsaInfo=$(dwm_alsa)
if [ -f ~/.dwm/status_config -a `cat ~/.dwm/status_config | grep -c "set show_alsa true"` -gt 0 -a "${alsaInfo}" != "" ]; then
    alsaInfo=" ${alsaInfo}"
else
    alsaInfo=""
fi

recordInfo="$(show_record)"
if [ -f ~/.dwm/status_config -a `cat ~/.dwm/status_config | grep -c "set show_record true"` -gt 0 -a "$recordInfo" != "" ]; then
    recordInfo=" ${recordInfo}"
else
    recordInfo=""
fi

batInfo="$(print_bat)"
if [ -f ~/.dwm/status_config -a `cat ~/.dwm/status_config | grep -c "set show_bat true"` -gt 0 -a  "${batInfo}" != "" ]; then
    batInfo=" ${batInfo}"
else
    batInfo=""
fi

dateInfo=" $(print_date)"

xsetroot -name "${memInfo}${velInfo}${alsaInfo}${batInfo}${recordInfo}${dateInfo} "
