#!/usr/bin/env bash

# Paths
ivy_pp="$HOME/.config/ivy/main/ivygen.dcol"
ivy_target="$HOME/.config/ivy/theme.ivy"

if [[ "$EUID" -eq 0 ]]; then
  echo "ivygen must not be run as root." >&2
  exit 1
fi
# ----------------- Read ivy colors -----------------
declare -A ivy

while IFS='=' read -r key val; do
    # skip empty lines
    [[ -z "$key" || -z "$val" ]] && continue
    ivy["$key"]="$val"
done < "$ivy_pp"

# ----------------- Update Kitty config -----------------
tmpfile=$(mktemp)

# Append theme lines using ivy variables
{
    echo
    echo "ivy_pry1=${ivy[dcol_rrggbb_1]}"
    echo "ivy_txt1=${ivy[dcol_rrggbb_2]}"
    echo "ivy_1xa1=${ivy[dcol_rrggbb_3]}"
    echo "ivy_1xa2=${ivy[dcol_rrggbb_4]}"
    echo "ivy_1xa3=${ivy[dcol_rrggbb_5]}"
    echo "ivy_1xa4=${ivy[dcol_rrggbb_6]}"
    echo "ivy_1xa5=${ivy[dcol_rrggbb_7]}"
    echo "ivy_1xa6=${ivy[dcol_rrggbb_8]}"
    echo "ivy_1xa7=${ivy[dcol_rrggbb_9]}"
    echo "ivy_1xa8=${ivy[dcol_rrggbb_10]}"
    echo "ivy_1xa9=${ivy[dcol_rrggbb_11]}"
   
    echo
    echo "ivy_pry2=${ivy[dcol_rrggbb_12]}"
    echo "ivy_txt2=${ivy[dcol_rrggbb_13]}"
    echo "ivy_2xa1=${ivy[dcol_rrggbb_14]}"
    echo "ivy_2xa2=${ivy[dcol_rrggbb_15]}"
    echo "ivy_2xa3=${ivy[dcol_rrggbb_16]}"
    echo "ivy_2xa4=${ivy[dcol_rrggbb_17]}"
    echo "ivy_2xa5=${ivy[dcol_rrggbb_18]}"
    echo "ivy_2xa6=${ivy[dcol_rrggbb_19]}"
    echo "ivy_2xa7=${ivy[dcol_rrggbb_20]}"
    echo "ivy_2xa8=${ivy[dcol_rrggbb_21]}"
    echo "ivy_2xa9=${ivy[dcol_rrggbb_22]}"
   
    echo
    echo "ivy_pry3=${ivy[dcol_rrggbb_23]}"
    echo "ivy_txt3=${ivy[dcol_rrggbb_24]}"
    echo "ivy_3xa1=${ivy[dcol_rrggbb_25]}"
    echo "ivy_3xa2=${ivy[dcol_rrggbb_26]}"
    echo "ivy_3xa3=${ivy[dcol_rrggbb_27]}"
    echo "ivy_3xa4=${ivy[dcol_rrggbb_28]}"
    echo "ivy_3xa5=${ivy[dcol_rrggbb_29]}"
    echo "ivy_3xa6=${ivy[dcol_rrggbb_30]}"
    echo "ivy_3xa7=${ivy[dcol_rrggbb_31]}"
    echo "ivy_3xa8=${ivy[dcol_rrggbb_32]}"
    echo "ivy_3xa9=${ivy[dcol_rrggbb_33]}"

    echo
    echo "ivy_pry4=${ivy[dcol_rrggbb_34]}"
    echo "ivy_txt4=${ivy[dcol_rrggbb_35]}"
    echo "ivy_4xa1=${ivy[dcol_rrggbb_36]}"
    echo "ivy_4xa2=${ivy[dcol_rrggbb_37]}"
    echo "ivy_4xa3=${ivy[dcol_rrggbb_38]}"
    echo "ivy_4xa4=${ivy[dcol_rrggbb_39]}"
    echo "ivy_4xa5=${ivy[dcol_rrggbb_40]}"
    echo "ivy_4xa6=${ivy[dcol_rrggbb_41]}"
    echo "ivy_4xa7=${ivy[dcol_rrggbb_42]}"
    echo "ivy_4xa8=${ivy[dcol_rrggbb_43]}"
    echo "ivy_4xa9=${ivy[dcol_rrggbb_44]}"
    

} >> "$tmpfile"

# Replace original config safely
mv "$tmpfile" "$ivy_target"

echo "Converted: dcol_* → ivy_*"
