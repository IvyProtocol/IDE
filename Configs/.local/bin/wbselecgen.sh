#!/usr/bin/env bash
set -eo pipefail

# ────────────────────────────────────────────────
# Configuration
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalvariable.sh"

wallDir="${homDir}/Pictures/wallpapers"
cacheDir="${ideCDir}/cache"
blurDir="${cacheDir}/blur"
rofiConf="${rasiDir}/config-wallpaper.rasi"
wallFramerate="60"
wallTransDuration="0.4"

[[ -d "${blurDir}" ]] || mkdir -p "${blurDir}"
[[ -d "${cacheDir}" ]] || mkdir -p "${cacheDir}"

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
    if [ -z "$img" ] || [ ! -f "$img" ]; then
        img=$(fl_wallpaper -r)
        img="${wallDir}/$img"
        [[ ! -f "$img" ]] && notify-send "Invalid wallpaper" "File not found: $img" && exit 1
    fi

    local base blurred rasifile argfv
    base="$(basename "$img")"
    img="${img}"
    blurred="${blurDir}/${base%.*}.png"
    rasifile="${ideCDir}/cache.rasi"
    argfv=$(awk -F'"' 'NR==2 {print $2}' "$rasifile")

    case "$ntSend" in
        --s) ntSend=1 ;;
        *)   ntSend=0 ;;
    esac

    log "Applying wallpaper: $img"
    [[ "$ntSend" -eq 0 ]] && notify "Using Theme Engine: " "${swayncDir}/icons/palette.png"

    if [[ -z "${schIPC}" ]]; then
        if [[ "${argfv}" == "dark" ]]; then
            "${scrDir}/ivy-shell.sh" "$img" -d
        elif [[ "${argfv}" == "light" ]]; then
            "${scrDir}/ivy-shell.sh" "$img" -l

        elif [[ "${argfv}" == "auto" || ! -e "${rasiDir}" || -z "${argfv}" ]]; then
            "${scrDir}/ivy-shell.sh" "$img" -a

        fi
    elif [[ -n "${schIPC}" ]]; then
        case "${schIPC}" in
            --dark|-d)  "${scrDir}/ivy-shell.sh" "${img}" -d ;;
            --light|-l) "${scrDir}/ivy-shell.sh" "${img}" -l ;;
            --auto|-a)  "${scrDir}/ivy-shell.sh" "${img}" -a ;;
        esac
    fi

    case $swi in
        --swww-p) swww img "$img" -t "outer" --transition-bezier .43,1.19,1,.4 --transition-duration $wallTransDuration --transition-fps $wallFramerate --invert-y  --transition-pos "$(hyprctl cursorpos | grep -E '^[0-9]' || echo "0,0")" ;;
        --swww-n) swww img "$img" -t "grow" --transition-bezier .43,1.19,1,.4 --transition-duration $wallTransDuration --transition-fps $wallFramerate --invert-y --transition-pos "$(hyprctl cursorpos | grep -E '^[0-9]' || echo "0,0")" ;;
        *)        swww img "$img" -t "any" --transition-bezier .43,1.19,1,.4 --transition-duration $wallTransDuration --transition-fps $wallFramerate --invert-y ;;
    esac

    [[ ! -f "${blurred}" ]] && log "Creating blurry wallpaper" && {
        "${scrDir}/swwwallcache.sh" -b "${img}"
    }

    if [[ ! -f $rasifile ]]; then
        echo "current-image=\"$img\"" > "$rasifile" 
    else
        sed -i "s|^current-image=.*|current-image=\"$img\"|" "$rasifile"
    fi

    {
        scRun=$(fl_wallpaper -t "${img}" -f 1)
        cp "$blurred" "${confDir}/wlogout/wallpaper_blurred.png" 
        cp "${cacheDir}/thumb/thumb-${scRun}.png" "${rasiDir}/current-wallpaper.png" 
        cp "${blurred}" "/usr/share/sddm/themes/silent/backgrounds/default.jpg"
    } >/dev/null 2>&1 

    [[ "$ntSend" -eq 0 ]] && notify "Wallpaper Theme applied" "$img"
}

# ────────────────────────────────────────────────
# Interactive wallpaper picker
choose_wallpaper() {
    mapfile -d '' files < <(find "${wallDir}" -type f \( -iname "*.jpg" -o -iname "*.png" -o  -iname "*.gif"  -o -iname "*.jpeg" \) -print0)

    menu() {
        for f in "${files[@]}"; do
            name=$(basename "$f")
            thumb="$cacheDir/thumb/thumb-${name%.*}.png"
            [[ ! -f "$thumb" ]] && "${scrDir}/swwwallcache.sh" -w "$f" >/dev/null 2>&1
            printf "%s\x00icon\x1f%s\n" "$name" "$thumb"
        done
    }

    choice=$(menu | rofi -dmenu -i -p "Wallpaper" -config "$rofiConf" -theme-str 'element-icon{size:33%;}')
    [ -z "$choice" ] && exit 0
    apply_wallpaper -i "${wallDir}/$choice"
}

# ────────────────────────────────────────────────
# Main
if [ -n "$1" ]; then
    apply_wallpaper "$@"
else
    choose_wallpaper
fi


