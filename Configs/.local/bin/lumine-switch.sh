#!/usr/bin/env bash
set -eo pipefail
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"

rasiPath="${rasiDir}/shell.rasi"

apply_config() {

    [[ $1 == "auto" ]] && wallIde=0
    [[ $1 == "dark" ]] && wallIde=1
    [[ $1 == "light" ]] && wallIde=2

    [[ -n "${enableWallIde}" ]] && setConf "enableWallIde" "${wallIde}" "${ideDir}/ide.conf" || setConf "enableWallIde" "0" "${ideDir}/ide.conf"
    notify -m 1 -p "Theme Mode: $1" -s "${swayncDir}/icons/palette.png"

    [[ ! -e "${scrDir}/ivy-shell.sh" ]] && exit 1
    [[ -n "${wallIde}" ]] && "${scrDir}/ivy-shell.sh" -i "${wallSet}" -c "${1}" 

    if [[ -z "${wallSet}" && -x "${scrDir}/wbselecgen.sh" ]]; then
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
