#!/usr/bin/env bash

scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"
IFS=$'\n\t'

rasiPath="${rasiDir}/shell.rasi"

apply_config() {
    local ideDir="${confDir}/ivy-shell"

    [[ $1 == "auto" ]] && wallIde=0
    [[ $1 == "dark" ]] && wallIde=1
    [[ $1 == "light" ]] && wallIde=2

    [[ -n "${enableWallIde}" ]] && sed -i "s|^enableWallIde=[0-9]|enableWallIde=${wallIde}|" "${ideDir}/ide.conf" || sed -i "s|^enableWallIde=.*|enableWallIde=0|" "${ideDir}/ide.conf"

    [[ ! -e "${scrDir}/ivy-shell.sh" ]] && exit 1
    ext="${wallSet}"
    [[ "${wallIde}" -eq 0 ]] && "${scrDir}/ivy-shell.sh" -i "$ext" -c auto -t 
    [[ "${wallide}" -eq 1 ]] && "${scrDir}/ivy-shell.sh" -i "$ext" -c dark -t
    [[ "${wallIde}" -eq 2 ]] && "${scrDir}/ivy-shell.sh" -i "$ext" -c light -t

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
