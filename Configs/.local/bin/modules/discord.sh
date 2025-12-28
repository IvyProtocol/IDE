#!/usr/bin/env bash
source ./globalvariable.sh
dQuickCss=$(jq -r '.useQuickCss' "$confDir/vesktop/settings/settings.json")
subTarget="$confDir/vesktop"

if [[ -f ${subTarget} || "$dQuickCss" == "false" ]]; then
  if pgrep -x "vesktop" > /dev/null; then
    wid=$(xdotool search --classname vesktop | head -n1)
    xdotool key --window "$wid" ctrl+r
  else
    echo "Vesktop is not running in the process"
  fi
else
  if [[ "$dQuickCss" == "true" ]]; then
    printf 'Uh oh!'
    printf "\nIt seems like you are using Quickcss."
    exit 0
  fi
  exit 0
fi


