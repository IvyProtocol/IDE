#!/usr/bin/env bash
scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/../globalcontrol.sh"

declare -A ivy

while IFS= read -r line || [[ -n $line ]]; do
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"

  [[ -z $line || $line == \#* ]] && continue
  [[ $line != dcol_* ]] && continue
  key="${line%%=*}"
  val="${line#*=}"

  key="${key%"${key##*[![:space:]]}"}"
  key="${key#"${key%%[![:space:]]*}"}"
  val="${val//\\/}"
  val="${val//\"/}"

  ivy["$key"]="$val"
done < "${ideDir}/main/ivygen.dcol"

generate_theme() {
  local suffix="$1"
  local target="$2"
  local src_suffix="$3"

  local tmpfile="$(mktemp)"

  {
    echo
    for block in {1..4}; do

      echo "ivy_pry${block}${suffix}=${ivy[dcol_pry$((block))${src_suffix}]}"
      echo "ivy_txt${block}${suffix}=${ivy[dcol_txt$((block))${src_suffix}]}"

      for i in {1..9}; do
        echo "ivy_$(((block)))xa${i}${suffix}=${ivy[dcol_$((block))xa${i}${src_suffix}]}"
      done

    done
  } > "$tmpfile"
  mv "${tmpfile}" "$target"
}

generate_theme "" "${ideDir}/theme.ivy" ""
generate_theme "_rgba" "${ideDir}/theme-rgba.ivy" "_rgba"

echo "Generated"
