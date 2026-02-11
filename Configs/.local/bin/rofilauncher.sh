#!/usr/bin/env bash
set -eo pipefail

scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/globalcontrol.sh"

[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10
[[ -z "${rofiStyleDir}" ]] && rofiStyleDir="${confDir}/rofi/styles"

rofiStyleLaunch="${rofiStyleDir}/style-${rofiStyle}.rasi"
[[ ! -f "${rofiStyleLaunch}" ]] && read -r rofiStyleLaunch <<< "$(find "${rofiStyleDir}" -type f -name "style-*.rasi" | sort -t '-' -k 2 -n | head -1 )" 
echo -e " :: Rofi-Launch - Preparting to read ${rofiStyleLaunch} - Deploying...."

case "${1}" in
  -d|--drun) rofiMode="drun" ;;
  -w|--window) rofiMode="window" ;;
  -f|--filebrowser) rofiMode="filebrowser" ;;
  -h|--help)
    echo -e "$(basename "${0}" ) [action]"
    echo "-d : drun mode"
    echo "-w : window mode"
    echo "-f : filebrowser mode"
    ;;
  *) rofiMode="drun" ;;
esac

wind_border=$(( hypr_border * 3 ))
[[ "${hypr_border}" -eq 0 ]] && elem_border="10" || elem_border=$(( hypr_border * 2 ))
r_override="window {border: ${hypr_width}px; border-radius: ${wind_border}px;} element {border-radius: ${elem_border}px;}"
r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
is_override="$(gsettings get org.gnome.desktop.interface icon-theme | sed "s/'//g")"
i_override="configuration {icon-theme: \"${is_override}\";}"

echo -e " :: Rofi-Launch - Profile :: '${rofiStyleLaunch}' :: Element-Border '${elem_border}' :: Border-Radius '${wind_border}' :: Icon-Theme '${is_override}'"
rofi -show "${rofiMode}" -theme-str "${r_scale}" -theme-str "${r_override}" -theme-str "${i_override}" -config "${rofiStyleLaunch}"

