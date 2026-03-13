#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC1091


tomlrc="${VYLE_DATA_HOME}/tomlmd/tomlrc.conf"
staterc="${VYLE_DATA_HOME}/tomlmd/staterc"
tomlSh="${VYLE_DATA_HOME}/tomlmd/tomlmainmd.sh"

cp "${VYLE_DATA_HOME}/staterc.conf" "${staterc}"
# Run tomlq // exports the environment!
tomlq -e 

# Source the new staterc.conf. We will compare the changes now with diff.
source "${VYLE_DATA_HOME}/staterc.conf"

# Update tomlSh if staterc.conf changed
if [[ -e "${tomlrc}" && "${tomlSource}" -eq 1 ]]; then
    # normalize both: remove trailing spaces, blank lines
    if ! cmp -s "${VYLE_DATA_HOME}/staterc.conf" "${staterc}" >/dev/null; then
        # Files differ → run envsubst and notify
        envsubst < "${tomlrc}" > "${tomlSh}"
        notify-send -r 91190 -t 1000 -i "${XDG_CONFIG_HOME}/dunst/icons/hyprdots.svg" "Vyle-Project" "Configuration has been reloaded."

    fi
fi

# Synchronize TOML with IDE conf
if [[ -e "${VYLE_CONFIG_HOME}/ide.conf" && -e "${VYLE_CONFIG_HOME}/vyle.toml" ]]; then
    envsubst < "${tomlrc}" > "${VYLE_CONFIG_HOME}/ide.conf"
fi

# Source generated script
source "${tomlSh}"

