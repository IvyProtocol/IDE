#!/usr/bin/env bash
set -eo pipefail

scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"

themeDir="${ideDir}/theme"
rofiConf="${rasiDir}/selector.rasi"

themeSelTui() {
    thmChsh="${1}"
    thmImg="$(<"${themeDir}/${thmChsh}/wallpapers/.wallbash-main")"
    if [[ -n "${thmImg}" ]]; then
        if [[ "${PrevThemeIde}" != "${thmChsh}" ]]; then
            setConf "PrevThemeIde" "${thmChsh}" "${scrDir}/globalcontrol.sh" 
        fi
        if [[ "${wallDir}" != "${themeDir}/${thmChsh}/wallpapers" ]]; then
            echo " :: Theme Control - Theme '${thmChsh}' :: Wallpaper '${thmImg}' :: DcolMode '${enableWallIde}' --> '${confDir}'"
            notify -m 2 -i "theme_engine" -p "${thmChsh}" -s "${ideCDir}/cache/thumb/$(fl_wallpaper -t "${thmImg}" -f 1).sloc" -t 1100 -a "t1"
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
        "${scrDir}/wbselecgen.sh" -t -i "${thmImg}" -w --swww-t -n 1 -r 1
        echo -e " :: Theme Control - Populated successfully ${thmChsh} -> ${confDir}"
    fi
}

thmSelEnv() {
    if [[ -z "${rofiScale}" || "${rofiScale}" -eq 0 ]]; then
        rofiScale=10
    fi
    r_scale="configuration {font : \"JetBrainsMono Nerd Font ${rofiScale}\";}"
    mon_x_res=$(( mon_res * 100 / mon_scale ))
    elem_border=$(( hypr_border * 3 ))
    icon_border=$(( elem_border - 5 ))
    local indx themes wallSet thumbDir thmExtn thmWall stripWall

    case "${themeRofiStyle}" in
        2)
            elm_width=$(( (20 + 12 ) * rofiScale * 2 ))
            max_avail=$(( mon_x_res - ( 4 * rofiScale) ))
            if [[ "${rofiColCount}" -eq 0 || -z "${rofiColCount}" ]]; then
                rofiColCount=$(( max_avail / elm_width ))
            fi
            r_override="window{width:100%;background-color:#00000003;} listview{columns:${rofiColCount};} element{border-radius:${elem_border}px;background-color:@main-bg;} element-icon{size:20em;border-radius:${icon_border}px 0px 0px ${icon_border}px;}"
            thmExtn="quad"
            thumbDir="${ideCDir}/cache/quad"
            ;;
        1|*)
            elm_width=$(( (23 + 12 + 1) * rofiScale * 2 ))
            max_avail=$(( mon_x_res - (4 * rofiScale) ))
            if [[ "${rofiColCount}" -eq 0 || -z "${rofiColCount}" ]]; then
                rofiColCount=$(( max_avail / elm_width ))
            fi
            r_override="window{width:100%;} listview{columns:${rofiColCount};} element{border-radius:${elem_border}px;padding:0.5em;} element-icon{size:23em;border-radius:${icon_border}px;}"
            thmExtn="sloc"
            thumbDir="${ideCDir}/cache/thumb"
            ;;
    esac
    mapfile -t themes < <(LC_ALL=C find "${themeDir}" -mindepth 1 -maxdepth 1 -type d ! -name 'Wallbash-Ivy' -printf '%f\n' | sort -Vf)
    menu() {
        for indx in "${themes[@]}"; do
            wallSet="${themeDir}/${indx}/wall.set"
            symUpdate=0
                if [[ ! -e "${themeDir}/${indx}/wallpapers/.wallbash-main" ]]; then
                    thmWall=$(find "${themeDir}/${indx}/wallpapers" -type f ! -name '.*' | sort -V | head -n 1 | tee -a "${themeDir}/${indx}/wallpapers/.wallbash-main")
                else
                    thmWall="$(<"${themeDir}/${indx}/wallpapers/.wallbash-main")"
                fi
                thmWall="$(fl_wallpaper -t "${thmWall}" -f 1).${thmExtn}"

                relpath="$(readlink -f "${wallSet}" 2>/dev/null || true)"
                stripPath="${relpath##*.}"

                if [[ ! -L "${wallSet}" || -L "${wallSet}" && ! -e "${wallSet}" || "${stripPath}" != "${thmExtn}" || -z "${relpath}"  ]]; then
                    ln -fs "${thumbDir}/${thmWall}" "${wallSet}"
                fi

            printf "%s\x00icon\x1f%s\n" "${indx}" "${wallSet}"
        done
    }
    choice=$(menu | rofi -dmenu -i -p "ThemeControl" -theme-str "${r_scale}" -theme-str "${r_override}" -config "${rofiConf}" -select "${PrevThemeIde}")
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
