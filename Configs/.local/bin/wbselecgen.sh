#!/usr/bin/env bash
set -eo pipefail

# ────────────────────────────────────────────────
# Configuration
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

log() { echo "[$0] "$@""; }

# ────────────────────────────────────────────────
# Apply wallpaper + blur + cache + color sync
apply_wallpaper() {
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
        [[ ! -f "$img" ]] && notify -m 1 -p "Invalid wallpaper?" && exit 1
    fi

    local base blurred rasifile
    base="$(basename "$img")"
    img="${img}"
    blurred="${blurDir}/${base%.*}.bpex"
    echo "$img" > "${ideDir}/theme/${PrevThemeIde}/wallpapers/.wallbash.main" 

    case "${ntSend}" in
        1)
            ntSend=1
            ;;
        0|*)
            ntSend=0
            ;;
    esac

    log "Applying wallpaper: $img"
    [[ "$ntSend" -eq 0 ]] && notify -m 2 -i "theme_engine"  -p "Using Theme Engine: " -s "${swayncDir}/icons/palette.png"

    case "${schIPC}" in
        dark|light|auto) 
            "${scrDir}/ivy-shell.sh" -i "${img}" -c "${schIPC}"
            ;;
        theme|*)
            if [[ "${enableWallIde}" -eq 3 && "${dcolMode}" == "theme" ]]; then
                read -r hashMech <<< $(hashmap -v -t "${img}" | awk -F '"' '{print $2}')
                if [[ -f "${dcolDir}/auto/ivy-${hashMech}.dcol" ]]; then
                    cp "${dcolDir}/auto/ivy-${hashMech}.dcol" "${ideDir}/main/ivygen.dcol"
                    "${scrDir}/modules/ivyshell-theme.sh" && "${scrDir}/modules/ivyshell-helper.sh"
                else
                    "${scrDir}/ivy-shell.sh" -i "$img"
                fi
            else
                "${scrDir}/ivy-shell.sh" -i "$img" -c "${dcolMode}"
            fi
            ;;
    esac
    
    case $swi in
        --swww-p) swww img "$img" -t "${wallAnimationPrevious}" --transition-bezier "${wallTransitionBezier}" --transition-duration "${wallTransDuration}" --transition-fps "${wallFramerate}" --invert-y  --transition-pos "$(hyprctl cursorpos | grep -E '^[0-9]' || echo "0,0")" ;;
        --swww-n) swww img "$img" -t "${wallAnimationNext}" --transition-bezier "${wallTransitionBezier}" --transition-duration "${wallTransDuration}" --transition-fps "${wallFramerate}" --invert-y --transition-pos "$(hyprctl cursorpos | grep -E '^[0-9]' || echo "0,0")" ;;
        --swww-t) swww img "$img" -t "${wallAnimationTheme}" --transition-bezier "${wallTransitionBezier}" --transition-duration "${wallTransDuration}" --transition-fps "${wallFramerate}" --invert-y --transition-pos "$(hyprctl cursorpos | grep -E '^[0-9]' || echo "0,0")" & ;;
        *)        swww img "$img" -t "${wallAnimation}" --transition-bezier "${wallTransitionBezier}" --transition-duration "${wallTransDuration}" --transition-fps "${wallFramerate}" --invert-y & ;;
    esac

    scRun=$(fl_wallpaper -t "${img}" -f 1)
    if [[ "$(find "${blurDir}" -maxdepth 0 -empty)" || "$(find "${colsDir}" -maxdepth 0 -empty)" || "$(find "${thumbDir}" -maxdepth 0 -empty)" ]]; then
        log "Creating blurry wallpaper and caching"
        "${scrDir}/swwwallcache.sh" -b "${img}"
    fi
    
    setConf "wallSet" "${wallSel}/$(fl_wallpaper -t $img)" "${ideDir}/ide.conf" 

    ln -sf "$blurred" "${confDir}/wlogout/wallpaper_blurred.png" 
    ln -sf "${colsDir}/${scRun}.cols" "${rasiDir}/current-wallpaper.png" 
    cp "${blurred}" "/usr/share/sddm/themes/silent/backgrounds/default.jpg" 
    cp "${thumbDir}/${scRun}.sloc" "${ideDir}/theme/${PrevThemeIde}/wall.set"
    [[ "$ntSend" -eq 0 ]] && notify -m 2 -i "theme_engine" -p "Wallpaper Theme applied" -s "$img"
}

# ────────────────────────────────────────────────
# Rofi Settings
expV() {
    [[ -z "${rofiScale}" ]] && rofiScale=10 || rofiScale="${rofiScale}"
    r_scale="configuration {font : \"JetBrainsMono Nerd Font ${rofiScale}\";}"
    elem_border=$(( hypr_border * 3 ))

    mon_x_res=$(( mon_res * 100 / mon_scale ))
    elm_width=$(( (28 + 8 + 5) * rofiScale ))
    max_avail=$(( mon_x_res - (4 * rofiScale) ))
    col_count=$(( max_avail / elm_width ))
    r_override="window{width:100%;} listview{columns:${col_count};spacing:5em;} element{border-radius:${elem_border}px;orientation:vertical;} element-icon{size:28em;border-radius:0em;} element-text{padding:1em;}"
}

# ────────────────────────────────────────────────
# Interactive wallpaper picker
choose_wallpaper() {
    mapfile -d '' files < <(LC_ALL=C find "${wallSel}" "${WallAddCustomPath[@]}" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) -print0 | sort -Vzf)
    menu() {
        selectC=0
        for f in "${files[@]}"; do
            name=$(basename "$f")
            thumb="${thumbDir}/${name%.*}.sloc"
            cols="${colsDir}/${name%.*}.cols"
            blur="${blurDir}/${name%.*}.bpex"
            [[ ! -f "$thumb" || ! -f "$cols" || ! -f "$blur" ]] && "${scrDir}/swwwallcache.sh" -f "$f"
            printf "%s\x00icon\x1f%s\n" "$name" "$thumb" 
        done
    }
    expV
    choice=$(menu | rofi -dmenu -i -p "Wallpaper" -theme-str "${r_scale}" -theme-str "${r_override}" -config "${rofiConf}" -selected-row "${selectC}")
    [[ -z "$choice" ]] && exit 0
    apply_wallpaper -i "${wallSel}/$choice"
}

# ────────────────────────────────────────────────
# Main
if [ -n "$1" ]; then
    apply_wallpaper "$@"
else
    choose_wallpaper
fi
