#!/usr/bin/env bash
set -eo pipefail

# ────────────────────────────────────────────────
# Configuration
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"

themeDir="${ideDir}/theme"
rofiConf="${rasiDir}/selector.rasi"

# ────────────────────────────────────────────────
themeSelTui() {
    thmChsh="${1}"
    if [[ ! -f "${themeDir}/${thmChsh}/wallpapers/.wallbash-main" ]]; then
        find "${themeDir}/${thmChsh}/wallpapers" -mindepth 1 -maxdepth 1 -type f | shuf -n 1 | tee "${themeDir}/${thmChsh}/wallpapers/.wallbash-main" >/dev/null 
    fi
    thmImg="$(<"${themeDir}/${thmChsh}/wallpapers/.wallbash-main")"
    if [[ -n "${thmImg}" ]]; then
        if [[ "${PrevThemeIde}" != "${thmChsh}" ]]; then
            setConf "PrevThemeIde" "${thmChsh}" "${scrDir}/globalcontrol.sh" 
        fi
        if [[ "${wallDir}" != "${themeDir}/${thmChsh}/wallpapers" ]]; then
            echo " :: Theme Control - Theme '${thmChsh}' :: Wallpaper '${thmImg}' :: DcolMode '${enableWallIde}' --> '${confDir}'"
            notify -m 2 -i "theme_engine" -p "Theme Selected: ${thmChsh}" -s "${themeDir}/${thmChsh}/wall.set" -t 1100 -a "t1"
            setConf "wallDir" "\${XDG_CONFIG_HOME:-\$HOME/.config}/ivy-shell/theme/${thmChsh}/wallpapers" "${ideDir}/ide.conf"
        else
            echo -e " :: Theme Control - Skipped populating $thmChsh -> ${confDir}"
            exit 0
        fi
        if [[ "${enableWallIde}" -eq 3 ]]; then
            if [[ "${ideTheme}" != "${thmChsh}" ]]; then
                setConf "ideTheme" "${thmChsh}" "${ideDir}/ide.conf"
            fi
            sed -Ei 's|^[[:space:]]*source[[:space:]]*=[[:space:]]*./themes/wallbash-ide.conf|#source = ./themes/wallbash-ide.conf|' "${confDir}/hypr/hyprland.conf"
        else
            "${scrDir}/modules/ivyshell-helper.sh" "${themeDir}/${thmChsh}/hypr.theme"
             sed -Ei 's|^#[[:space:]]*source[[:space:]]*=[[:space:]]*./themes/wallbash-ide.conf|source = ./themes/wallbash-ide.conf|' "${confDir}/hypr/hyprland.conf"
        fi
    
        [[ ! -e "${scrDir}/wbselecgen.sh" ]] && notify -m 1 -p "Does wbselecgen.sh exist?" -s "${swayncDir}/icons/palette.png" && return 1
        "${scrDir}/wbselecgen.sh" -i "${thmImg}" -w --swww-t -n 1
        echo -e " :: Theme Control - Populated successfully ${thmChsh} -> ${confDir}"
    fi
}

# ────────────────────────────────────────────────
# Rofi Settings
thmSelEnv() {
    if [[ -z "${rofiScale}" || "${rofiScale}" -eq 0 ]]; then
        rofiScale=10
    fi
    r_scale="configuration {font : \"JetBrainsMono Nerd Font ${rofiScale}\";}"
    mon_x_res=$(( mon_res * 100 / mon_scale ))
    elem_border=$(( hypr_border * 3 ))
    icon_border=$(( elem_border - 5 ))

    elm_width=$(( (23 + 12 + 1) * rofiScale * 2 ))
    max_avail=$(( mon_x_res - (4 * rofiScale) ))
    if [[ "${rofiColCount}" -eq 0 || -z "${rofiColCount}" ]]; then
        rofiColCount=$(( max_avail / elm_width ))
    fi
    r_override="window{width:100%;} listview{columns:${rofiColCount};} element{border-radius:${elem_border}px;padding:0.5em;} element-icon{size:23em;border-radius:${icon_border}px;}"

    local indx selectC themes wallSet
    mapfile -t themes < <(LC_ALL=C find "${themeDir}" -mindepth 1 -maxdepth 1 -type d ! -name 'Wallbash-Ivy' -printf '%f\n' | sort -Vf)
    menu() {
        selectC=0
        for indx in "${themes[@]}"; do
            wallSet="${themeDir}/${indx}/wall.set"
            printf "%s\x00icon\x1f%s\n" "${indx}" "${wallSet}"
        done
    }
    choice=$(menu | rofi -dmenu -i -p "ThemeControl" -theme-str "${r_scale}" -theme-str "${r_override}" -config "${rofiConf}" -select "${selectC}")
    [[ -z "$choice" ]] && exit 0
    themeSelTui "$choice"
}

theme_control() {
    local thm_i thmCheck thmFlags themes thmTotal thmFinal
    thmCheck="${1:-}"

    [[ -n "${PrevThemeIde}" ]] || return 1
    mapfile -t themes < <(LC_ALL=C find "${themeDir}" -mindepth 1 -maxdepth 1 -type d ! -name 'Wallbash-Ivy' -printf '%f\n' | sort -Vf )
    thm_i=-1
    for i in "${!themes[@]}"; do
        [[ "${themes[$i]}" == "${PrevThemeIde}" ]] && thm_i=$i
    done

    thmTotal="${#themes[@]}"
    case "${thmCheck}" in
     --p) idx=$(( (thm_i - 1 + thmTotal) % thmTotal )) ;;
     --n) idx=$(( (thm_i + 1) % thmTotal )) ;;
     *)
         return 1 
         ;;
    esac
    themeSelTui "${themes[$idx]}"
}

case "${1}" in
    -n)
        theme_control --n 
        ;;
    -p)
        theme_control --p
        ;;
    -t)
        themeSelTui "$2"
        ;;
    *)
        thmSelEnv
        ;;
esac


