if status is-interactive
	#set -U fish_greeting ""
	starship init fish | source

	alias pamcan pacman
	alias fastfetch="$HOME/.local/bin/fastfetch.sh"
	alias env_pkg="$HOME/.config/fish/fish_scripts/env_pkg.sh"
	alias wbselecgen="$HOME/.local/bin/wbselecgen.sh"
	alias zimg="kitty +kitten icat"
	alias themeswitch="$HOME/.local/bin/themeswitch.sh"
	alias lumine-switch="$HOME/.local/bin/lumine-switch.sh"
	alias wbsecrandom="$HOME/.local/bin/wbsecrandom.sh"
	set EDITOR nvim
end
