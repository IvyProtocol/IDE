#!/usr/bin/env bash
set -eo pipefail
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"

pxCheck="${1:-}"

echo -e " :: THIS SCRIPT HAS BEEN DEPRECATED! Use ${scrDir}/wbselecgen.sh!"

case "${pxCheck}" in
    -p|-n|-r)
        "${scrDir}/wbselecgen.sh" "${pxCheck}"
        ;;
    *)
        return 1 ;;
esac >/dev/null

