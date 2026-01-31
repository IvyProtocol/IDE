#!/usr/bin/env bash
set -eo pipefail
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"

rasiPath="${rasiDir}/shell.rasi"

apply_config() {
    local ideDir="${confDir}/ivy-shell"

    [[ $1 == "auto" ]] && wallIde=0
    [[ $1 == "dark" ]] && wallIde=1
    [[ $1 == "light" ]] && wallIde=2

    [[ -n "${enableWallIde}" ]] && sed -i "s|^enableWallIde=[0-9]|enableWallIde=${wallIde}|" "${ideDir}/ide.conf" || sed -i "s|^enableWallIde=.*|enableWallIde=0|" "${ideDir}/ide.conf"
    notify -m 1 -p "Theme Mode: $1" -s "${swayncDir}/icons/palette.png"

    [[ ! -e "${scrDir}/ivy-shell.sh" ]] && exit 1
    ext="${wallSet}"
    [[ "${wallIde}" -eq 0 ]] && "${scrDir}/ivy-shell.sh" -i "$ext" -c auto  
    [[ "${wallIde}" -eq 1 ]] && "${scrDir}/ivy-shell.sh" -i "$ext" -c dark 
    [[ "${wallIde}" -eq 2 ]] && "${scrDir}/ivy-shell.sh" -i "$ext" -c light



    if [[ -z "${ext}" && -x "${scrDir}/wbselecgen.sh" ]]; then
        rnSel=$(find "${wallDir}" -maxpath 1 -type f | shuf -n 1)
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
    echo "$choice"
}

if pgrep -x "rofi" >/dev/null; then
    pkill rofi
fi

main "$@"
