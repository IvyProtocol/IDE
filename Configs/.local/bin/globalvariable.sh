#!/usr/bin/env bash
export homDir="${XDG_HOME:-$HOME}"
export confDir="${XDG_CONFIG_HOME:-${homDir}/.config}"
export localDir="${XDG_LOCAL_HOME:-${homDir}/.local}"
export cacheDir="${XDG_CACHE_HOME:-${homDir}/.cache}"
export swayncDir="${XDG_SWAYNC_ICON:-${confDir}/swaync}"
export rofiStyleDir="${XDG_RSDIR_HOME:-${confDir}/rofi}/styles"
export rofiAssetDir="${XDG_RADIR_HOME:-${confDir}/rofi/shared}/assets"
export rasiDir="${XDG_RTDIR_HOME:-${confDir}/rofi/shared}"
export wlDir="${XDG_WLDIR_HOME:-${confDir}/waybar/Styles}"
export wcDir="${XDG_WCDIR_HOME:-${confDir}/waybar/}"
export hyprscrDir="${XDG_WBSCRDIR_HOME:-${confDir}/hypr/scripts}"
export themeDir="${XDG_THEME_CONF:-${confDir}/ivy-shell}/themes"

pkg_installed() {
  local PkgIn=$1

  if pacman -Q "${PkgIn}" &>/dev/null; then
    return 0
  else
    return 1
  fi
}

pkg_available() {
  local PkgIn=$1
  if pacman -Ss "${PkgIn}" &>/dev/null; then
    return 0
  else
    return 1
  fi
}

fl_wallpaper() {
    local walRasi="${cacheDir}/ivy-shell/cache.rasi"
    local wpex fillpath extract_wall wall

    wpex=$(grep -oE '"/[^"]+"' "$walRasi") || return 1
    fillPath="${wpex#\"}"
    fillPath="${fillPath%\"}"
    extract_wall="${fillPath##*/}"
    wall="${extract_wall}"
    echo "$wall"
}

notify() {
  local notif_file notif_id swayIPath intOut
  
  notif_file="/tmp/.ivy_notif_id"
  notif_id=""
  intOut="$1"
  swayIPath="$2"

  [[ -f "$notif_file" ]] && notif_id=$(<"$notif_file")
  if [[ -n "$notif_id" ]]; then
    notify-send -r "$notif_id" "$intOut" -i "${swayIPath}" -p
  else
    notif_id=$(notify-send "$intOut" -i "${swayIPath}" -p)
    echo "$notif_id" > "$notif_file"
  fi &
}
