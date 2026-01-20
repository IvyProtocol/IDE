#!/usr/bin/env bash
set -euo pipefail
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalvariable.sh"

pxCheck="${1:-}"
wallDir="${homDir}/Pictures/wallpapers"

swww-prefix() {
    local walRasi="${cacheDir}/ivy-shell/cache.rasi"
    local wall wall_i pxCheck dirflag
   
    pxCheck="${1:-}"
    wall=$(fl_wallpaper)

    [[ -n "${wall}" ]] || return 1

    mapfile -t wallpapers < <( LC_ALL=C find "$wallDir" -maxdepth 1 -type f -printf '%f\n' | sort -V )

    wall_i=-1
    for i in "${!wallpapers[@]}"; do
        [[ "${wallpapers[$i]}" == "${wall}" ]] && wall_i=$i
    done

    total=${#wallpapers[@]}
    case "$pxCheck" in
        --p) idx=$(( (wall_i - 1 + total) % total )); dirFlag=0 ;;
        --n) idx=$(( (wall_i + 1) % total )); dirFlag=1 ;;
        *) return 1 ;;
    esac
    
    rand="$wallDir/${wallpapers[$idx]}"
    if [[ "$dirFlag" -eq 0 ]]; then
        ${scrDir}/wbselecgen.sh -i "${rand}" -w --swww-p
    else
        ${scrDir}/wbselecgen.sh -i "${rand}" -w --swww-n
    fi
}

render() {
    rmDir=$(find "$wallDir" -maxdepth 1 -type f | shuf -n 1)
    ${scrDir}/wbselecgen.sh -i "$rmDir"
}

case "$pxCheck" in
    -p|--previous) 
        swww-prefix --p 
