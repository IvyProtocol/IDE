#!/usr/bin/env bash
set -eo pipefail

scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"

wallSel="${wallDir}"
cacheDir="${ideCDir}/cache"
blurDir="${cacheDir}/blur"
colsDir="${cacheDir}/cols"
thumbDir="${cacheDir}/thumb"
rofiConf="${rasiDir}/selector.rasi"

[[ -d "${blurDir}" ]] || mkdir -p "${blurDir}"
[[ -d "${cacheDir}" ]] || mkdir -p "${cacheDir}"
[[ -d "${colsDir}" ]] || mkdir -p "${colsDir}"
[[ -d "${thumbDir}" ]] || mkdir -p "${thumbDir}"

wallSelTui() {
   OPTIND=1
   local img="" schIPC="" swi="" ntSend=""
   while getopts ":i:s:w:n:" arg; do
       case "$arg" in
           i)    img="$OPTARG"    ;;
           s) schIPC="$OPTARG"    ;;
           w)    swi="$OPTARG"    ;;
           n) ntSend="$OPTARG"    ;;
       esac
   done

    shift $((OPTIND -1))
    if [[ -z "$img" || ! -f "$img" ]]; then
        img=$(fl_wallpaper -r)
        img="${wallDir}/$img"
        [[ ! -f "$img" ]] && notify -m 1 -p "Invalid wallpaper?" -t 900 -a "t1" && exit 1
    fi

    local base blurred
    base="$(basename "$img")"
    img="${img}"
    blurred="${blurDir}/${base%.*}.bpex"
    echo "$img" > "${ideDir}/theme/${PrevThemeIde}/wallpapers/.wallbash-main" 

    case "${ntSend}" in
        1)
            ntSend=1
            ;;
        0|*)
            ntSend=0
            ;;
    esac

    echo -e " :: Theme Control - [$0] - Wallpaper Control - Applying $img"
    [[ "$ntSend" -eq 0 ]] && notify -m 2 -i "theme_engine"  -p "Using Theme Engine: " -s "${confDir}/dunst/icons/hyprdots.svg" -a "t1"
    scRun=$(fl_wallpaper -t "${img}" -f 1)
    
    {
        if [[ "$(find "${blurDir}" -maxdepth 0 -empty)" || "$(find "${colsDir}" -maxdepth 0 -empty)" || "$(find "${thumbDir}" -maxdepth 0 -empty)" ]]; then
            echo -e " :: Re-populating cache for ${img}"
            "${scrDir}/swwwallcache.sh" -b "${img}"
        fi
    
        setConf "wallSet" "${wallSel}/$(fl_wallpaper -t $img)" "${ideDir}/ide.conf" 

        ln -sf "$blurred" "${confDir}/wlogout/wallpaper_blurred.png" 
        ln -sf "${colsDir}/${scRun}.cols" "${rasiDir}/current-wallpaper.png" 
        cp "${blurred}" "/usr/share/sddm/themes/silent/backgrounds/default.jpg" 
        ln -sf "${thumbDir}/${scRun}.sloc" "${ideDir}/theme/${PrevThemeIde}/wall.set"
    } &

    case $swi in
        --swww-p) swww img "$img" -t "${wallAnimationPrevious}" --transition-bezier "${wallTransitionBezier}" --transition-duration "${wallTransDuration}" --transition-step "${wallTransitionStep}" --transition-fps "${wallFramerate}" --invert-y  --transition-pos "$(hyprctl cursorpos | grep -E '^[0-9]' || echo "0,0")" ;;
        --swww-n) swww img "$img" -t "${wallAnimationNext}" --transition-bezier "${wallTransitionBezier}" --transition-duration "${wallTransDuration}" --transition-step "${wallTransitionStep}" --transition-fps "${wallFramerate}" --invert-y --transition-pos "$(hyprctl cursorpos | grep -E '^[0-9]' || echo "0,0")" ;;
        --swww-t) swww img "$img" -t "${wallAnimationTheme}" --transition-bezier "${wallTransitionBezier}" --transition-duration "${wallTransDuration}" --transition-step "${wallTransitionStep}" --transition-fps "${wallFramerate}" --invert-y --transition-pos "$(hyprctl cursorpos | grep -E '^[0-9]' || echo "0,0")" ;;
        *)        swww img "$img" -t "${wallAnimation}" --transition-bezier "${wallTransitionBezier}" --transition-duration "${wallTransDuration}" --transition-step "${wallTransitionStep}" --transition-fps "${wallFramerate}" --invert-y  ;;
    esac
    sleep "${wallTransDuration}"
    case "${schIPC}" in
        dark|light) 
            "${scrDir}/ivy-shell.sh" "${img}" --"${schIPC}"
            ;;
        auto)
            "${scrDir}/ivy-shell.sh" "${img}"
            ;;
        theme|*)
            if [[ "${enableWallIde}" -eq 3 && "${dcolMode}" == "theme" ]]; then
                read -r hashMech <<< $(hashmap -v -t "${img}" | awk -F '"' '{print $2}')
                if [[ -f "${dcolDir}/auto/ivy-${hashMech}.dcol" ]]; then
                    cp "${dcolDir}/auto/ivy-${hashMech}.dcol" "${ideDir}/main/ivygen.dcol"
                    "${scrDir}/modules/ivyshell-theme.sh" && "${scrDir}/modules/ivyshell-helper.sh"
                else
                    "${scrDir}/ivy-shell.sh" "$img"
                fi
            else
                "${scrDir}/ivy-shell.sh" "$img" --"${dcolMode}"
            fi
            ;;
    esac

    [[ "$ntSend" -eq 0 ]] && notify -m 2 -i "theme_engine" -p "Wallpaper Theme applied" -s "${ideDir}/theme/${PrevThemeIde}/wall.set" -t 900 -a "t1"
}

