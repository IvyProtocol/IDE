#!/usr/bin/env bash

scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/globalcontrol.sh"

if ! env_pkg -- -Q "wlogout" >/dev/null 2>&1; then
    notify -m 1 -p "Is wlogout installed? Exit-Code 1" -u critical -t 900 -a "t2" -s "${dunstDir}/icons/hyprdots.svg"
    exit 1
else
    pgrep -x "wlogout" 2>/dev/null && [[ $? -lt 1 ]] && pkill -x "wlogout" && exit 0
fi

wlogoutStyle="${1:-${wlogoutStyle}}"
[[ -f "${confDir}/wlogout/layout_${wlogoutStyle}" ]] || [[ -f "${confDir}/wlogout/style_${wlogoutStyle}" ]] || wlogoutStyle=1

wLayout="${confDir}/wlogout/layout_${wlogoutStyle}"
wlTmplt="${confDir}/wlogout/style_${wlogoutStyle}.css"
y_mon=$(hyprctl -j monitors | jq '.[] | .height')

case "${wlogoutStyle}" in
    1)  wlColms=6
        export mgn=$(( y_mon * 28 / mon_scale ))
        export hvr=$(( y_mon * 23 / mon_scale )) ;;
    2)  wlColms=2
        export x_mgn=$(( mon_res * 35 / mon_scale  ))
        export y_mgn=$(( y_mon * 25 / mon_scale ))
        export x_hvr=$(( mon_res * 32 / mon_scale ))
        export y_hvr=$(( y_mon * 20 / mon_scale )) ;;
esac
if [[ "${enableWallIde}" -eq 3 ]]; then
    unset dcolMode
    colorScheme="$(grep "^[[:space:]]*\$COLOR[-_]SCHEME\s*=" "${ideDir}/theme/{PrevThemeIde}/hypr.theme" | sed "s/.*-//g; s/'//g" \
        || gsettings get org.gnome.desktop.interface color-scheme | sed "s/'//g; s/.*-//" \
        || { echo " colorScheme is empty!"; colorScheme="dark" ; } )"
    [[ "${colorScheme}" == "light" ]] && dcolMode="light" || dcolMode="dark"
    [[ -f "${ideDir}/theme/${PrevThemeIde}/theme.dcol" ]] && source "${ideDir}/theme/${PrevThemeIde}/theme.dcol"
fi

[[ "${dcolMode}" == "light" ]] && export BtnCol="black" || export BtnCol="white"
export active_rad=$(( hypr_border * 5 ))
export button_rad=$(( hypr_border * 8 ))
export fntSize=$(( y_mon * 2 / 100 ))

echo -e " :: Deploying :: Profile - ${wlogoutStyle} :: DcolMode - ${dcolMode} :: Theme - ${PrevThemeIde} :: Font-Size - ${fntSize}"
wlStyle="$(envsubst < $wlTmplt)"
wlogout -b "${wlColms}" -c 0 -r 0 -m 0 --layout "${wLayout}" --css <(echo "${wlStyle}") --protocol layer-shell

