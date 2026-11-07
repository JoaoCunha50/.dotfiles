if status is-interactive
    function starship_transient_prompt_func
        starship module character
    end

    if test "$TERM" != "linux"
        starship init fish | source
        enable_transience
    end

    # fnm
    fnm env --use-on-cd --shell fish | source

    # Direnv + Zoxide
    command -v direnv &> /dev/null && direnv hook fish | source
    command -v zoxide &> /dev/null && zoxide init fish --cmd cd | source

    if command -v fzf >/dev/null 2>&1
        fzf --fish | source
    end

    if command -v eza >/dev/null 2>&1
        alias ls 'eza -lh --group-directories-first --icons=auto'
        alias lsa 'ls -a'
        alias lt 'eza --tree --level=2 --long --icons --git'
        alias lta 'lt -a'
    end

    # Abbrs
    abbr lg 'lazygit'
    abbr gd 'git diff'
    abbr ga 'git add .'
    abbr gc 'git commit -am'
    abbr gl 'git log'
    abbr gs 'git status'
    abbr gst 'git stash'
    abbr gsp 'git stash pop'
    abbr gp 'git push'
    abbr gpl 'git pull'
    abbr gsw 'git switch'
    abbr gsm 'git switch main'
    abbr gb 'git branch'
    abbr gbd 'git branch -d'
    abbr gco 'git checkout'
    abbr gsh 'git show'

    abbr l 'ls'
    abbr ll 'ls -l'
    abbr la 'ls -a'
    abbr lla 'ls -la'

    abbr edit 'nvim'

    # Alias
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias celar "printf '\033[2J\033[3J\033[1;1H'"
    alias claer "printf '\033[2J\033[3J\033[1;1H'"
    alias pamcan pacman

    fish_add_path $HOME/.opencode/bin
    fish_add_path $HOME/.local/bin
    fish_add_path $HOME/.local/scripts

    if set -q TERM; and test "$TERM" = "xterm-kitty"
        function kitty
            kitty @ launch --type=tab --cwd ~/ --tab-title "home"
        end

        function dev
            kitty @ launch --type=tab --cwd ~/dev --tab-title "dev"
        end

        function configs
            kitty @ launch --type=tab --cwd ~/.config --tab-title "configs"
        end

        function study
            kitty @ launch --type=tab --cwd ~/studys --tab-title "study"
        end
    end
end
