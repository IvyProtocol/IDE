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
export ideCDir="${XDG_IDE_CACHE:-${cacheDir}/ivy-shell}"
export dcolDir="${XDG_DCOL_HOME:-${ideCDir}/shell}"

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

ISAUR="yay"
if ! command -v yay &>/dev/null; then
  ISAUR="pacman"
fi
install_package() {
  for pkg in "$@"; do
    if $ISAUR -Q "$pkg" &>/dev/null; then
      echo -e " :: ${indentAction} $pkg is already installed. Skipping..."
      continue
    fi

    (clear && $ISAUR -S --noconfirm "$pkg")
    if $ISAUR -Q "$pkg" &>/dev/null; then
      echo -e " :: ${indentOk} Package $pkg installed successfully!"
    else
      echo -e " :: ${indentError} Package $pkg failed"
    fi
  done
}

timestamp() {
  local timestamp
  timestamp=$(date +"%m%d_%H%M")
  echo "${timestamp}"
}

prompt_timer() {
    set +e
    unset PROMPT_INPUT
    local timsec=$1
    local msg=$2
    while [[ ${timsec} -ge 0 ]]; do
        echo -ne "\r :: ${msg} (${timsec}s) : "
        read -rt 1 -n 1 PROMPT_INPUT && break
        ((timsec--))
    done
    export PROMPT_INPUT
    echo ""
    set -e
}

fl_wallpaper() {
  OPTIND=1
  local fill=0 fillPath extract_wall w_int="" c_rasi
  c_rasi="${ideCDir}/cache.rasi"

  while getopts ":f:t:r" prefix; do
    case "${prefix}" in
       f) fill="${OPTARG}" ;;
       t) w_int="${OPTARG}" ;;
       r) w_int=$(grep -oE '"/[^"]+"' "$c_rasi") || return 1 ;;
     esac
  done
  shift $((OPTIND - 1))

  [[ -n "${w_int}" ]] || return 1
  fillPath="${w_int#\"}"
  fillPath="${fillPath%\"}"
  extract_wall="${fillPath##*/}"
  w_int="${extract_wall}"

  [[ "$fill" -eq 1 ]] && w_int="${w_int%.*}"
  echo "$w_int"
}

notify() {
  OPTIND=1
  local modern="" swayncIPath="" printOut="" notify_id="" value="" notif_file
  
  while getopts ":m:s:p:i:v:" prefix; do
    case "${prefix}" in
      m) modern="${OPTARG}" ;;
      s) 
        swayncIPath="${OPTARG}" 
        ;;
      p) 
        printOut="${OPTARG}"
        ;;
      i)
        notify_id="${OPTARG}"
        ;;
      v)
        value="${OPTARG}"
        ;;
    esac
  done
  if [[ "${modern}" -eq 2 ]]; then
    notify-send -e -h string:x-canonical-private-synchronous:${notify_id} ${value:+-h int:value:${value}} ${swayncIPath:+-i "${swayncIPath[@]}"} "$printOut"
  elif [[ "${modern}" -eq 1 ]]; then
    notif_file="/tmp/.ivy_notif_id"
    notif_id=""

    [[ -f "${notif_file}" ]] && notif_id=$(<"${notif_file}")
    if [[ -n "$notif_id" ]]; then
      notify-send -r "${notif_id}" "${printOut}" ${swayncIPath:+-i "${swayncIPath}"} -p
    else
      notif_id=$(notify-send "${printOut}" ${swayncIPath:+-i "${swayncIPath}"} -p)
      echo "${notif_id}" > "${notif_file}"
    fi
  else
    [[ -z "${OPTARG}" ]] && {
      echo -e "[$0] Correct arguments are:"
      echo -e "[$0] -l, legacy usage of notif_id. Supports: -s, -p."
      echo -e "[$0] -m, private usage of notify-send. Supports: -s, -p, -i, -v. Mandatorial: -p, -i."
      echo -e "[$0] -p, print inputted message." #If two -p are declared, then the second flag would overlap! 
      echo -e "[$0] -i, increament notif_id to notify-send. Mandatory if -m 2 was used."
      echo -e "[$0] -v, value set for notify-send, optional."
      exit 1
    }
  fi
}


hashmap() {
  local hashpref hashMap
  wallHash=()
  wallList=()
  while getopts ":v:t:" hashpref; do
    case "$hashpref" in
      v) verboseMap=1;;
      t) target="$OPTARG" ;;
    esac
  done
  shift $((OPTIND - 1))

  for src in "$@"; do
    hashMap=$(find "$src" -type f \( -iname "*.gif" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -exec md5sum {} + | sort -V)

    if [[ -z "${hashMap}" ]]; then
      echo "WARNING: No image found in \"${src}\""
      continue
    fi

    while read -r shaMap img ; do
      wallHash+=("${shaMap}")
      wallList+=("${img}")
    done <<< "${hashMap}"

    if [[ "${verboseMap}" -eq 1 ]]; then
      for indx in "${!wallHash[@]}" ; do
        echo ":: \${wallHash[${indx}]}=\"${wallHash[indx]}\" :: \${wallList[${indx}]}=\"${wallList[indx]}\""
      done
    fi
  done
}

srcf_rcall() {
  local sr_call="${sr_call:-${1}}"

  if declare -f "${sr_call}" >/dev/null 2>&1; then
    return 1
  else
    return 0
  fi
}

if echo "$HYPRLAND_INSTANCE_SIGNATURE" &>/dev/null; then
  export hypr_border="$(hyprctl -j getoption decoration:rounding | jq '.int')"
  export hypr_width="$(hyprctl -j getoption general:border_size | jq '.int')"
fi

mon_res=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
mon_scale=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .scale' | tr -d '.')
