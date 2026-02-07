#!/usr/bin/env bash
set -euo pipefail

# -----------------------
# Configuration
# -----------------------
scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/../globalcontrol.sh"

wbDir="${ideDir}"
shellDir="${1:-${wbDir}/theme/${ideTheme}}"
targetDir="${2:-${XDG_CACHE_HOME:-$HOME/.cache}/wal/wal-dir/}"
mkdir -p "$targetDir"

confDir="${confDir}"
cacheDir="${cacheDir}"
homDir="${homDir}"

[[ -z "${plLoader}" ]] && plLoader="ivy"

# -----------------------
# Early Fallback Check
# -----------------------
[[ "$EUID" -eq 0 ]] && echo "[$0] must not be run as root." >&2 && exit 1
#[[ ! -e "${shellDir}" ]] && echo "[$0] no dcol/ivy file found. Nothing to apply!" && exit 0

 if ! find "$shellDir" -type f \( -name '*.dcol' -o -name '*.ivy' -o -name '*.theme' \) -print -quit | grep -q .; then
    echo "ivygen-helper: no .dcol or .ivy templates found, nothing to apply."
    exit 0
fi

# -----------------------
# Load palette files
# -----------------------
[[ -f "$wbDir/theme.ivy" ]] && load_ivy_file "$wbDir/theme.ivy"
[[ -f "$wbDir/theme-rgba.ivy" ]] && load_ivy_file "$wbDir/theme-rgba.ivy"

if ! compgen -v | grep -Eq "^(${plLoader})_"; then
    echo "ivygen-helper: no palette variables loaded, nothing to apply."
    exit 0
fi

# -----------------------
# Template processing function
# -----------------------
process_template() {
    set +u
    local template_file="$1"
    
    case "$template_file" in
    *.dcol|*.ivy|*.theme) ;;
    *)
        echo "ivygen-helper: unsupported template type: $template_file" >&2
        return 0
        ;;
    esac

    # Read first line and trim spaces
    read -r raw_first_line < "$template_file"
    local first_line
    first_line="$(printf "%s" "$raw_first_line" | sed 's/[[:space:]]*$//')"

    # Remove first line from template content
    local template_content
    template_content=$(<"$template_file")
    template_content="${template_content#*$'\n'}"

    # Determine target and optional script
    local target script=""
    if [[ "$first_line" == *"|"* ]]; then
        target="${first_line%%|*}"
        script="${first_line##*|}"
    elif [[ -n "$first_line" ]]; then
        target="$first_line"
    else
        rel="$(realpath --relative-to="$shellDir" "$template_file")"
        case "$rel" in
            *.dcol) target="$targetDir/$(rel%.dcol)" ;;
            *.ivy)  target="$targetDir/$(rel%.ivy)" ;;
        esac
    fi

    # Expand special variables
    target="${target//\$(scrDir)/$scrDir}"
    target="${target//\$(confDir)/$confDir}"
    target="${target//\$(cacheDir)/$cacheDir}"
    target="${target//\$(homDir)/$homDir}"
    [[ -n "$script" ]] && script="${script//\$(scrDir)/$scrDir}"
    [[ -n "$script" ]] && script="${script//\$(confDir)/$confDir}"
    [[ -n "$script" ]] && script="${script//\$(cacheDir)/$cacheDir}"
    [[ -n "$script" ]] && script="${script//\$(homDir)/$homDir}"

    # Replace placeholders
    for var in $(compgen -v | grep -E "^(${plLoader})_" ); do
        value="${!var}"       # original value
        placeholder="<${var}>"

    # 1) Replace simple <wallbash_XXXX>
        template_content="${template_content//${placeholder}/${value}}"

    # 2) Replace <wallbash_XXXX_rgba>
        if [[ "$var" == *_rgba ]]; then
            placeholder_rgba="<${var}>"
            template_content="${template_content//${placeholder_rgba}/${value}}"

        # 3) Replace <wallbash_XXXX_rgba(X)>
        # Use regex to find all occurrences with optional alpha
            while [[ "$template_content" =~ \<${var}\(([0-9.]+)\)\> ]]; do
                alpha="${BASH_REMATCH[1]}"
                if [[ "$value" =~ rgba\(([0-9]+),([0-9]+),([0-9]+),([0-9.]+)\) ]]; then
                    r="${BASH_REMATCH[1]}"
                    g="${BASH_REMATCH[2]}"
                    b="${BASH_REMATCH[3]}"
                    template_content="${template_content//<${var}(${alpha})>/rgba($r,$g,$b,$alpha)}"
                else
                # Fallback: remove placeholder if badly formatted
                    template_content="${template_content//<${var}(${alpha})>/$value}"
                fi
            done
        fi
    done


    # -----------------------
    # Write template output
    # -----------------------
    mkdir -p "$(dirname "$target")"
    if [[ ! -f "$target" || "$(cat "$target")" != "$template_content" ]]; then
        printf "%s" "$template_content" > "$target" 
        echo "Generated: $target"
    else
        echo "Skipped (unchanged): $target"
        exit 0
    fi

    # -----------------------
    # Execute optional script safely
    # -----------------------
    if [[ -n "$script" ]]; then
        # Inline commands prefixed with $RUN:
        if [[ "$script" == \$RUN:* ]]; then
            bash -c "${script#\$RUN:}"
        # Executable file
        elif [[ -x "$script" ]]; then
            "$script"
        else
            echo "Skipped non-executable script: $script"
        fi
    fi
    set -u
}

export -f process_template setConf
export scrDir confDir cacheDir targetDir homDir shellDir plLoader
for var in $(compgen -v | grep -E "^(${plLoader})_"); do export "$var"; done

# -----------------------
# Run templates in parallel
# -----------------------
find "$shellDir" -type f \( -name '*.dcol' -o -name '*.ivy' -o -name '*.theme' \) -print0 \
    | xargs -0 -n 1 -P 3 bash -c 'process_template "$@"' _
