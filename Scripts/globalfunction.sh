#!/usr/bin/env bash

set -euo pipefail

export scrDir="$(dirname "$(realpath "$0")")"
export cloneDir="${XDG_CLONE_DIR:-${scrDir}}/Clone"
export homDir="${XDG_HOME_DIR:-$HOME}"
export confDir="${XDG_CONFIG_HOME:-${homDir}}/.config"
export cacheDir="${XDG_CACHE_HOME:-${homDir}}/.cache"
export configDir="${XDG_CONFIGDIR_HOME:-${scrDir}}/../Configs/"
export localDir="${XDG_LOCAL_DIR:-${homDir}}/.local/bin/"
export sourceDir="${XDG_SOURCE_DIR:-${scrDir}}/../Source"

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

export indentMagenta="$(tput setaf 5)"
export indentYellow="$(tput setaf 3)"

print_color() {
  printf "%b%sb\n" "$1" "$2" "${indentReset}"
}

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
      echo -e "${indentAction} $pkg is already installed. Skipping..."
      continue
    fi

    ($ISAUR -S --noconfirm "$pkg") &
    PID=$!
    if $ISAUR -Q "$pkg" &>/dev/null; then
      echo -e "${indentOk} Package $pkg installed successfully!"
    else
      echo -e "${indentError} Package $pkg failed"
    fi
  done
}

install_package() {
  for dir in "$@"; do
    if cp -r "$pkg" &>/dev/null; then
      echo -e "${indentAction} $pkg is already installed. Skipping..."
      continue
    fi

    (cp -r --noconfirm "$dir") &
    PID=$!
    if $ISAUR -Q "$pkg" &>/dev/null; then
      echo -e "${indentOk} Package $pkg installed successfully!"
    else
      echo -e "${indentError} Package $pkg failed"
    fi
  done
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


