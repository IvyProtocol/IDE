#!/usr/bin/env bash

set -u

scrDir="$(dirname "$(realpath "$0")")"
if [[ ! "${scrDir}/globalfunction.sh" ]]; then
  echo "n\Something went wrong to '${scrDir}/globalfunction.sh'"
else
  echo "n\Sourcing Global Variable"
fi
[[ -e ${scrDir}/globalfunction.sh ]] && source "${scrDir}/globalfunction.sh"

if [[ $EUID -eq 0 ]]; then
  echo "${IndentError} This script should ${indentWarning} NOT ${indentReset} be executed as root!!"
  printf "\n%.0s" {1..2}
  exit 1
fi

if grep -iqE '(ID|ID_LIKE)=.*(arch)' /etc/os-release >/dev/null 2>&1; then
  echo ${indentOk} "Arch Linux Detected"
  while true; do
    read -p "$(echo -n "${indentAction} Do you want to install anyway? (y/n): ")" check
    case ${check} in
      y|yes)
        echo -n "${indentNotice} Proceeding on Arch Linux by user confirmation"
        break
        ;;
      n|no|"")
        echo -n "${indentError} Aborting installation due to user choice. No changes were made."
        exit 0
        ;;
      *)
        echo "${indentError} Please answer 'y' or 'n'."
        ;;
    esac
  done
fi

if [[ -d "${cloneDir}/${aurRp}" ]]; then
  echo -n "${indentAction} AUR exists '${cloneDir}/${aurRp}'...."
  while true; do
    read -p "$(echo -n "${indentAction} Do you want to remove the directory? (y/n): ")" check1
    case ${check1} in
      Y|y)
        var=$(stat -c '%U' ${cloneDir}/${aurRp})
        var1=$(stat -c '%U' ${cloneDir}/${aurRp}/PKGBUILD)
        if [[ $var = $USER ]] && [[ $var1 = $USER ]]; then
          echo -n "${indentAction} Removing..."
          rm -rf "${cloneDir}"
          break
        elif [[ $var = root ]] && [[ $var1 = root ]]; then
          echo "${indentWarning} The file has root ownership!!!"
        fi
        ;;
      N|n)
        read -p "$(echo -n "${indentAction} !!!? Would you like to use that folder instead? (y/n): ")" check2
        case ${check2} in
          Y|y)
            if [[ -e "${cloneDir}/${aurRp}/PKGBUILD" ]]; then
              (cd "${cloneDir}/${aurRp}/" && makepkg -si)
              break
            else
              echo "${indentWarning} !!! Something went wrong in our side..."
              var=$(stat -c '%U' ${cloneDir}/${aurRp})
              var1=$(stat -c '%U' ${cloneDir}/${aurRp}/PKGBUILD)
              if [[ $var = $USER ]] && [[ $var1 = $USER ]]; then
                echo "${indentAction} Retrying the script"
              elif [[ $var = root ]] && [[ $var1 = root ]]; then
                echo "${indentInfo} The folder has root ownership. Please retry again later"
              fi
            fi
            ;;
          N|n)
            var=$(stat -c '%U' ${cloneDir}/${aurRp})
            var1=$(stat -c '%U' ${cloneDir}/${aurRp}/PKGBUILD)
            if [[ $var = $USER ]] && [[ $var1 = $USER ]]; then
              echo -n "${indentAction} Removing..."
              rm -rf "${cloneDir}"
            elif [[ $var = root ]] && [[ $var1 = root ]]; then
              echo "${indentWarning} The file has root ownership!!!"
            fi
            ;;
          *)
            echo "${indentError} Please answer 'y' or 'n'."
            ;;
        esac
        ;;
      *)
        echo "${IndentError} Please answer 'y' or 'n'."
        ;;
    esac
  done
else
  mkdir -p ${cloneDir}
fi

if [[ "$check" = "Y" ]] || [[ "$check" = "y" ]]; then
  echo "
It is generally recommended for this repository to have cachyos-repository. However, it is completely optional.
"
  read -rp "${indentInfo} Would you like to get cachyos-repository? (y/n): " check3
  check3="${check3,,}"
  case "$check3" in
    y|Y)
      curl "https://mirror.cachyos.org/${cachyRp}" -o "${cloneDir}/${cachyRp}"
      tar xvf "${cloneDir}/${cachyRp}" -C "${cloneDir}"
      sudo bash "${cloneDir}/cachyos-repo/cachyos-repo.sh"
      echo "${indentOk} Repository has been installed successfully."
      ;;
    n|N|""|*)
      echo "${indentOk} Aborting installation due to user preference."
      ;;
  esac
elif [[ -e "${cloneDir}/${cachyRp}" ]] || [[ -d "${cloneDir}/cachyos-repo" ]]; then
  echo "${indentAction} CachyOS Repository exists..."
  echo "${indentNotice} Deleting the Repository"
  rm -rf ${cloneDir}/${cacheRp}
  rm -rf ${cloneDir}/cachyos-repo
