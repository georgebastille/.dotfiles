source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
     echo "Well hello there Handsome!"
end

alias paru='nice -n 10 ionice -c3 paru'

# Auto-start or attach tmux on interactive shell
if status is-interactive
    if not set -q TMUX
        if tmux has-session 2>/dev/null
            tmux attach
        else
            tmux new
        end
    end
end

alias paru='nice -n 19 ionice -c 3 paru'
