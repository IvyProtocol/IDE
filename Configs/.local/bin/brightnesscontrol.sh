#!/usr/bin/env bash
scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/globalcontrol.sh"

step=5  

get_brightness() {
    brightnessctl -m | cut -d, -f4 | tr -d '%'
}

icoDir="${confDir}/dunst/icons/vol"
send_notify() {
    local brightness=$1
    local angle=$(( (brightness + 2) / 5 * 5 ))
    ico="${icoDir}/vol-${angle}.svg"
    bar=$(seq -s "." $(($brightness / 15)) | sed 's/[0-9]//g' )
    notify-send -a "t2" -r 91190 -t 800 -i "${ico}" "${brightness}${bar}" "$(hyprctl -j monitors | jq -r '.[] | select(.focused==true) | .description')" 
}

chsh_brightctl() {
    local delta current new 
    delta=$1
    current=$(get_brightness)
    new=$((current + delta))

    (( new < 5 )) && new=5
    (( new > 100 )) && new=100

    brightnessctl set "${new}%"
    send_notify "${new}"
}

case "$1" in
    "--inc")
        chsh_brightctl "$step"
        ;;
    "--dec")
        chsh_brightctl "-$step"
        ;;
    *"|--get")
        get_brightness
        ;;
esac
