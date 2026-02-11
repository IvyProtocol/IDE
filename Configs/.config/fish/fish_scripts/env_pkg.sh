#!/usr/bin/env bash
[[ ! -f "$HOME/.local/bin/globalcontrol.sh" ]] && echo "[$0] $HOME/.local/bin/globalcontrol.sh" && exit 1 || source "$HOME/.local/bin/globalcontrol.sh"

srcf_rcall env_pkg && [[ $? -ge 1 ]] && echo "[$0]: function {env_pkg} does NOT exist!" && exit 1
env_pkg "$@"
#yes, this is as simple. 
