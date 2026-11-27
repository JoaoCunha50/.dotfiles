set -gx BUN_INSTALL "$HOME/.bun"

if test (uname) = Darwin
    set -gx ANDROID_HOME "$HOME/Library/Android/sdk"
    set -gx ANDROID_SDK_ROOT "$ANDROID_HOME"
end

set -g DOTFILES_PATHS \
    "$HOME/.local/scripts" \
    "$HOME/.local/bin" \
    "$HOME/.opencode/bin"

fish_add_path --global --move $DOTFILES_PATHS

if status is-interactive
    function starship_transient_prompt_func
        starship module character
    end

    if type -q starship; and test "$TERM" != linux
        starship init fish | source
        enable_transience
    end

    if type -q fnm
        fnm env --use-on-cd --shell fish | source
    end

    type -q direnv; and direnv hook fish | source
    type -q zoxide; and zoxide init fish --cmd cd | source

    # Fish vi mode otherwise changes insert mode to a line cursor.
    set -g fish_cursor_default block
    set -g fish_cursor_insert block
    set -g fish_cursor_replace_one block
    set -g fish_cursor_visual block

    fish_vi_key_bindings

    if type -q fzf
        fzf --fish | source
    end

    if type -q atuin
        atuin init fish --disable-up-arrow | source
    end

    if functions -q fzf-cd-widget
        bind -M insert f2 fzf-cd-widget
        bind -M default f2 fzf-cd-widget
    end

    if functions -q _atuin_search
        bind -M insert \cr _atuin_search
        bind -M default \cr _atuin_search
    end

    if functions -q _atuin_ai_resume
        bind -M insert \cg _atuin_ai_resume
        bind -M default \cg _atuin_ai_resume
    end

    if type -q eza
        alias ls 'eza -lh --group-directories-first --icons=auto'
        alias lsa 'ls -a'
        alias lt 'eza --tree --level=2 --long --icons --git'
        alias lta 'lt -a'
    end

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

    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias celar "printf '\033[2J\033[3J\033[1;1H'"
    alias claer "printf '\033[2J\033[3J\033[1;1H'"
    alias pamcan pacman
end