wallSelEnv() {
    if [[ -z "${rofiScale}" || "${rofiScale}" -eq 0 ]]; then
        rofiScale=10
    fi
    r_scale="configuration {font : \"JetBrainsMono Nerd Font ${rofiScale}\";}"
    elem_border=$(( hypr_border * 3 ))

    mon_x_res=$(( mon_res * 100 / mon_scale ))
    elm_width=$(( (28 + 8 + 5) * rofiScale ))
    max_avail=$(( mon_x_res - (4 * rofiScale) ))
    if [[ "${rofiColCount}" -eq 0 || -z "${rofiColCount}" ]]; then
        rofiColCount=$(( max_avail / elm_width ))
    fi
    r_override="window{width:100%;} listview{columns:${rofiColCount};spacing:5em;} element{border-radius:${elem_border}px;orientation:vertical;} element-icon{size:28em;border-radius:0em;} element-text{padding:1em;}"

    local indx files thumb cols blur name
    mapfile -d '' files < <(LC_ALL=C find "${wallSel}" "${WallAddCustomPath[@]}" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.jpeg" \) -print0 | sort -Vzf)
    menu() {
        for indx in "${files[@]}"; do
            name=$(basename "$indx")
            thumb="${thumbDir}/${name%.*}.sloc"
            cols="${colsDir}/${name%.*}.cols"
            blur="${blurDir}/${name%.*}.bpex"
            [[ ! -f "$thumb" || ! -f "$cols" || ! -f "$blur" ]] && "${scrDir}/swwwallcache.sh" -f "$indx"
            printf "%s\x00icon\x1f%s\n" "$name" "$thumb" 
        done
    }
choice=$(menu | rofi -dmenu -i -p "Wallpaper" -theme-str "${r_scale}" -theme-str "${r_override}" -config "${rofiConf}" -select "$(fl_wallpaper -r)")
    [[ -z "$choice" ]] && exit 0
    wallSelTui -i "${wallSel}/$choice"
}

wall_control() {
    local wall wall_i wallCheck wallpapers wallTotal wallFinal swwwTrans
    wallCheck="${1:-}"
    wall="$(fl_wallpaper -r)"

    [[ -n "${wall}" ]] || return 1
    mapfile -t wallpapers < <(LC_ALL=C find "${wallDir}" -maxdepth 1 -mindepth 1 -type f ! -name '.*' -printf '%f\n' | sort -V)

    wall_i=-1
    for indx in "${!wallpapers[@]}"; do 
        [[ "${wallpapers[$indx]}" == "${wall}" ]] && wall_i=$indx
    done

    wallTotal=${#wallpapers[@]}
    case "${wallCheck}" in
        --p) 
            idx=$(( (wall_i - 1 + wallTotal) % wallTotal ));
            swwwTrans="--swww-p"
            ;;
        --n) 
            idx=$(( (wall_i + 1) % wallTotal ));
            swwwTrans="--swww-n"
            ;;
        *) return 1 ;;
    esac
    wallSelTui -i "${wallDir}/${wallpapers[$idx]}" -w "${swwwTrans}" -n 1
}

wallSelRandom() {
    random=$(find "${wallDir}" -maxdepth 1 -type f | shuf -n 1 )
    wallSelTui -i "${random}" -n 1
}

case "${1}" in
    -n)
        wall_control --n
        ;;
    -p)
        wall_control --p
        ;;
    -t)
        wallSelTui ${@}
        ;;
    -r)
        wallSelRandom 
        ;;
    *)
        wallSelEnv
        ;;
esac
