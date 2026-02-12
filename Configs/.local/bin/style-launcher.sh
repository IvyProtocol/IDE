#!/usr/bin/env bash
#  ┳┓┏┓┏┓┳  ┓ ┏┓┳┳┳┓┏┓┓┏┏┓┳┓  ┏┓┏┳┓┓┏┓ ┏┓  ┏┓┏┓┓ ┏┓┏┓┏┳┓┏┓┳┓
#  ┣┫┃┃┣ ┃━━┃ ┣┫┃┃┃┃┃ ┣┫┣ ┣┫━━┗┓ ┃ ┗┫┃ ┣ ━━┗┓┣ ┃ ┣ ┃  ┃ ┃┃┣┫
#  ┛┗┗┛┻ ┻  ┗┛┛┗┗┛┛┗┗┛┛┗┗┛┛┗  ┗┛ ┻ ┗┛┗┛┗┛  ┗┛┗┛┗┛┗┛┗┛ ┻ ┗┛┛┗
#                                                           

# Copyright: The Hyde Project
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"

rasiDir="${rasiDir}/selector.rasi"
[[ -z "${rofiScale}" ]] && font_scale=10 || font_scale="${rofiScale}"

elem_border=$((2 * 5))
icon_border=$((elem_border - 5))
mon_x_res=$((mon_res * 100 / mon_scale))
elm_width=$(((20 + 12 + 16) * font_scale))
max_avail=$((mon_x_res - (4 * font_scale)))

if [[ "${rofiColCount}" -eq 0 || -z "${rofiColCount}" ]]; then
    rofiColCount=$((max_avail / elm_width))
    [[ "${rofiColCount}" -gt 5 ]] && col_count=5
fi
r_override="window{width:100%;} listview{columns:${rofiColCount};} element{orientation:vertical;border-radius:${elem_border}px;} element-icon{border-radius:${icon_border}px;size:25em;} element-text{enabled:false;}"

mapfile -t style_files < <(find -L "$rofiAssetDir" -type f -name '*.png')

style_names=()
for file in "${style_files[@]}"; do
    echo "$file"
    style_names+=("$(basename "$file")")
done

IFS=$'\n' style_names=($(sort -V <<<"${style_names[*]}"))
unset IFS

rofi_list=""
for style_name in "${style_names[@]}"; do
    rofi_list+="${style_name}\x00icon\x1f${rofiAssetDir}/${style_name}\n"
done

RofiSel=$(echo -en "$rofi_list" | rofi -dmenu -markup-rows -theme-str "$r_override" -theme "$rasiDir" -select "style-${rofiStyle}.png")

if [[ ! -z "${RofiSel}" ]]; then
    UpdRofiSel=$(echo "$RofiSel" | tr -d '[A-Za-z.]-')
    setConf "rofiStyle" "${UpdRofiSel}" "${ideDir}/ide.conf"
    notify -m 2 -i "rofi_notif" -t 1200 -s "${rofiAssetDir}/${RofiSel}" -a "t1" -p "Rofi style ${RofiSel} applied..."
fi
