#!/usr/bin/env bash

scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalvariable.sh"
IFS=$'\n\t'

# Define directories
rasiPath="${rasiDir}/shell.rasi"

apply_config() {
    local rasiTarget="${cacheDir}/ivy-shell"
    local awCheck=$(awk 'NR == 2' "${rasiTarget}/cache.rasi")
    local wallDir="${homDir}/Pictures/wallpapers"

    if [[ -z "$awCheck" ]]; then
        echo "Cshell=\"$1\"" >> "${rasiTarget}/cache.rasi"
    else
        sed -i "s|^Cshell=.*|Cshell=\"$1\"|" "${rasiTarget}/cache.rasi"
    fi

    [[ ! -e "${scrDir}/ivy-shell.sh" ]] && exit 1
    ext="${wallDir}/$(fl_wallpaper -r)"
    if [[ "$1" == "dark" ]]; then
        "${scrDir}/ivy-shell.sh" "$ext" -d
    elif [[ "$1" == "light" ]]; then
        "${scrDir}/ivy-shell.sh" "$ext" -l
    elif [[ "$1" == "auto" ]]; then
        "${scrDir}/ivy-shell.sh" "$ext" -a
    fi
    if [[ -z "${ext}" && -x "${scrDir}/wbselecgen.sh" ]]; then
        rnSel=$(find "${wallDir}" -maxpath 1 -type f | shuf -n 1) \
        "${scrDir}/wbselecgen.sh" -i "${rnSel}"
    fi
}

main() {
    options=(auto dark light) 

    choice=$(printf '%s\n' "${options[@]}" \
        | rofi -i -dmenu \
               -config "$rasiPath" \
               -selected-row "$default_row"
    )

    [[ -z "$choice" ]] && { echo "No option selected. Exiting."; exit 0; }
    
    apply_config "$choice"
}

if pgrep -x "rofi" >/dev/null; then
    pkill rofi
fi

main "$@"
