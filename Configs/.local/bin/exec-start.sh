#!/usr/bin/env bash
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"

flag="${ideCDir}/done"

if ! pgrep -x "swww-daemon" >/dev/null; then
  swww-daemon &
fi
if [[ ! -e "$flag" ]]; then
  "${scrDir}/wbselecgen.sh" -i "${homDir}/Pictures/wallpapers/1_rain_world.png" -n --s -w --swww-n >/dev/null 2>&1
  touch "$flag"
fi
