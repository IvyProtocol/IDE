if status is-interactive
	starship init fish | source

	alias pamcan pacman
	alias fastfetch="$HOME/.local/bin/fastfetch.sh"
	alias env_pkg="$HOME/.config/fish/fish_scripts/env_pkg.sh"
	alias wbselecgen="$HOME/.local/bin/wbselecgen.sh"
	alias zimg="kitty +kitten icat"
	set EDITOR nvim
end
