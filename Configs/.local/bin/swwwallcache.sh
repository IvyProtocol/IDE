#!/usr/bin/env bash

export scrDir="$(dirname "$(realpath "$0")")"

[[ -e "${scrDir}/globalvariable.sh" ]] && source "${scrDir}/globalvariable.sh" || exit 1 

export ideCDir
export dcolDir
thmbDir="${ideCDir}/cache/thumb"
blurDir="${ideCDir}/cache/blur"
scrRun="${scrDir}/ivy-shell.sh"

[[ -d "${thmbDir}" ]] || mkdir -p "${thmbDir}"
[[ -d "${blurDir}" ]] || mkdir -p "${blurDir}"

if srcf_rcall fl_wallpaper >/dev/null 2>&1; then
  echo "[$0]: function {fl_wallpaper} does NOT exist!" && exit 1
fi

fn_wallcache() {
  local h_sum="${1:-}"
  local w_sum="${2:-}"
  local sr_call="$(fl_wallpaper -t "${w_sum}" -f 1)"

  [[ ! -f "${thmbDir}/thumb-${sr_call}.png" ]] && magick "${w_sum}"[0] -strip -resize 1000 -gravity center -extent 1000 -quality 90 "${thmbDir}/thumb-${sr_call}.png"
  [[ ! -f "${blurDir}/${sr_call}.png" ]] && magick "${w_sum}"[0] -strip -scale 10% -blur 0x3 -resize 100% "${blurDir}/${sr_call}.png"
  [[ ! -e "${dcolDir}/auto/ivy-${h_sum}.dcol" ]] && "${scrRun}" "${w_sum}" -a --helper=1
  [[ ! -e "${dcolDir}/dark/ivy-${h_sum}.dcol" ]] && "${scrRun}"  "${w_sum}" -d --helper=1
  [[ ! -e "${dcolDir}/light/ivy-${h_sum}.dcol" ]] && "${scrRun}"  "${w_sum}" -l --helper=1
} >/dev/null 2>&1

fn_wallcache_thumb() {
  local h_sum="${1:-}"
  local w_sum="${2:-}"
  local sr_call="$(fl_wallpaper -t "${w_sum}" -f 1)"
  [[ ! -f "${thmbDir}/thumb-${sr_call}.png" ]] && magick "${w_sum}"[0] -strip -resize 1000 -gravity center -extent 1000 -quality 90 "${thmbDir}/thumb-${sr_call}.png"
} >/dev/null 2>&1

fn_wallcache_blur() {
  local h_sum="${1:-}"
  local w_sum="${2:-}"
  local sr_call="$(fl_wallpaper -t "${w_sum}" -f 1)"
  [[ ! -f "${blurDir}/${sr_call}.png" ]] && magick "${w_sum}"[0] -strip -scale 10% -blur 0x3 -resize 100% "${blurDir}/${sr_call}.png"
} >/dev/null 2>&1

fn_wallcache_force() {
  local h_sum="${1:-}"
  local w_sum="${2:-}"
  local sr_call="$(fl_wallpaper -t "${w_sum}" -f 1)"

  magick "${w_sum}"[0] -strip -resize 1000 -gravity center -extent 1000 -quality 90 "${thmbDir}/thumb-${sr_call}.png"
  magick "${w_sum}"[0] -strip -scale 10% -blur 0x3 -resize 100% "${blurDir}/${sr_call}.png"
  "${scrRun}" "${w_sum}" -a --helper=1
  "${scrRun}"  "${w_sum}" -d --helper=1
  "${scrRun}"  "${w_sum}" -l --helper=1 
} >/dev/null 2>&1

export -f fn_wallcache fn_wallcache_force fn_wallcache_blur fn_wallcache_thumb fl_wallpaper
export thmbDir blurDir dcolDir scrRun mode cacheIn

mode="${mode:-}"
cacheIn="${cacheIn:-}"
while getopts ":f:w:b:t:" option; do
  case $option in
    f) 
      cacheIn="${OPTARG}"
      mode="_force"
      [[ -z "${OPTARG}" || ! -e "${OPTARG}" ]] && {
        echo "Error: Input wallpaper has returned exit code 1" 
        exit 1
      }
      ;;
    w)
      cacheIn="$OPTARG"
      [[ -z "${OPTARG}" || ! -e "${OPTARG}" ]] && { 
        echo "Error: Input wallpaper \"${OPTARG}\" not found!"
        exit 1
      }
      ;;
    b)
      cacheIn="${OPTARG}"
      mode="_blur"
      [[ -z "${OPTARG}" || ! -e "${OPTARG}" ]] && {
        echo "Error: Input wallpaper \"${OPTARG}\" not found!"
        exit 1
      }
      ;;
    t)
      cacheIn="${OPTARG}"
      mode="_thumb"
      [[ -z "${OPTARG}" || ! -e "${OPTARG}" ]] && {
        echo "Error: Input wallpaper \"${OPTARG}\" not found!"
        exit 1
      }
    ;;
  esac
done

wallPathArray=("${cacheIn}")
hashmap -v -t "${wallPathArray[@]}"
parallel --bar --link fn_wallcache${mode} ::: "${wallHash[@]}" ::: "${wallList[@]}"
exit 0
