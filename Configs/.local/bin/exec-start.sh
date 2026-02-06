#!/usr/bin/env bash
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"

confDir="${cacheDir}/ivy-shell/"
flag="$confDir/done"

if ! pgrep -x "swww-daemon" >/dev/null; then
  swww-daemon &
fi
if [[ ! -e "$flag" ]]; then
  "${scrDir}/wbselecgen.sh" -i "${homDir}/Pictures/wallpapers/1_rain_world.png" -n 1 -w --swww-n >/dev/null 2>&1
  touch "$flag"
fi
