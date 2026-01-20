#!/usr/bin/env bash
set -euo pipefail

scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalfunction.sh"

pill="$1"
pill2="$2"
case $pill in
  --baloo)
    cp -r "${configDir}/.config/baloofileinformationrc" ${pill2}
    ;;
  --btop)
    cp -r "${configDir}/.config/btop" "${pill2}"
    ;;
  --dolphinrc)
    cp -r "${configDir}/.config/dolphinrc" "${pill2}"
    ;;
  --fastfetch)
    cp -r "${configDir}/.config/fastfetch" "${pill2}"
    ;;
  --fish)
    cp -r "${configDir}/.config/fish" "${pill2}"
    ;;
  --gtk-3.0)
    cp -r "${configDir}/.config/gtk-3.0" "${pill2}"
    ;;
  --gtk-4.0)
    cp -r "${configDir}/.config/gtk-4.0" "${pill2}"
    ;;
  --hypr)
    cp -r "${configDir}/.config/hypr" "${pill2}"
    ;;
  --ivy-shell)
    cp -r "${configDir}/.config/ivy-shell" "${pill2}"
    ;;
  --kdeglobals)
    cp -r "${configDir}/.config/kdeglobals" "${pill2}"
    ;;
  --kitty)
    cp -r "${configDir}/.config/kitty" "${pill2}"
    ;;
  --Kvantum)
    cp -r "${configDir}/.config/Kvantum" "${pill2}"
    ;;
  --mpd)
    cp -r "${configDir}/.config/mpd" "${pill2}"
    ;;
  --nvim)
    cp -r "${configDir}/.config/nvim" "${pill2}"
    ;;
  --nwg-look)
    cp -r "${configDir}/.config/nwg-look" "${pill2}"
    ;;
  --qt6ct)
    cp -r "${configDir}/.config/qt6ct" "${pill2}"
    ;;
  --rofi)
    cp -r "${configDir}/.config/rofi" "${pill2}"
    ;;
  --starship)
    cp -r "${configDir}/.config/starship.toml" "${pill2}"
    ;;
  --swaync)
    cp -r "${configDir}/.config/swaync" "${pill2}"
    ;;
  --systemd)
    cp -r "${configDir}/.config/systemd" "${pill2}"
    ;;
  --waybar)
    cp -r "${configDir}/.config/waybar" "${pill2}"
    ;;
  --wlogout)
    cp -r "${configDir}/.config/wlogout" "${pill2}"
    ;;
  --xsettingsd)
    cp -r "${configDir}/.config/xsettingsd" "${pill2}"
    ;;
  --all)
    cp -r "${configDir}/.config" "${pill2}"
    cp -r "${configDir}/.local" "${pill2}"
    cp -r "${configDir}/.icons" "${pill2}"
    cp -r "${configDir}/.gtkrc-2.0" "${pill2}"
    ;;
  *)
    exit 0
    ;;
esac



