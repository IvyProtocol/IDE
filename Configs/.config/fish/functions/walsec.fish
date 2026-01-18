function walsec
    set script "$HOME/.local/bin/wbselecgen.sh"

    # No arguments → open selector
    if test (count $argv) -eq 0
        "$script"
        return
    end
    set img $argv[1]

    if not test -f "$img"
        echo "Invalid image format: $img"
        return 1
    end
    "$script" $argv
end

