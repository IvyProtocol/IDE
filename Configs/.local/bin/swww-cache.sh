#!/usr/bin/env bash
set -euo pipefail
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalvariable.sh"

confDir="${cacheDir}/ivy-shell/"
flag="$confDir/done"

if ! pgrep -x "swww-daemon" >/dev/null; then
  swww-daemon &
fi

if [[ ! -f "$flag" ]]; then
  "${scrDir}/wbselecgen.sh" -i "${homDir}/Pictures/wallpapers/1_rain_world.png" -n --s -w --swww-n >/dev/null 2>&1
  touch "$flag"
fi
