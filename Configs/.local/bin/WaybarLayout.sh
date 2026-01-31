#!/usr/bin/env bash

scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"
IFS=$'\n\t'

# Define directories
wlDir="${wlDir}/Configs"
wcDir="${wcDir}/config"
rasiTarget="${rasiDir}/config-waybar.rasi"

apply_config() {
    wblayout "$1"
}

main() {
    current_target=$(readlink -f "$wcDir")
    current_name=$(basename "$current_target")

    mapfile -t options < <(
        find -L "$wlDir" -maxdepth 1 -type f -printf '%f\n' | sort
    )

    default_row=0
    MARKER="👉"
    for i in "${!options[@]}"; do
        if [[ "${options[i]}" == "$current_name" ]]; then
            options[i]="$MARKER ${options[i]}"
            default_row=$i
            break
        fi
    done

    choice=$(printf '%s\n' "${options[@]}" \
        | rofi -i -dmenu \
               -config "$rasiTarget" \
               -selected-row "$default_row"
    )

    [[ -z "$choice" ]] && { echo "No option selected. Exiting."; exit 0; }

    choice=${choice# $MARKER}

    case "$choice" in
        *)
            apply_config "$choice"
            ;;
    esac
}

if pgrep -x "rofi" >/dev/null; then
    pkill rofi
fi

main
