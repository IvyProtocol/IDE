#!/usr/bin/env bash

set -euo pipefail

scrDir="$(dirname "$(realpath "$0")")"
if [[ ! -f "${scrDir}/globalfunction.sh" ]]; then
  echo " :: Something went wrong to '${scrDir}/globalfunction.sh'"
else
  echo " :: Sourcing Global Variable"
fi
[[ -e ${scrDir}/globalfunction.sh ]] && source "${scrDir}/globalfunction.sh"

if [[ $EUID -eq 0 ]]; then
  echo "${IndentError} This script should ${indentWarning} NOT ${indentReset} be executed as root!! ${exitCode1}"
  printf "\n%.0s" {1..2}
  exit 1
fi

command="${1:-}"
base="${2:-}"
case $command in
  --ed)
    update_editor "$base"
    echo -e " :: ${indentOk} - ${base} has been made default. ${exitCode0}"
    exit 0
    ;;
  --ch)
    ${pkgsRp} --"$2"
    echo -e " :: ${indentOk} - ${2} package have been installed. ${exitCode0}"
    exit 0
    ;;
  --cachyRp)
    mkdir -p "${cloneDir}"
    curl "https://mirror.cachyos.org/${cachyRp}" -o "${cloneDir}/${cachyRp}"
    tar xvf "${cloneDir}/${cachyRp}" -C "${cloneDir}"
	clear
    (cd "${cloneDir}/cachyos-repo" && sudo ./cachyos-repo.sh)
	clear
    echo " :: ${indentOk} Repository has been ${indentGreen}installed${indentGreen} successfully. ${exitCode0}"
    exit 0
    ;;
  --yay)
  	if pkg_installed "yay-bin" 2>/dev/null; then
	  echo -e " :: ${indentAction} ${aurRp} is already ${indentGreen} installed - ${exitCode0}"
	else
	  clear
	  git clone "https://aur.archlinux.org/${aurRp}.git" "${cloneDir}/${aurRp}" >/dev/null 2>&1
	  clear
      var=$(stat -c '%U' "${cloneDir}/${aurRp}")
      var1=$(stat -c '%U' "${cloneDir}/${aurRp}/PKGBUILD")

      if [[ $var = "$USER" ]] && [[ $var1 = "$USER" ]]; then
        (cd "${cloneDir}/${aurRp}/" && makepkg -si)
      fi
      exit 0
	fi
    ;;
  --sddm)
    if [[ -f "${sourceDir}/SDDM-Silent.tar.gz" ]]; then
      sudo chown -R $USER:$USER /usr/share/sddm/themes/* >/dev/null 2>&1
      tar -xvf "${sourceDir}/SDDM-Silent.tar.gz" -C "/usr/share/sddm/themes/" >/dev/null 2>&1
      clear
      if [[ ! -e "${localDir}/../ivy-shell/sddm/sddm.conf" ]]; then
        cat > "${localDir}/../ivy-shell/sddm/sddm.conf" <<EOF
[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard

[Theme]
Current=Silent
EOF
      fi
      sudo cp "${localDir}/../ivy-shell/sddm/sddm.conf" /etc/sddm.conf >/dev/null 2>&1
      if sed -n '/^[[:space:]]*if \[\[ "\$img"/,/^[[:space:]]*fi/p' "${localDir}/wbselecgen.sh" | grep -q '^[[:space:]]*#.*cp '; then
        sed -i '/^[[:space:]]*if \[\[ "\$img"/,/^[[:space:]]*fi/ s/^\([[:space:]]\{4,\}\)# \?\(cp .*"\)/\1\2/' "${localDir}/wbselecgen.sh"
      fi
    fi
    ;;
esac

if grep -iqE '(ID|ID_LIKE)=.*(arch)' /etc/os-release >/dev/null 2>&1; then
  echo " :: ${indentOk} Arch Linux Detected"
  while true; do
    read -p "$(echo -n " :: ${indentAction} Do you want to install anyway? (y/n): ")" check
    case ${check} in
      y|yes)
        echo " :: ${indentNotice} Proceeding on Arch Linux by user confirmation."
        break
        ;;
      n|no)
        echo " :: ${indentError} Aborting installation due to user choice. No changes were made. ${exitCode0}"
        exit 0
        ;;
      *|"")
        echo " :: ${indentError} Please answer 'y' or 'n'. "
        ;;
    esac
  done
fi


if [[ "${check}" = "Y" ]] || [[ ${check} = "y" ]]; then
  rpcachecheck=0
  while true; do
    if [[ -d "${cloneDir}/cachyos-repo" ]] || [[ -d "${cloneDir}/${cachyRp}" ]]; then
      prompt_timer 120 "${indentAction} Would you like to delete the repository?"
      case "$PROMPT_INPUT" in
        Y|y)
          if [[ $(stat -c '%U' ${cloneDir}/${cachyRp}) = $USER ]] || [[ $(stat -c '%U' ${cloneDir}/cachyos-repo) = $USER ]]; then
            echo " :: ${indentNotice} Deleting ${indentGreen}the Repository"
            rm -rf ${cloneDir}/${cachyRp}
            rm -rf ${cloneDir}/cachyos-repo
			      rpcachecheck=1
            break
          elif [[ $(stat -c '%u' ${cloneDir}/${cachyRp}) -eq 0 ]] || [[ $(stat -c '%u' ${cloneDir}/cachyos-repo) -eq 0 ]]; then
            echo " :: ${indentError} The file has ${indentWarning}root${indentWarning} ownership!! Manual intervention required - ${exitCode1}"
            exit 1
          fi
          ;;
        N|n)
          prompt_timer 120 " :: ${indentNotice} Would you like to rather use the repository?"
          case $PROMPT_INPUT in
            y|Y)
              if [[ -e "${cloneDir}/cachyos-repo/cachyos-repo.sh" ]]; then
			  	      clear
                (cd "${cloneDir}/cachyos-repo" && sudo ./cachyos-repo.sh)
				        clear
                break
              else
                echo "${indentError} !!! Something went ${indentWarning}wrong${indentWarning} in our side..."
                if [[ $(stat -c '%U' ${cloneDir}/${cachyRp}) = $USER ]] || [[ $(stat -c '%U' ${cloneDir}/cachyos-repo) = $USER ]]; then
                  echo " :: ${indentAction} Retrying the script!"
                elif [[ $(stat -c '%u' ${cloneDir}/${cachyRp}) -eq 0 ]] || [[ $(stat -c '%u' ${cloneDir}/cachyos-repo) -eq 0 ]]; then
                  echo " :: ${indentError} The folder has ${indentWarning}root${indentWarning} ownership. Manual intervention required - ${exitCode1}"
                  exit 1
                fi
              fi
              ;;
            n|N)
              if [[ $(stat -c '%U' ${cloneDir}/${cachyRp}) = $USER ]] || [[ $(stat -c '%U' ${cloneDir}/cachyos-repo) = $USER ]]; then
                echo " :: ${indentNotice} Deleting ${indentGreen}the repository."
                rm -rf ${cloneDir}/${cachyRp}
                rm -rf ${cloneDir}/cachyos-repo
				        rpcachecheck=1
                break
              elif [[ $(stat -c '%u' ${cloneDir}/${cachyRp}) -eq 0 ]] || [[ $(stat -c '%u' ${cloneDir}/cachyos-repo) -eq 0 ]]; then
                echo " :: ${indentError} The file has ${indentWarning}root${indentWarning} ownership!!! ${exitCode1}"
                exit 1
              fi
              ;;
            *|"")
              echo " :: ${indentError} Please answer 'y' or 'n'. ${exitCode1}"
              ;;
          esac
          ;;
        *)
          echo -e " :: ${indentError} Please answer 'y' or 'n'. ${exitCode1}"
          ;;
      esac
    else
      prompt_timer 120 "${indentNotice} Would you like to get cachyos-repository? "
      case "$PROMPT_INPUT" in
        y|Y)
		      mkdir -p "${cloneDir}"
          curl "https://mirror.cachyos.org/${cachyRp}" -o "${cloneDir}/${cachyRp}" 2>/dev/null  2>&1
          tar xvf "${cloneDir}/${cachyRp}" -C "${cloneDir}" >/dev/null 2>&1
		      clear
          (cd "${cloneDir}/cachyos-repo/" && sudo ./cachyos-repo.sh)
		      clear
          echo " :: ${indentOk} Repository has been ${indentGreen}installed${indentGreen} successfully. ${exitCode0}"
          break
          ;;
        n|N|""|*)
          echo " :: ${indentReset} Aborting installation due to user preference. ${exitCode0}"
          break
          ;;
      esac 
    fi
  done
fi

if [[ "$rpcachecheck" -eq 1 ]]; then
  prompt_timer 120 "${indentNotice} Would you like to get cachyos-repository? "
  case "$PROMPT_INPUT" in 
    y|Y)
      mkdir -p "${cloneDir}"
      curl "https://mirror.cachyos.org/${cachyRp}" -o "${cloneDir}/${cachyRp}" 2>/dev/null  2>&1
      tar xvf "${cloneDir}/${cachyRp}" -C "${cloneDir}" >/dev/null 2>&1
	    clear
      (cd "${cloneDir}/cachyos-repo/" && sudo ./cachyos-repo.sh)
	    clear
      echo " :: ${indentOk} Repository has been ${indentGreen}installed${indentGreen} successfully. ${exitCode0}"
      ;;
    n|N|""|*)
      echo " :: ${indentReset} Aborting installation due to user preference. ${exitCode0}"
      ;;
  esac 
fi

if [[ -d "${cloneDir}/${aurRp}" ]]; then
  echo -n "${indentAction} AUR exists '${cloneDir}/${aurRp}'...."
  rpcachecheck=0
  while true; do
    prompt_timer 120 "${indentAction} Do you want to remove the directory? "
    case $PROMPT_INPUT in
      Y|y)
        if [[ $(stat -c '%U' ${cloneDir}/${aurRp}) = $USER ]] && [[ $(stat -c '%U' ${cloneDir}/${aurRp}/PKGBUILD) = $USER ]]; then
          echo -n " :: ${indentAction} Removing..."
          rm -rf "${cloneDir}/${aurRp}"
		      rpcachecheck=1
          break
        elif [[ $(stat -c '%u' ${cloneDir}/${aurRp}) -eq 0 ]] && [[ $(stat -c '%u' ${cloneDir}/${aurRp}/PKGBUILD) -eq 0 ]]; then
          echo " :: ${indentWarning} The file has ${indentWarning}root${indentWarning} ownership!!! Manual intervention required - ${exitCode1}"
        fi
        ;;
      N|n)
        prompt_timer 120 "${indentAction} !!!? Would you like to use that folder instead?"
        case $PROMPT_INPUT in
          Y|y)
            if [[ -e "${cloneDir}/${aurRp}/PKGBUILD" ]]; then
		          clear
              (cd "${cloneDir}/${aurRp}/" && makepkg -si)
			        clear
              break
            else
              echo "${indentWarning} !!! Something went ${indentWarning}wrong${indentWarning} in our side..."
              if [[ $(stat -c '%U' ${cloneDir}/${aurRp}) = $USER ]] && [[ $(stat -c '%U' ${cloneDir}/${aurRp}/PKGBUILD) = $USER ]]; then
                echo " :: ${indentAction} Retrying the script"
              elif [[ $(stat -c '%u' ${confDir}/${aurRp}) -eq 0 ]] && [[ $(stat -c '%u' ${confDir}/${aurRp}/PKGBUILD) -eq 0 ]]; then
                echo " :: ${indentInfo} The folder has ${indentWarning}root${indentWarning} ownership. Manual intervention required - ${exitCode1}"
                exit 1
              fi
            fi
            ;;
          N|n)
            if [[ $(stat -c '%U' ${cloneDir}/${aurRp}) = $USER ]] && [[ $(stat -c '%U' ${cloneDir}/${aurRp}/PKGBUILD) = $USER ]]; then
              echo " :: ${indentAction} Removing..."
              rm -rf "${cloneDir}/${aurRp}"
			        rpcachecheck=1
              break
            elif [[ $(stat -c '%u' ${cloneDir}/${aurRp}) -eq 0 ]] && [[ $(stat -c '%U' ${cloneDir}/${aurRp}/PKGBUILD) -eq 0 ]]; then
              echo " :: ${indentError} The file has ${indentWarning}root${indentWarning} ownership!!! ${exitCode1}"
            fi
            ;;
          *)
            echo " :: ${indentError} Please answer 'y' or 'n'."
            ;;
        esac
        ;;
      *)
        echo " :: ${IndentError} Please answer 'y' or 'n'."
        ;;
    esac
  done
else
  mkdir -p "${cloneDir}"
  if [[ $check = "Y" ]] || [[ $check = "y" ]]; then
    prompt_timer 120 "${indentAction} Would you like to install yay?"

    case "$PROMPT_INPUT" in
      [Yy]*)
        git clone "https://aur.archlinux.org/${aurRp}.git" "${cloneDir}/${aurRp}" >/dev/null 2>&1
        var=$(stat -c '%U' "${cloneDir}/${aurRp}")
        var1=$(stat -c '%U' "${cloneDir}/${aurRp}/PKGBUILD")

        if [[ $var = "$USER" ]] && [[ $var1 = "$USER" ]]; then
		      clear
          (cd "${cloneDir}/${aurRp}/" && makepkg -si)
		      clear
        fi
        ;;
      [Nn]*|""|*)
        if pkg_installed "yay-bin" 2>/dev/null || pkg_installed "yay" 2>/dev/null; then
          echo -e " :: ${indentAction} ${aurRp} is already ${indentGreen}installed - ${exitCode0}"
        else
          echo " :: ${indentReset} Aborting Installation due to user preference. The installation will not begin if ${aurRp} is not installed. ${exitCode1}"
          exit 1
        fi
        ;;
    esac
  fi
fi

if [[ "$rpcachecheck" -eq 1 ]]; then
  prompt_timer 120 "${indentAction} Would you like to install yay?"
  case "$PROMPT_INPUT" in
    [Yy]*)
      git clone "https://aur.archlinux.org/${aurRp}.git" "${cloneDir}/${aurRp}" >/dev/null 2>&1
      var=$(stat -c '%U' "${cloneDir}/${aurRp}")
      var1=$(stat -c '%U' "${cloneDir}/${aurRp}/PKGBUILD")

      if [[ $var = "$USER" ]] && [[ $var1 = "$USER" ]]; then
	  	  clear
        (cd "${cloneDir}/${aurRp}/" && makepkg -si)
		    clear
      fi
      ;;
    [Nn]*|""|*)
      if pkg_installed "yay-bin" 2>/dev/null || pkg_installed "yay" 2>/dev/null; then
        echo -e " :: ${indentAction} ${aurRp} is already ${indentGreen}installed - ${exitCode0}"
      else
        echo " :: ${indentReset} Aborting Installation due to user preference. The installation will not begin if ${aurRp} is not installed. ${exitCode1}"
        exit 1
      fi
  esac
fi

if [[ $check = "Y" ]] || [[ $check = "y" ]]; then
  while true; do
    if [[ -e "${pkgsRp}" ]]; then
      if [[ $(stat -c '%U' ${pkgsRp}) = $USER ]]; then
        ${pkgsRp} --hyprland
        echo -e " :: ${indentOk} All hyprland packages were ${indentGreen}installed${indentGreen}."
      elif [[ $(stat -c '%u' ${pkgsRp}) -eq 0 ]]; then
        echo " :: ${indentError} The shell script has ${indentWarning}root ownership!!! ${indentWarning}${exitCode1}${indentWarning}"
        exit 1
      fi
      prompt_timer 120 "${indentNotice} Would you like to get additional packages?"
      case "$PROMPT_INPUT" in
        [Yy]*)
          echo -e " :: ${indentAction} Proeeding installation due to User's request."
          ${pkgsRp} --extra
          echo -e " :: ${indentOk} All extra packages were ${indentGreen}installed${indentGreen}"
          ;;
        [Nn]|*)
          echo -e " :: ${indentAction} Avorting installation due to User Preferences."
          ;;
      esac
      prompt_timer 120 "${indentNotice} Would you also like to get driver packages? [Intel Only]"
      case "$PROMPT_INPUT" in
        [Yy]|Yes|yes)
          echo -e " :: ${indentAction} Proceeding installation due to User's request."
          ${pkgsRp} --driver
          echo -e " :: ${indentAction} All driver packages were ${indentGreen}installed${indentGreen}"
          ;;
        [Nn]|No|no)
          echo -e " :: ${indentReset} Avorting installation due to User Preferences."
          ;;
      esac
	    sddmtheme=0
      prompt_timer 120 "${indentInfo} Would you like to get SDDM Theme?"
      case "$PROMPT_INPUT" in
        [Yy]*)
          echo -e " :: ${indentAction} Proceeding installation due to User's request."
          ${pkgsRp} --sddm
          echo -e " :: ${indentAction} SDDM dependencies have been ${indentGreen}installed${indentGreen}."
          sddmtheme=1
          break
          ;;
        [Nn]*)
          echo -e " :: ${indentReset} Avorting themeing SDDM due to User's request."
          sddmtheme=0
          break
          ;;
      esac
    else
      echo " :: ${indentError} The Package DOES NOT EXIST!! ${indentWarning} ${exitCode0}"
      exit 0
    fi
  done
fi

if [[ -d $configDir ]]; then
   if [ ! -d "${confDir}" ]; then
    echo " :: ${indentError} - ${confDir} does not exist. Creating it now."
    mkdir -p ${confDir} && echo " :: ${indentOk} Directory created successfully." || echo " :: ${indentError} Failed to create directory."
  fi
  backupCheck=0
  confcheck="fastfetch kitty rofi swaync btop  hypr ivy-shell Kvantum nwg-look qt6ct waybar wlogout dunst"
  for conf in $confcheck; do
    confpath="${confDir}/${conf}"
    if [[ -d "${confpath}" ]]; then
      while true; do
        echo " :: ${indentInfo} Found ${indentYellow}$conf${indentOrange} config found in ${confDir}/"
        prompt_timer 120 "${indentAction} Do you want to backup ${indentBlue}${conf}${indentReset} config?"
        case "$PROMPT_INPUT" in
          Y|y)
            backupDir=$(get_backup_dirname)
            backupconf="${homDir}/.backup"
            mkdir -p "${backupconf}" 
            mv "${confpath}" "${backupconf}/${conf}-backup-${backupDir}"
            echo -e " :: ${indentNotice} Backed up ${conf} to ${backupconf}/${conf}-backup-${backupDir}"
            backupCheck=1
            break
            ;;
          N|n)
            echo -e " :: ${indentNotice} - Skipping ${indentYellow}${conf}${indentReset}" 2>&1
            break
            ;;
          *)
            echo -e " :: ${indentWarning} - Invalid choice. Please enter Y or N."
            continue
            ;;
        esac
      done
      continue
    else
      if [[ $(stat -c '%U' ${confDir}) = $USER ]]; then
        echo -e " :: ${indentOk} Populating ${confDir}"
        ${scrDir}/dircaller.sh --all ${homDir}/ 2>&1
      elif [[ $(stat -c '%u' ${configDir}) -eq 0 ]]; then
        echo -e " :: ${indentError} The directory is owned by ${indentWarning}root!${indentYellow} ${indentWarning}${exitCode1}${indentWarning}!"
        exit 1
      fi
      break
    fi
  done
  if [[ $backupCheck -eq 1 ]]; then
    if [[ $(stat -c '%U' ${confDir}) = $USER ]]; then
      echo -e " :: ${indentOk} Populating ${confDir}"
      ${scrDir}/dircaller.sh --all ${homDir}/ 2>&1
    elif [[ $(stat -c '%u' ${configDir}) -eq 0 ]]; then
      echo -e " :: ${indentError} The directory is owned by ${indentWarning}root!${indentYellow} ${indentWarning}${exitCode1}${indentWarning}!"
    fi
  fi
  tar -xvf "${sourceDir}/Sweet-cursors.tar.xz" -C "${homDir}/.icons" >/dev/null 2>&1
  clear
  if [[ ! -e "${confDir}/gtk-4.0/assets" ]] || [[ ! -e "${confDir}/gtk-4.0/gtk-dark.css" ]] || [[ -L "${confDir}/gtk-4.0/assets" ]] || [[ -L "${confDir}/gtk-4.0/gtk-dark.css" ]]; then
    ln -sf /usr/share/themes/adw-gtk3/assets "${confDir}/gtk-4.0/assets" 2>&1
    ln -sf /usr/share/themes/adw-gtk3/gtk-4.0/gtk-dark.css "${confDir}/gtk-4.0/gtk-dark.css" 2>&1
    echo -e " :: ${indentOk} GTK Symlink initialized ${indentGreen}."
  fi
  if [[ ! -e "${confDir}/waybar/style.css" ]] || [[ ! -e "${confDir}/waybar/config" ]] || [[ -L "${confDir}/waybar/style.css" ]] || [[ -L "${confDir}/waybar/config" ]]; then
    ln -sf ${confDir}/waybar/Styles/\[BOT\]\ HyDE.css "${confDir}/waybar/style.css" 2>&1
  	ln -sf ${confDir}/waybar/Styles/Configs/\[TOP\]\ HyDE-02.jsonc "${confDir}/waybar/config" 2>&1
  	echo -e " :: ${indentOk} Waybar Configuration reinstated."
  fi
  EDITOR_SET=0
  if pkg_installed "nvim" &>/dev/null; then
    echo -e " :: ${indentInfo} By default, this repository comes with ${indentMagenta}neovim${indentSkyBlue}."
    prompt_timer 20 "${indentAction} Do you want to make ${indentMagenta}neovim${indentSkyBlue} default?" 2>&1
    case $PROMPT_INPUT in
      Y|y)
        update_editor "nvim"
        EDITOR_SET=1
        ;;
      N|n)
        echo -e " :: ${indentNotice} Defaulting to $(echo "$EDITOR"), no ${indentOrange}changes${indentMagenta} were made!"
      ;;
      *)
        echo -e " :: ${indentError} Please say 'y' or 'n'. ${exitCode1}!"
        ;;
    esac
  elif [[ "$EDITOR_SET" -eq 0 ]] && pkg_installed "vim" &>/dev/null; then
    echo -e " :: ${indentInfo} ${indentMagenta}vim${indentYellow} is detected as installed."
    prompt_timer 20 "${indentAction} Do you want to make ${indentMagenta}vim${indentGreen} default?"
    if [[ "$PROMPT_INPUT" == "Y" || "$PROMPT_INPUT" == "y" ]]; then
      update_editor "vim"
      EDITOR_SET=1
    fi
  fi
  if pkg_installed "cava" &>/dev/null; then
    mkdir -p "${confDir}/cava"
    cp "${localDir}/../state/ivy-shell/cava.ivy" "${confDir}/ivy-shell/shell/"    
  fi
  if pkg_installed "vscodium" &>/dev/null; then
  	set +e
    mkdir -p "${homDir}/.vscode-oss/extensions/thehydeproject.wallbash-0.3.6/"
    mkdir -p "${confDir}/VSCodium/User"
	  cp "${localDir}/../state/ivy-shell/VSCodium/User/settings.json" "${confDir}/VSCodium/User"
    cp "${localDir}/../state/ivy-shell/code.ivy" "${confDir}/ivy-shell/shell"
	  if [[ -e "${sourceDir}/Code_Wallbash.vsix" ]]; then
	    unzip -l "${sourceDir}/Code_Wallbash.vsix"
	    unzip -q "${sourceDir}/Code_Wallbash.vsix" -d "${cloneDir}" 
	    cp -r ${cloneDir}/extension/* "${homDir}/.vscode-oss/extensions/thehydeproject.wallbash-0.3.6/"
	  else
	    echo -e " :: ${indentError} - Code_Wallbash.vsix doesn't exist!"
	  fi
	set -e
  fi
  if pkg_installed "vesktop" &>/dev/null; then
    mkdir -p "${confDir}/vesktop/themes"
    cp "${localDir}/../state/ivy-shell/discord.ivy" "${confDir}/ivy-shell/shell/"
  fi
  if pkg_installed "python-pywalfox" &>/dev/null; then
  	cp "${localDir}/../state/ivy-shell/pyfox.ivy" "${confDir}/ivy-shell/shell/"
  fi
  if [[ $sddmtheme -eq 1 ]]; then
    if [[ -f "${sourceDir}/SDDM-Silent.tar.gz" ]]; then
      echo -e " :: Populating ${indentMagenta} SDDM to /usr/share due to user request"
      sleep 1
      sudo chown -R $USER:$USER /usr/share/sddm/themes/* >/dev/null 2>&1
      tar -xvf "${sourceDir}/SDDM-Silent.tar.gz" -C "${cloneDir}/"
      sudo cp "${cloneDir}/silent" "/usr/share/sddm/themes/"
      sudo cp "${localDir}/../state/ivy-shell/sddm/sddm.conf" "/etc/sddm.conf" 2>&1
      if [[ $? -eq 1 ]]; then
        echo " :: Something went wrong while populating SDDM Theme. ${exitCode1}"
      fi
    elif [[ $sddmtheme -eq 0 ]]; then
      rm -rf ${localDir}/../state/ivy-shell/sddm
      rm "${localDir}/sddm-style.sh"
      sed -i '27d' ${hyprDir}/keybinds.conf >/dev/null 2>&1
	    sed -i '/^[[:space:]]*if \[\[ "\$img"/,/^[[:space:]]*fi/ s/^\([[:space:]]\{4,\}\)\(cp .*"\)/\1# \2/' "${localDir}/wbselecgen.sh"
    fi
	set -e
  fi
  var=$(getent passwd "$USER" | cut -d: -f7)
  if [[ $var == "/usr/bin/fish" ]]; then
    echo " :: ${indentOk} Shell is already ${var}. No need to trigger again. ${indentGreen}${exitCode0}"
  else
    while true; do
      prompt_timer 120 "${indentAction} Would you like to switch to fish?"
      case $PROMPT_INPUT in
        Y|y)
          set +e
          echo -e " :: ${indentNotice} Switching the shell to fish"
		      clear
          chsh -s /usr/bin/fish 2>&1
		      clear
          exitstatus=$?
          var1=$(getent passwd "$USER" | cut -d: -f7)

          if [[ $exitstatus -eq 0 ]]; then
            echo -e " :: ${indentOk} Changed from $var to ${indentGreen}$var1${indentOrange} is completed!"
            break
          else
            echo -e " :: ${indentError} Shell change failed? (incorrect passwd?) Try again - ${exitCode1}"
          fi
          ;;
        N|n)
          echo -e " :: ${indentReset} Aborting due to user preference. Keeping ${var} intact."
          break
          ;;
        *|"")
          echo -e " :: ${indentError} Invalid input. Please answer 'y' or 'n' ${exitCode1}"
          ;;
      esac
    done
    set -e
  fi
  prompt_timer 120 "${indentYellow} Would you like to get wallpapers?"
  while true; do
    case "$PROMPT_INPUT" in
      Y|y)
        echo -e " :: ${indentAction} Proceeding pulling repository due to User's repository."
        mkdir -p "${walDir}"
      
        if git clone --depth 1 "https://${repRp}" "${walDir}" >/dev/null 2>&1; then
          echo -e " :: ${indentOk} ${indentMagenta}wallpapers${indentReset} cloned successfully!"
        else
          echo -e " :: ${indentError} Failed to clone ${indentYellow}wallpapers ${exitCode1}"
        fi
        "${localDir}/color-cache.sh" -a
		"${localDir}/color-cache.sh" -d
		"${localDir}/color-cache.sh" -l
        echo -e " :: ${indentOk} ${indentOrange}wallpapers${indentGreen} has been cached by ${localDir}/color-cache.sh"
        break
        ;;
      N|n)
	    mkdir -p "${walDir}"
        echo -e " :: ${indentOk} Pulling wallpapers from source."
        if [[ $PROMPT_INPUT = 'N' ]] || [[ $PROMPT_INPUT = 'n' ]]; then
          mv ${sourceDir}/assets/*.png "${walDir}" && cp -r ${sourceDir}/assets/*.jpg "${walDir}" >/dev/null 2>&1
          echo -e " :: ${indentOk} Some ${indentMagenta}wallpapers${indentReset} copied successfully!"
        else
          echo -e " :: ${indentError} Failed to copy some ${indentYellow}wallpapers - ${exitCode1}"
        fi
        "${localDir}/color-cache.sh" -a
		"${localDir}/color-cache.sh" -d
		"${localDir}/color-cache.sh" -l
        echo -e " :: ${indentOk} ${indentOrange}wallpapers${indentGreen} has been cached by ${localDir}/color-cache.sh"
        break
        ;;
      *)
        echo -e " :: ${indentError} Invalid choice. Please say 'y' or 'n'. ${exitCode1}"
        ;;
    esac
  done
  xdg-user-dirs-update 2>&1
  sudo systemctl enable sddm 2>&1
  echo -e " :: This repository has been installed on the system!"
  read -p "$(echo -e " :: ${indentAction} It is not recommended to use newly installed or upgraded repository without rebooting the system. ${indentSkyBlue} Would you like to reboot? ${indentGreen}(yes/no): ")" answer
  case $answer in
    [Yy]|Yes|yes)
      echo " :: ${indentOk} Rebooting the system. ${exitCode0}"
      systemctl reboot
      ;;
    [Nn]|No|no)
      echo " :: ${indentOk} The system will not reboot ${exitCode0}"
      exit 0
      ;;
    *)
      echo " :: ${indentOk} The system will not reboot. ${exitCode0}"
      exit 0
      ;;
  esac
fi

