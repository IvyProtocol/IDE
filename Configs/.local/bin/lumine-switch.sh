#!/usr/bin/env bash
set -eo pipefail
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"

rasiPath="${rasiDir}/shell.rasi"

apply_config() {
    [[ $1 == "auto" ]] && wallIde=0
    [[ $1 == "dark" ]] && wallIde=1
    [[ $1 == "light" ]] && wallIde=2
    [[ $1 == "theme" ]] && wallIde=3 

    [[ -n "${enableWallIde}" ]] && setConf "enableWallIde" "${wallIde}" "${ideDir}/ide.conf" || setConf "enableWallIde" "0" "${ideDir}/ide.conf"
    notify -m 2 -i "theme_engine" -p "Theme Mode: $1" -s "${confDir}/dunst/icons/hyprdots.svg" -t 900 -a "t1"
    [[ ! -e "${scrDir}/ivy-shell.sh" ]] && exit 1
    if [[ "${wallIde}" -eq 3 ]]; then
        setConf "ideTheme|enableWallIde" "${PrevThemeIde}|3" "${ideDir}/ide.conf" &
        sed -i 's|^[[:space:]]*source[[:space:]]*=[[:space:]]*./themes/wallbash-ide.conf|#source = ./themes/wallbash-ide.conf|' "${confDir}/hypr/hyprland.conf" &
        "${scrDir}/modules/ivyshell-helper.sh"
        exit 0
    else
        setConf "ideTheme" "Wallbash-Ivy" "${confDir}/ivy-shell/ide.conf" &
        sed -i 's|^#[[:space:]]*source[[:space:]]*=[[:space:]]*./themes/wallbash-ide.conf|source = ./themes/wallbash-ide.conf|' "${confDir}/hypr/hyprland.conf" &
        "${scrDir}/ivy-shell.sh" "${wallSet}" --"${1}"
    fi

    if [[ -z "${wallSet}" && -x "${scrDir}/wbselecgen.sh" ]]; then
        rnSel=$(find "${wallDir}" -maxpath 1 -type f | shuf -n 1)
        "${scrDir}/wbselecgen.sh" -i "${rnSel}"
    fi
}

rofi_wallbash() {
    if [[ -z "${rofiScale}" || "${rofiScale}" -eq 0 ]]; then
        rofiScale=10
    fi

    r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
    elem_border=$(( hypr_border * 4 ))
    r_override="window{border-radius:${elem_border}px;} element{border-radius:${elem_border}px;}"

    ivyshellModes=(theme auto dark light) 
    choice=$(printf '%s\n' "${ivyshellModes[@]}" | rofi -i -dmenu -theme-str "${r_scale}" -theme-str "${r_override}" -config "$rasiPath" -select "${ivyshellModes[$(($enableWallIde + 1))]}" )

    [[ -z "$choice" ]] && { echo "No option selected. Exiting."; exit 0; }
    apply_config "$choice"
}

[[ -z "$1" ]] && rofi_wallbash || apply_config "$1"
