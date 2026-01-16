#!/usr/bin/env bash
set -euo pipefail
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalvariable.sh"

pxCheck="${1:-}"
wallDir="${homDir}/Pictures/wallpapers"

swww-prefix() {
    local walRasi="${cacheDir}/ivy-shell/blurred/current_wallpaper.rasi"
    local wpex filterPath extract_wall wall_i pxCheck dirflag
   
    pxCheck="${1:-}"
    wpex=$(grep -oE '"/[^"]+"' "$walRasi") || return 1
    fillPath="${wpex#\"}"
    fillPath="${fillPath%\"}"
    extract_wall="${fillPath##*/}"
    wall="${extract_wall}"

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
    
    export rand="$wallDir/${wallpapers[$idx]}"
    if [[ "$dirFlag" -eq 0 ]]; then
        ${scrDir}/wbselecgen.sh "${rand}" --swww-p
    else
        ${scrDir}/wbselecgen.sh "${rand}" --swww-n
    fi
}

render() {
    rmDir=$(find "$wallDir" -maxdepth 1 -type f | shuf -n 1)
    ${scrDir}/wbselecgen.sh "$rmDir"
}

case "$pxCheck" in
    -p|--previous) 
        swww-prefix --p 
        ;;
    -n|--next)
        swww-prefix --n
        ;;
    -r|--random)
        render
        ;;
    *)
        echo -e "Invalid '$pxCheck' for argument. Correct arguments are: -p (--previous), -n (--next), -r (--random)"
        exit 0
esac

