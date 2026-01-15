#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Clipboard Manager. This script uses cliphist, rofi, and wl-copy.
scrDir=$(dirname "$(realpath "$0")")

if [[ ! -f "${scrDir}/globalvariable.sh" ]]; then
    rasiDir="$HOME/.config/rofi/shared/"
else
    source "${scrDir}/globalvariable.sh"
fi

rasiScr="${rasiDir}/config-clipboard.rasi"
kbcus1="Control-Delete"
kbcus2="Alt-Delete"

if pkg_installed "rofi"; then
    if pidof rofi > /dev/null; then
        pkill rofi
    fi
else
    notify-send -p -e -u low " [IDE]" " Is rofi installed? exit-code 1."
    exit 1
fi

while true; do
    select=$(
        rofi -i -dmenu \
            -kb-custom-1 "$kbcus1" \
            -kb-custom-2 "$kbcus2" \
            -config "${rasiScr}" < <(cliphist list) 
    )

    case "$?" in
        1)
            exit
            ;;
        0)
            case "$select" in
                "")
                    continue
                    ;;
                *)
                    cliphist decode <<<"$select" | wl-copy
                    exit
                    ;;
            esac
            ;;
        10)
            cliphist delete <<<"$select"
            ;;
        11)
            cliphist wipe
            ;;
    esac
done

