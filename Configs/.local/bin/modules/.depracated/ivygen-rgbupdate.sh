#!/usr/bin/env bash

# Paths
ivy_pp="$HOME/.config/ivy/main/ivygen.dcol"
ivy_target="$HOME/.config/ivy/theme-rgba.ivy"

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
    echo "ivy_pry1_rgba=${ivy[dcol_rrggbb_1_rgba]}"
    echo "ivy_txt1_rgba=${ivy[dcol_rrggbb_2_rgba]}"
    echo "ivy_1xa1_rgba=${ivy[dcol_rrggbb_3_rgba]}"
    echo "ivy_1xa2_rgba=${ivy[dcol_rrggbb_4_rgba]}"
    echo "ivy_1xa3_rgba=${ivy[dcol_rrggbb_5_rgba]}"
    echo "ivy_1xa4_rgba=${ivy[dcol_rrggbb_6_rgba]}"
    echo "ivy_1xa5_rgba=${ivy[dcol_rrggbb_7_rgba]}"
    echo "ivy_1xa6_rgba=${ivy[dcol_rrggbb_8_rgba]}"
    echo "ivy_1xa7_rgba=${ivy[dcol_rrggbb_9_rgba]}"
    echo "ivy_1xa8_rgba=${ivy[dcol_rrggbb_10_rgba]}"
    echo "ivy_1xa9_rgba=${ivy[dcol_rrggbb_11_rgba]}"
   
    echo
    echo "ivy_pry2_rgba=${ivy[dcol_rrggbb_12_rgba]}"
    echo "ivy_txt2_rgba=${ivy[dcol_rrggbb_13_rgba]}"
    echo "ivy_2xa1_rgba=${ivy[dcol_rrggbb_14_rgba]}"
    echo "ivy_2xa2_rgba=${ivy[dcol_rrggbb_15_rgba]}"
    echo "ivy_2xa3_rgba=${ivy[dcol_rrggbb_16_rgba]}"
    echo "ivy_2xa4_rgba=${ivy[dcol_rrggbb_17_rgba]}"
    echo "ivy_2xa5_rgba=${ivy[dcol_rrggbb_18_rgba]}"
    echo "ivy_2xa6_rgba=${ivy[dcol_rrggbb_19_rgba]}"
    echo "ivy_2xa7_rgba=${ivy[dcol_rrggbb_20_rgba]}"
    echo "ivy_2xa8_rgba=${ivy[dcol_rrggbb_21_rgba]}"
    echo "ivy_2xa9_rgba=${ivy[dcol_rrggbb_22_rgba]}"
   
    echo
    echo "ivy_pry3_rgba=${ivy[dcol_rrggbb_23_rgba]}"
    echo "ivy_txt3_rgba=${ivy[dcol_rrggbb_24_rgba]}"
    echo "ivy_3xa1_rgba=${ivy[dcol_rrggbb_25_rgba]}"
    echo "ivy_3xa2_rgba=${ivy[dcol_rrggbb_26_rgba]}"
    echo "ivy_3xa3_rgba=${ivy[dcol_rrggbb_27_rgba]}"
    echo "ivy_3xa4_rgba=${ivy[dcol_rrggbb_28_rgba]}"
    echo "ivy_3xa5_rgba=${ivy[dcol_rrggbb_29_rgba]}"
    echo "ivy_3xa6_rgba=${ivy[dcol_rrggbb_30_rgba]}"
    echo "ivy_3xa7_rgba=${ivy[dcol_rrggbb_31_rgba]}"
    echo "ivy_3xa8_rgba=${ivy[dcol_rrggbb_32_rgba]}"
    echo "ivy_3xa9_rgba=${ivy[dcol_rrggbb_33_rgba]}"

    echo
    echo "ivy_pry4_rgba=${ivy[dcol_rrggbb_34_rgba]}"
    echo "ivy_txt4_rgba=${ivy[dcol_rrggbb_35_rgba]}"
    echo "ivy_4xa1_rgba=${ivy[dcol_rrggbb_36_rgba]}"
    echo "ivy_4xa2_rgba=${ivy[dcol_rrggbb_37_rgba]}"
    echo "ivy_4xa3_rgba=${ivy[dcol_rrggbb_38_rgba]}"
    echo "ivy_4xa4_rgba=${ivy[dcol_rrggbb_39_rgba]}"
    echo "ivy_4xa5_rgba=${ivy[dcol_rrggbb_40_rgba]}"
    echo "ivy_4xa6_rgba=${ivy[dcol_rrggbb_41_rgba]}"
    echo "ivy_4xa7_rgba=${ivy[dcol_rrggbb_42_rgba]}"
    echo "ivy_4xa8_rgba=${ivy[dcol_rrggbb_43_rgba]}"
    echo "ivy_4xa9_rgba=${ivy[dcol_rrggbb_44_rgba]}"
    

} >> "$tmpfile"

# Replace original config safely
mv "$tmpfile" "$ivy_target"

echo "Converted: dcol_* → ivy_*"
