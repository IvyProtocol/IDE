#!/usr/bin/env bash
[[ -f "$HOME/.local/bin/globalcontrol.sh" ]] && source "$HOME/.local/bin/globalcontrol.sh" || echo "$HOME/.local/bin/globalcontrol.sh does not exist!" && exit 1

srcf_rcall env_pkg && [[ $? -ge 1 ]] && echo "[$0]: function {env_pkg} does NOT exist!" && exit 1
env_pkg "$@"
#yes, this is as simple. 