fi

if [[ $check = "Y" ]] || [[ $check = "y" ]]; then
  prompt_timer 120 "${indentNotice} Would you like to install yay?"

  case "$PROMPT_INPUT" in
    [Yy]*)
      git clone "https://aur.archlinux.org/${aurRp}.git" "${cloneDir}/${aurRp}"
      var=$(stat -c '%U' "${cloneDir}/${aurRp}")
      var1=$(stat -c '%U' "${cloneDir}/${aurRp}/PKGBUILD")

      if [[ $var = "$USER" ]] && [[ $var1 = "$USER" ]]; then
        (cd "${cloneDir}/${aurRp}/" && makepkg -si)
      fi
      break
      ;;
    [Nn]*|""|*)
      echo "${indentOk} Aborting Installation due to user preference. ${aurRp} wasn't installed."
      ;;
  esac
fi

if [[ $check = "Y" ]] || [[ $check = "y" ]]; then
  if [[ -e "${pkgsRp}" ]]; then
    var=$(stat -c '%U' ${pkgsRp})
    var1=$(stat -c '%U' ${pkgsRp})
    if [[ $var = $USER ]] && [[ $var1 = $USER ]]; then
      ${pkgsRp} --hyprland
      echo -n "${indentOk} All hyprland packages were installed."
    elif [[ $var = root ]] && [[ $var = root ]]; then
      echo "${indentWarning} The shell script has root ownership!!! Exiting..."
      exit 1
    fi
      prompt_timer 120 "${indentNotice} Would you like to get additional packages?"
      case "$PROMPT_INPUT" in
        [Yy]*)
          echo -n "${indentAction} Proeeding installation due to User's request."
          ${pkgsRp} --extra
          echo -n "${indentOk} All extra packages were installed"
          break
          ;;
        [Nn]|*)
          echo -n "${indentAction} Avorting installation due to User Preferences."
          ;;
      esac
    prompt_timer 120 "${indentNotice} Would you also like to get driver packages (Intel only, The default is 'no' [Recommended]"
    case "$PROMPT_INPUT" in
      [Yy]*)
        echo -n "${indentAction} Proceeding installation due to User's request."
        ${pkgsRp} --driver
        echo -n "${indentAction} All driver packages were installed"
        ;;
      [Nn]|*)
        echo -n "${indentAction} Avorting installation due to User Preferences."
        ;;
    esac
  else
    echo "${indentWarning} The Package DOES NOT EXIST!!"
  fi
fi

if [[ -d $configDir ]]; then
  echo "${indentYellow} Populating ${confDir}"
  ${scrDir}/dircaller.sh --all ${homDir}/ 
  tar -xvf ${sourceDir}/Sweet-cursors.tar.xz ${homDir}/.icons
  ln -sf /usr/share/themes/adw-gtk3/assets ${confDir}/gtk-4.0/assets
  ln -sf /usr/share/themes/adw-gtk3/gtk-4.0/gtk-dark.css ${confDir}/gtk-4.0/assets
  echo "${indentNotice} Switching the shell to fish"
  chsh -s /usr/bin/env fish
  echo "${indentOk} Conversion to fish is completed!"
  
  dirTarget=$(mkdir -p ${homDir}/Pictures/wallpapers/)
  prompt_timer 120 "${indentAction} Would you like to pull wallpapers from a repository?"
  case "$PROMPT_INPUT" in
    Y|y)
      echo -n "${indentNotice} Proceeding pulling repository due to User's repository."
      if [[ -d "${homDir}/Pictures/wallpapers" ]]; then
        mkdir -p "${homDir}/Pictures/wallpapers"
      fi
      git clone --depth 1 "https://${repRp}" "${homDir}/Pictures/wallpapers"
      ${localDir}/color-cache.sh
      echo "${indentOk} Wallpapers Cached"
      ;;
    N|n)
      prompt_timer 120 "${indentReset} Would you like to pull from another repository? [Drop the full clone link or say --skip to avoid"
      case $prompt_input in
        "")
          echo "${indentError} No Link was given"
          ;;
        *)
          dirTarget=$(mkdir -p ${homDir}/Pictures/wallpapers/)
          git clone --depth 1 "$PROMPT_INPUT" "$dirTarget"
          ${localDir}/color-cache.sh
          echo "${IndentOk} Ivy-Shell has cached all the wallpapers"
          ;;
        --skip)
          echo "${indentOk} Pulling wallpapers from source."
          cp -r "${sourceDir}/assets/*.png" "${dirTarget}"
          cp -r "${sourceDir}/assets/*.jpg" "${dirTarget}"
          ${localDir}/color-cache.sh
          echo "${IndentOk} Ivy-Shell has cached all the wallpapers"
          ;;
      esac
      ;;
  esac
fi

reboot


  






