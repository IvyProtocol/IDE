#!/usr/bin/env bash
set -euo pipefail

scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalvariable.sh"

pill=${1:-}
pill2=${2:-}
case $pill in
  --h|-h|--help)
    if [[ -z $pill2 ]]; then
cat <<EOF
Fastfetch is a neofetch-like tool for fetching system information and displaying them in a pretty way

Usage: fastfetch <?options>

Informative options:
  -h, --help <?command>                      Display this help message or help for a specific command
  -v, --version                              Show the full version of fastfetch
  --list-config-paths                        List search paths for config files
  --list-data-paths                          List search paths for presets and logos
  --list-logos                               List available logos
  --list-modules                             List available modules
  --list-presets                             List presets that fastfetch knows about
  --list-features                            List the supported features that fastfetch was compiled with
  --print-logos                              Display available logos
  --print-structure                          Display the default structure

Config options:
  -c, --config <config>                      Specify the config file or preset to load

General options:
  --detect-version <?bool>                   Specify whether to detect and display versions of terminal, shell, editor, and others

Logo options:
  -l, --logo <logo>                          Set the logo source. Use "none" to disable the logo
      --logo-type <enum>sh
      Set the type of the logo specified in "--logo"
      --logo-width <num>                     Set the width of the logo (in characters) if it is an image
      --logo-height <num>                    Set the height of the logo (in characters) if it is an image

Display options:
  -s, --structure <structure>                Set the structure of the fetch
EOF
    else
      if [ $pill2 = "show-full"  ]; then
        exec fastfetch --help 
      fi
    fi
  ;;
  --v|-v|--version)
    exec fastfetch -v
    ;;
  --list-logos)
    exec fastfetch --list-logos
    ;;
  --list-config-paths)
    exec fastfetch --list-config-paths
    ;;
  --list-presets)
    exec fastfetch --list-presets
    ;;
  --list-modules)
    exec fastfetch --list-modules
    ;;
  --list-data-paths)
    exec fastfetch --list-data-paths
    ;;
  --list-features)
    exec fastfetch --list-features
    ;;
  --print-logos)
    exec fastfetch --print-logos
    ;;
  --print-structure)
    exec fastfetch --print-structure
    ;;
  --c|-c|--config)
    exec fastfetch --config ${pill2}
    ;;
  --dv|-dv|--detect-version)
    exec fastfetch --detect-version ${pill2}
    ;;
  --s|-s|--structure)
    exec fastfetch --structure ${pill2}
    ;;

  -l|--l|--logo)
    exec fastfetch --logo ${pill2}
    ;;
  --logo-type)
    exec fastfetch --logo-type ${pill2}
    ;;
  --logo-width)
    exec fastfetch --logo-width ${pill2}
    ;;
  --logo-height)
    exec fastfetch --logo-height ${pill2}
    ;;
  *)
    iconDir="${confDir}/fastfetch/icons/"
    if [[ -e "$iconDir" && -r "$iconDir" && -w "$iconDir" ]]; then
      fetch=$(find "$iconDir" -maxdepth 1 -type f | shuf -n 1)
      exec fastfetch -l "$fetch"
      exit 0
    else
      exec fastfetch
    fi
  ;;
esac
