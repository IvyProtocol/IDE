#!/usr/bin/env bash
set -eo pipefail

scrDir="$(dirname "$(realpath "${0}")")"
source "${scrDir}/globalcontrol.sh"

#// Credits to sl1ng for the orginal script. Rewritten by Vyle.
ctlcheck=("pactl" "jq" "notify-send" "awk" "pgrep" "hyprctl" "iconv")
missing=()

for ctl in "${ctlcheck[@]}"; do
  command -v "${ctl}" >/dev/null || missing+=("${ctl}")
done

if (( ${#missing[@]} )); then
  echo "Missing required dependencies: \"${missing[*]}\"" >&2
  exit 1
fi

#// Parse .pid, .class, .title to __pid, __class, __title.
active_json="$(hyprctl -j activewindow 2>/dev/null)" || { echo "Did hyprctl fail to run? [EXIT-CODE:-1]" >&2; exit 1; }
PID="$(jq -r '"\(.pid)\t\(.class)\t\(.title)\t\(.initialTitle)"' <<< "${active_json}")" || { echo "Did jq fail to run? [EXIT-CODE:-1]" >&2; exit 1; }

IFS=$'\t' read -r __pid __class __title __intTitle <<< "${PID}"

[[ -z "${__pid}" || "${__pid}" == "null" || "${__pid}" -le 0 ]] 2>/dev/null && { echo "Could not resolve PID for focused window." >&2; exit 1; }
sink_json="$(pactl -f json list sink-inputs 2>/dev/null | iconv -f utf-8 -t utf-8 -c)" || { echo "Did pactl or iconv fail to run? Required manual intervention." >&2; exit 1; }

#// Check if the __pid matches application.process.id or else verify other statements.
mapfile -t sink_ids < <(jq -r --arg pid "${__pid}" --arg class "${__class}" --arg title "${__title}" '
.[] |
 def lc(x): (x // "" | ascii_downcase);
  def normalize(x): x | gsub("[-_~.]+";" ") ;
  select(
  (.properties["application.process.id"] // "") == $pid
  or
  ($class != "" and (lc(.properties["application.name"]) | contains(lc($class))))
  or
  ($class != "" and (lc(.properties["application.id"]) | contains(lc($class))))
  or
  ($class != "" and (lc(.properties["application.process.binary"]) | contains(lc($class))))
  or
  ($title != "" and (normalize(lc(.properties["media.name"])) | contains(normalize(lc($title)))))
  ) | .index' <<< "${sink_json}"
)

if [[ "${#sink_ids[@]}" -eq 0 ]]; then
  fallback_pid="$(pgrep -x "${__class}" | head -n 1 || true)"
  if [[ -n "${fallback_pid}" ]]; then
    mapfile -t sink_ids < <( jq -r --arg pid "${fallback_pid}" '.[] |
      select(.properties["application.process.id"] == $pid) | .index' <<< "${sink_json}" )
  fi
fi

#// Detect $HYPRLAND_INSTANCE_SIGNATURE to trigger and dispatch error code.
if [[ ${#sink_ids[@]} -eq 0 ]]; then
  if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE}" ]]; then
    # If even the fallback_pid remains empty, we will dispatch exit code based on $HYPRLAND_INSTANCE_SIGNATURE.
    notify-send -a "t1" -r 91190 -t 1200 -i "${dunstDir}/icons/hyprdots.svg" "No sink input available."
    echo "No sink input for focused window: ${__class}" >&2
    exit 1
  else
    echo "No sink input for focused active_window ${__class}" >&2
    exit 1
  fi
fi

idsJson=$(printf '%s\n' "${sink_ids[@]}" | jq -s 'map(tonumber)')

#// Get the available option from pactl.
want_mute=$(jq -r --argjson ids "$idsJson" '
    [ .[] | select(.index as $i | $ids | index($i)) | .mute ] as $m |
    if all($m[]; . == true) then "no"
    else "yes"
    end' <<< "${sink_json}"
)

if [[ "${want_mute}" == "no" ]]; then
  state_msg="Unmuted"
  swayIcon="${dunstDir}/icons/vol/unmuted-speaker.svg"
else
  state_msg="Muted"
  swayIcon="${dunstDir}/icons/vol/muted-speaker.svg"
fi

[[ -f "${swayIcon}" ]] || { echo -e "Missing swaync icons." >&2; swayIcon=""; }

errors=0
for id in "${sink_ids[@]}"; do
  pactl set-sink-input-mute "$id" "$want_mute" ||  ((++errors)) 
done

if ((errors)); then
  echo -e "pactl failed to set \"${id}\" to be \"${state_msg}\"! Manual intervention required." >&2
  notify-send -a "t1" -r 91190 -t 1200 -i "${dunstDir}/hyprdots.svg" "Failed to set \"${id}\" to be \"${state_msg}\"!"
else
  # // Append paxmier to get a nice result. Pamixer is complete optional here.
  if command -v pamixer >/dev/null; then
    notify-send -a "t2" -r 91190 -i "${swayIcon}" "${state_msg} ${__intTitle}" "$(pamixer --get-default-sink | awk -F '"' 'END{print $(NF - 1)}')"
  else
    notify-send -a "t2" -r 91190 -t 800 -i "${swayIcon}" "${state_msg} ${__class}"
  fi
fi

