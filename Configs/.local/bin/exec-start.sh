#!/usr/bin/env bash
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"

confDir="${cacheDir}/ivy-shell/"
flag="$confDir/done"

if ! pgrep -x "swww-daemon" >/dev/null; then
  swww-daemon &
fi
if [[ ! -e "$flag" ]]; then
  "${scrDir}/wbselecgen.sh" -t -i "${ideDir}/theme/${PrevThemeIde}/wallpapers/$(fl_wallpaper -r)" -n --s -w --swww-n >/dev/null 2>&1
  touch "$flag"
fi
