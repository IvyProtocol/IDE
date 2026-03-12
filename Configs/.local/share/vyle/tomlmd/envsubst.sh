#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC1091


tomlrc="${VYLE_DATA_HOME}/tomlmd/tomlrc.conf"
staterc="${VYLE_DATA_HOME}/tomlmd/staterc"
tomlSh="${VYLE_DATA_HOME}/tomlmd/tomlmainmd.sh"

# Backup staterc.conf
cp "${VYLE_DATA_HOME}/staterc.conf" "${staterc}"

# Run tomlq
tomlq -e 

# Source the new staterc.conf
source "${VYLE_DATA_HOME}/staterc.conf"

# Update tomlSh if staterc.conf changed
if [[ -e "${tomlrc}" && "${tomlSource:-0}" -eq 1 ]]; then
    # normalize both: remove trailing spaces, blank lines
    if ! diff -q <(sed 's/[[:space:]]*$//;/^$/d' "${VYLE_DATA_HOME}/staterc.conf") \
                 <(sed 's/[[:space:]]*$//;/^$/d' "${staterc}") >/dev/null; then
        # Files differ → run envsubst and notify
        envsubst < "${tomlrc}" > "${tomlSh}"
    fi
fi

# Synchronize TOML with IDE conf
if [[ -e "${VYLE_CONFIG_HOME}/ide.conf" && -e "${VYLE_CONFIG_HOME}/vyle.toml" ]]; then
    envsubst < "${tomlrc}" > "${VYLE_CONFIG_HOME}/ide.conf"
fi

# Source generated script
source "${tomlSh}"
