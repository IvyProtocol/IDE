#!/usr/bin/env bash
set -eo pipefail

# ────────────────────────────────────────────────
# Configuration
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalvariable.sh"

WALL_DIR="${confDir}/../Pictures/wallpapers"
CACHE_DIR="${cacheDir}/ivy-shell/cache"
mkdir -p "$CACHE_DIR"
BLURRED_DIR="${cacheDir}/ivy-shell/blurred"
mkdir -p "$BLURRED_DIR"
ROFI_THEME="${rasiDir}/config-wallpaper.rasi"
wallFramerate="60"
wallTransDuration="0.4"
BLUR="50x30"

log() { echo "[$0] "$@""; }

# ────────────────────────────────────────────────
# Apply wallpaper + blur + cache + color sync
apply_wallpaper() {
   OPTIND=1
   local img="" schIPC="" swi=""

   while getopts ":i:s:w:" arg; do
       case "$arg" in
           i)    img="$OPTARG"    ;;
           s) schIPC="$OPTARG"    ;;
           w)    swi="$OPTARG"    ;;
       esac
   done

   shift $((OPTIND -1))
    if [ -z "$img" ] || [ ! -f "$img" ]; then
        img=$(fl_wallpaper)
        img="$WALL_DIR/$img"
        [[ ! -f "$img" ]] && notify-send "Invalid wallpaper" "File not found: $img" && exit 1
    fi

    local base="$(basename "$img")"
    local cached_img="$CACHE_DIR/$base"

    case "$img" in
        *.gif)
            if [ ! -f "$cached_img" ]; then
                cp "$img" "$cached_img"
            fi
            img="$cached_img"
            ;;
        *)
            img="$img"
            ;;
    esac

    local blurred="$BLURRED_DIR/blurred-${base%.*}.png"
    local rasifile="$CACHE_DIR/../cache.rasi"
    local argfv=$(awk -F'"' 'NR==2 {print $2}' "$rasifile")

    log "Applying wallpaper: $img"
    notify "Using Theme Engine: " "${swayncDir}/icons/palette.png"

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
        --swww-s) val="0" ;;
        *)        swww img "$img" -t "any" --transition-bezier .43,1.19,1,.4 --transition-duration $wallTransDuration --transition-fps $wallFramerate --invert-y ;;
    esac

    if [ ! -f "$blurred" ]; then
        log "Creating blurred wallpaper..."
        if [[ "$img" == *.gif ]]; then
            magick "$img[0]" -resize 75% "$blurred"
        else
            magick "$img" -resize 75% "$blurred"
        fi
        [ "$BLUR" != "0x0" ] && magick "$blurred" -blur "$BLUR" "$blurred"
    fi

    if [[ ! -f $rasifile ]]; then
        echo "current-image=\"$img\"" > "$rasifile" 
    else
        sed -i "s|^current-image=.*|current-image=\"$img\"|" "$rasifile"
    fi

    cp "$blurred" "${confDir}/wlogout/wallpaper_blurred.png" &
    if [[ "$img" = *.jpg ]]; then
        magick "$img" "${confDir}/rofi/shared/current-wallpaper.png" 
        cp "$blurred" "/usr/share/sddm/themes/silent/backgrounds/default.jpg" 
    elif [[ "$img" = *.gif ]]; then
        magick "$img[0]" "${confDir}/rofi/shared/current-wallpaper.png" 
        cp "$blurred" "/usr/share/sddm/themes/silent/backgrounds/default.jpg" 
    elif [[ "$img" = *.png ]]; then
        magick "$img" "${confDir}/rofi/shared/current-wallpaper.png" 
        cp "$blurred" "/usr/share/sddm/themes/silent/backgrounds/default.jpg" 
    fi >/dev/null 2>&1 &

    notify "Wallpaper Theme applied" "$img"
}

# ────────────────────────────────────────────────
# Interactive wallpaper picker
choose_wallpaper() {
    mapfile -d '' files < <(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) -print0)

    menu() {
        for f in "${files[@]}"; do
            name=$(basename "$f")
            thumb="$CACHE_DIR/thumb-${name%.*}.png"

            if [ ! -f "$thumb" ]; then
                case "$f" in
                    *.gif) magick "$f[0]" -resize 400x225 "$thumb" ;;  # first frame
                    *)     magick "$f" -resize 400x225 "$thumb" ;;
                esac
            fi

            printf "%s\x00icon\x1f%s\n" "$name" "$thumb"
        done
    }

    choice=$(menu | rofi -dmenu -i -p "Wallpaper" -config "$ROFI_THEME" -theme-str 'element-icon{size:33%;}')
    [ -z "$choice" ] && exit 0
    apply_wallpaper -i "$WALL_DIR/$choice"
}

# ────────────────────────────────────────────────
# Main
if [ -n "$1" ]; then
    apply_wallpaper "$@"
else
    choose_wallpaper
fi


