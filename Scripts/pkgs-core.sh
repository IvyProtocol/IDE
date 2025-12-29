#!/usr/bin/env bash

hyprland=( 
  base
  base-devel
  efibootmgr
  thermald
  os-prober
  tuned-ppd
  pacman-contrib
  cpupower
  brightnessctl
  
  hyprland
  hyprlock
  hypridle
  sddm
  waybar
  xdg-desktop-portal-hyprland
  xdg-desktop-portal-gtk
  xdg-user-dirs
  polkit-gnome
  wlogout
  kxmlgui5
  adw-gtk-theme

  bluez-utils
  bluetui
  iwd
  network-manager-applet
  wireless_tools

  alsa-utils
  pipewire-alsa
  pipewire-pulse
  gst-plugin-pipewire
  mpd
  mpc
  ncmpcpp
  pavucontrol
  pamixer

  inotify-tools
  jq
  file-roller
  ncdu
  parallel
  unzip
  xdotool
  wl-clip-persist
  cliphist
  nvim
  imagemagick
  qt6-imageformats
  qt6-wayland
  smartmontools
  swww

  fish
  starship
  fastfetch

  firefox
  dolphin
  kitty
  rofi
  loupe
  kvantum
  qt6ct-kde
  kde-cli-tools
  nwg-look
  gnome-disk-utility
  gnome-system-monitor
  swaync
  
  ttf-cascadia-code-nerd
  ttf-fira-mono
  ttf-jetbrains-mono-nerd
  ttf-segoe-ui-variable
  tela-circle-icon-theme-dracula
)

extra=(
  gnome-sound-recorder
  vesktop
  vscodium
  python-pywalfox
  btop
  cava
  wl-screenrec
)

driver=(
  vulkan-intel
  xf86-video-ati
  acpi
  acpi_call
  acpid
  tp_smapi
  intel-media-driver
  intel-ucode
  libva-intel-driver
  libva-utils
  mesa-utils
  vulkan-headers
)

scrDir="$(dirname "$(realpath "$0")")"
source "$scrDir/globalfunction.sh"
var="$1"
 
case $var in
  --hyprland)
    install_package "${hyprland[@]}"
    ;;
  --extra)
    install_package "${extra[@]}"
    ;;
  --driver)
    install_package "${driver[@]}"
    ;;
  *|"")
    exit 0
    ;;
esac
