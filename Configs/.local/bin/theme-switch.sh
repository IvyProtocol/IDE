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
# Apply wallpaper + blur + cache + color sync
apply_wallpaper() {
    thmChsh="${1}"
    [[ "${themeIde}" == "${1}" ]] || setConf "themeIde" "${1}" "${scrDir}/globalcontrol.sh" 
    [[ "${wallDir}" == "${ideDir}/theme/${1}/wallpapers" ]] || setConf "wallDir" "\${XDG_CONFIG_HOME:-\$HOME/.config}/ivy-shell/theme/${1}/wallpapers" "${ideDir}/ide.conf"

    if [[ "${enableWallIde}" -eq 3 ]]; then
        [[ "${ideTheme}" == "$1" ]] && exit 0 || setConf "ideTheme" "$1" "${ideDir}/ide.conf"
        sed -i 's|^[[:space:]]*source[[:space:]]*=[[:space:]]*./themes/wallbash-ide.conf|#source = ./themes/wallbash-ide.conf|' "${confDir}/hypr/hyprland.conf"
    else
        sed -i 's|^#[[:space:]]*source[[:space:]]*=[[:space:]]*./themes/wallbash-ide.conf|source = ./themes/wallbash-ide.conf|' "${confDir}/hypr/hyprland.conf"
    fi

    if [[ ! -f "${ideDir}/theme/${themeIde}/wallpapers/.wallbash.main" ]]; then
        echo "${ideDir}/theme/${themeIde}/wallpapers/1_rain_world.png" > "${ideDir}/theme/${themeIde}/wallpapers/.wallbash.main" &
    fi
    img="$(cat "${ideDir}/theme/${1}/wallpapers/.wallbash.main")"

    [[ ! -e "${scrDir}/wbselecgen.sh" ]] && notify -m 1 -p "Does wbselecgen.sh exist?" -s d"${swayncDir}/icons/palette.png" || "${scrDir}/wbselecgen.sh" -i "${img}" -w --swww-t -n --s theme && exit 1
}

# ────────────────────────────────────────────────
# Rofi Settings
expV() {
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
# Interactive wallpaper picker
choose_wallpaper() {
    mapfile -t themes < <(LC_ALL=C find "${themeDir}" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort -Vf)

    menu() {
        selectC=0
        for indx in "${themes[@]}"; do
            wallSet="${themeDir}/${indx}/wall.set"

            printf "%s\x00icon\x1f%s\n" "${indx}" "${wallSet}"
        done
    }
    expV
    choice=$(menu | rofi -dmenu -i -p "ThemeControl" -theme-str "${r_scale}" -theme-str "${r_override}" -config "${rofiConf}" -select "${selectC}")
    [[ -z "$choice" ]] && exit 0
    apply_wallpaper "$choice"
}

# ────────────────────────────────────────────────
# Main
if [ -n "$1" ]; then
    apply_wallpaper "$@"
else
    choose_wallpaper
fi
