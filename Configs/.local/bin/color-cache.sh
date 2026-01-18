#!/usr/bin/env bash
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalvariable.sh"
wallDir="$HOME/Pictures/wallpapers"
ivygen_cDot="${cacheDir}/ivy-shell/shell"

[[ ! -d "$wallDir" ]] && exit 0

# Gather all wallpaper files
wallbash=("$wallDir"/*.jpg "$wallDir"/*.png "$wallDir"/*.gif "$wallDir"/*.jpeg)

# Filter only existing files
existing=()
for wp in "${wallbash[@]}"; do
    [[ -f "$wp" ]] && existing+=("$wp")
done

total_existing=${#existing[@]}
[[ $total_existing -eq 0 ]] && exit 0

# Identify uncached wallpapers
uncached=()
skipped_count=0
for wp in "${existing[@]}"; do
    ivyhash=$(md5sum "$wp" | awk '{print $1}')
    ivycache="${ivygen_cDot}/ivy-${ivyhash}.dcol"
    if [[ -f "$ivycache" ]]; then
        ((skipped_count++))
        continue
    fi
    uncached+=("$wp")
done

total_uncached=${#uncached[@]}
[[ $total_uncached -eq 0 ]] && echo "All wallpapers already cached. Skipped: $skipped_count." && exit 0

# Progress bar settings
BAR_WIDTH=50
count=0

pxcCheck="$1"
case "$pxcCheck" in
    -a)
        prefix="-a"
        ;;
    -d)
        prefix="-d"
        ;;
    -l)
        prefix="-l"
        ;;
    *)
        echo "Incorrect use of $0. The prefixes for $0 is '-a', 'd', '-l'."
        exit 1
        ;;
esac

# Process uncached wallpapers
for wp in "${uncached[@]}"; do
    ((count++))
    percent=$((count * 100 / total_uncached))
    filled=$((percent * BAR_WIDTH / 100))
    empty=$((BAR_WIDTH - filled))
    bar="$(printf '█%.0s' $(seq 1 $filled))$(printf ' %.0s' $(seq 1 $empty))"

    # Display progress
    printf "\rPopulating wallpapers: [%s] %3d%% (%d/%d) | Skipped: %d" \
           "$bar" "$percent" "$count" "$total_uncached" "$skipped_count"

    # Run ivy-shell.sh silently
    ${localDir}/bin/ivy-shell.sh "$wp" "$prefix" --helper=1 >/dev/null 2>&1
done

echo "Caching complete. Total processed: $total_uncached, Skipped: $skipped_count."

