#!/usr/bin/env bash
set -eo pipefail

# ────────────────────────────────────────────────
# Configuration
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"

themeDir="${ideDir}/theme"
rofiConf="${rasiDir}/selector.rasi"

log() { echo "[$0] "$@""; }

# ────────────────────────────────────────────────
themeSelTui() {
    thmChsh="${1}"
    thmImg="$(<"${themeDir}/${thmChsh}/wallpapers/.wallbash-main")"
    if [[ -n "${thmImg}" ]]; then
        if [[ "${PrevThemeIde}" != "${thmChsh}" ]]; then
            setConf "PrevThemeIde" "${thmChsh}" "${scrDir}/globalcontrol.sh" 
        fi
        if [[ "${wallDir}" != "${ideDir}/theme/${1}/wallpapers" ]]; then
            setConf "wallDir" "\${XDG_CONFIG_HOME:-\$HOME/.config}/ivy-shell/theme/${thmChsh}/wallpapers" "${ideDir}/ide.conf"
        fi
        if [[ "${enableWallIde}" -eq 3 ]]; then
            if [[ "${ideTheme}" != "${thmChsh}" ]]; then
                setConf "ideTheme" "$1" "${ideDir}/ide.conf"
            fi
            sed -Ei 's|^[[:space:]]*source[[:space:]]*=[[:space:]]*./themes/wallbash-ide.conf|#source = ./themes/wallbash-ide.conf|' "${confDir}/hypr/hyprland.conf"
        else
            "${scrDir}/modules/ivyshell-helper.sh" "${themeDir}/${thmChsh}/hypr.theme"
#            cp "${themeDir}/${thmChsh}/hypr.theme" "${confDir}/hypr/themes/theme.conf"
            sed -Ei 's|^#[[:space:]]*source[[:space:]]*=[[:space:]]*./themes/wallbash-ide.conf|source = ./themes/wallbash-ide.conf|' "${confDir}/hypr/hyprland.conf"
        fi
    
        [[ ! -e "${scrDir}/wbselecgen.sh" ]] && notify -m 1 -p "Does wbselecgen.sh exist?" -s "${swayncDir}/icons/palette.png" && return 1
        "${scrDir}/wbselecgen.sh" -i "${thmImg}" -w --swww-t 
    fi
}

# ────────────────────────────────────────────────
# Rofi Settings
rSettings() {
    [[ -z "${rofiScale}" ]] && rofiScale=10 || rofiScale="${rofiScale}"
    r_scale="configuration {font : \"JetBrainsMono Nerd Font ${rofiScale}\";}"
    mon_x_res=$(( mon_res * 100 / mon_scale ))
    elem_border=$(( hypr_border * 3 ))
    icon_border=$(( elem_border - 5 ))

    elm_width=$(( (23 + 12 + 1) * rofiScale * 2 ))
    max_avail=$(( mon_x_res - (4 * rofiScale) ))
    col_count=$(( max_avail / elm_width ))
    r_override="window{width:100%;} listview{columns:${col_count};} element{border-radius:${elem_border}px;padding:0.5em;} element-icon{size:23em;border-radius:${icon_border}px;}"
}

# ────────────────────────────────────────────────
thmSelEnv() {
    mapfile -t themes < <(LC_ALL=C find "${themeDir}" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort -Vf)

    menu() {
        selectC=0
        for indx in "${themes[@]}"; do
            wallSet="${themeDir}/${indx}/wall.set"
            printf "%s\x00icon\x1f%s\n" "${indx}" "${wallSet}"
        done
    }
    rSettings
    choice=$(menu | rofi -dmenu -i -p "ThemeControl" -theme-str "${r_scale}" -theme-str "${r_override}" -config "${rofiConf}" -select "${selectC}")
    [[ -z "$choice" ]] && exit 0
    themeSelTui "$choice"
}

[[ -z "${1}" ]] && thmSelEnv || themeSelTui "$1"

