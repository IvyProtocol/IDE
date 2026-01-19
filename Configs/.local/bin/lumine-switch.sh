#!/usr/bin/env bash

scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalvariable.sh"
IFS=$'\n\t'

# Define directories
rasiPath="${rasiDir}/shell.rasi"

apply_config() {
    local rasiTarget="${cacheDir}/ivy-shell"
    local awCheck=$(awk 'NR == 2' "${rasiTarget}/cache.rasi")
    if [[ -z "$awCheck" ]]; then
        echo "Cshell=\"$1\"" >> "${rasiTarget}/cache.rasi"
    else
        sed -i "s|^Cshell=.*|Cshell=\"$1\"|" "${rasiTarget}/cache.rasi"
    fi

    [[ -e "${scrDir}/wbselecgen.sh" ]] && "${scrDir}/wbselecgen.sh" -s
}

main() {
    options=(dark light auto) 

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
