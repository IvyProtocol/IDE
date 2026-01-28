#!/usr/bin/env bash

set -euo pipefail

export scrDir="$(dirname "$(realpath "$0")")"
export cloneDir="${XDG_CLONE_DIR:-${scrDir}}/Clone"
export homDir="${XDG_HOME_DIR:-$HOME}"
export confDir="${XDG_CONFIG_HOME:-${homDir}}/.config"
export cacheDir="${XDG_CACHE_HOME:-${homDir}}/.cache"
export configDir="${XDG_CONFIGDIR_HOME:-${scrDir}}/../Configs/"
export localDir="${XDG_LOCAL_DIR:-${homDir}}/.local/bin"
export sourceDir="${XDG_SOURCE_DIR:-${scrDir}}/../Source"
export walDir="${XDG_WALDIR_HOME:-${homDir}}/Pictures/wallpapers"
export hyprDir="${XDG_HYPRDIR_HOME:-${confDir}/hypr}/hyprland"

export aurRp="yay-bin"
export cachyRp="cachyos-repo.tar.xz"
export pkgsRp="${XDG_PKGSRP_HOME:-${scrDir}}/pkgs-core.sh"
export repRp="github.com/IvyProtocol/Ivy-wallpapers.git"

export indentOk="$(tput setaf 2)[OK]$(tput sgr0)"
export indentError="$(tput setaf 1)[ERROR]$(tput sgr0)"
export indentNotice="$(tput setaf 3)[NOTICE]$(tput sgr0)"
export indentInfo="$(tput setaf 4)[INFO]$(tput sgr0)"
export indentReset="$(tput setaf 5)[RESET]$(tput sgr0)"
export indentAction="$(tput setaf 6)[ACTION]$(tput sgr0)"
export indentWarning="$(tput setaf 1)"
export exitCode1="$(tput setaf 1)[EXIT-CODE-1]$(tput sgr0)"
export exitCode0="$(tput setaf 2)[EXIT-CODE-0]$(tput sgr0)"

export indentMagenta="$(tput setaf 5)"
export indentYellow="$(tput setaf 3)"
export indentOrange="$(tput setaf 214)"
export indentGreen="$(tput setaf 2)"
export indentBlue="$(tput setaf 4)"
export indentSkyBlue="$(tput setaf 6)"

env_pkg() {
  local envPkg statsPkg defAur
  OPTIND=1
  defAur="${defAur:-yay}"

  while getopts "A:H:" opt; do
    case "$opt" in
      A) 
        defAur="$OPTARG"
        ;;
      H)
        echo -e " :: ${indentInfo} Use env_pkg as how pacman works. Example, env_pkg -- -S|-Q|-Ss <package_name>"
        echo -e " :: ${indentInfo} Use env_pkg to describe the AUR to use with -A. env_pkg -A <aur_helper> -- -<PREFIX> <package_name>"
        return 0
        ;;
      *) echo "Invalid option"; return 1 ;;
    esac
  done
  shift $((OPTIND-1))
  if ! command -v "${defAur}" >/dev/null 2>&1; then
    echo -e " :: ${defAur} does not exist! Defaulting to pacman!"
    defAur="pacman"
  fi
  envPkg="$1"
  shift

  statsPkg=("$@")
  if [[ "$envPkg" == "-S" ]]; then
    echo -e " :: ${defAur} ${envPkg} is being used!"
    for pkg in "${statsPkg[@]}"; do
      if "${defAur}" -Q "$pkg" &>/dev/null; then
        echo -e " :: ${pkg} is already installed. Skipping..."
        continue
      else
        [[ "${defAur}" == "pacman" ]] && sudo "${defAur}" -S --noconfirm --needed "${pkg}" || "${defAur}" -S --noconfirm --needed "${pkg}" 
        [[ "$?" != 0 ]] && echo -e " :: Package ${pkg} failed to install! Manual intervention required!" || echo -e " :: ${pkg} installed successfully!"
      fi
    done
  else
    [[ "${defAur}" == "pacman" ]] && sudo "${defAur}" "${envPkg}" "${statsPkg[@]}" || "${defAur}" "${envPkg}" "${statsPkg[@]}"
    return $?
  fi
}

update_editor() {
  local editor=$1
  sed -i "s/env=EDITOR,.*/env = EDITOR,$editor/" ${hyprDir}/env.conf
  echo " :: ${indentOk} Default editor set to ${indentMagenta}$editor${indentReset}." 2>&1
}

timestamp_dirname() {
  local timestamp
  local name="$1"
  timestamp=$(date +"%m%d_%H%M")
  echo "${name}_${timestamp}"
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


