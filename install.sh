#!/usr/bin/env bash
set -euo pipefail

ROOT=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
ASSUME_YES=0

usage() {
    printf 'Usage: %s [--yes]\n' "${0##*/}"
}

while (($# > 0)); do
    case $1 in
        --yes)
            ASSUME_YES=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'Unknown argument: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

STOW_PACKAGES=(fish ghostty tmux rex bin starship atuin nvim)
PACMAN_PACKAGES=(
    stow fish fzf atuin tmux ghostty jq starship fnm direnv zoxide eza
    neovim tree-sitter-cli git ripgrep fd lazygit clang stylua prettier
    ttf-jetbrains-mono-nerd
)
BREW_FORMULAE=(
    stow fish fzf atuin tmux jq starship fnm direnv zoxide eza neovim
    tree-sitter-cli git ripgrep fd lazygit clang-format stylua prettier
)
BREW_CASKS=(ghostty font-jetbrains-mono-nerd-font)

case $(uname -s) in
    Linux)
        PROFILE=linux
        PACKAGE_MANAGER=pacman
        command -v pacman >/dev/null 2>&1 || {
            printf 'pacman is required on Linux.\n' >&2
            exit 1
        }
        ;;
    Darwin)
        PROFILE=macos
        PACKAGE_MANAGER=brew
        command -v brew >/dev/null 2>&1 || {
            printf 'Homebrew is required. Install it, then run %s again.\n' "${0##*/}" >&2
            exit 1
        }
        ;;
    *)
        printf 'Only Arch/CachyOS Linux and macOS are supported.\n' >&2
        exit 1
        ;;
esac

[[ -d "$ROOT/profiles/$PROFILE" ]] || {
    printf 'Missing profile: %s\n' "$PROFILE" >&2
    exit 1
}

MISSING_FORMULAE=()
MISSING_CASKS=()
if [[ $PACKAGE_MANAGER == pacman ]]; then
    while IFS= read -r package; do
        [[ -n $package ]] && MISSING_FORMULAE+=("$package")
    done < <(pacman -T "${PACMAN_PACKAGES[@]}" 2>/dev/null || true)
else
    for package in "${BREW_FORMULAE[@]}"; do
        brew list --formula "$package" >/dev/null 2>&1 || MISSING_FORMULAE+=("$package")
    done
    for package in "${BREW_CASKS[@]}"; do
        brew list --cask "$package" >/dev/null 2>&1 || MISSING_CASKS+=("$package")
    done
fi

ACTION_KINDS=()
ACTION_PATHS=()
NEEDS_STOW=0

has_action() {
    local kind=$1 path=$2 index
    for ((index = 0; index < ${#ACTION_KINDS[@]}; index++)); do
        [[ ${ACTION_KINDS[index]} == "$kind" && ${ACTION_PATHS[index]} == "$path" ]] && return 0
    done
    return 1
}

add_action() {
    local kind=$1 path=$2
    has_action "$kind" "$path" && return
    ACTION_KINDS+=("$kind")
    ACTION_PATHS+=("$path")
}

canonical_file() {
    local path=$1 directory base
    directory=$(dirname -- "$path")
    base=$(basename -- "$path")
    printf '%s/%s\n' "$(CDPATH= cd -- "$directory" && pwd -P)" "$base"
}

resolved_link() {
    local link=$1 target
    target=$(readlink "$link")
    case $target in
        /*) ;;
        *) target=$(dirname -- "$link")/$target ;;
    esac
    canonical_file "$target"
}

blocking_ancestor() {
    local path
    path=$(dirname -- "$1")
    while [[ $path == "$HOME"/* && $path != "$HOME" ]]; do
        if [[ -L $path ]]; then
            printf '%s\n' "$path"
            return 0
        fi
        if [[ -e $path && ! -d $path ]]; then
            printf 'Managed path has a non-directory parent: %s\n' "$path" >&2
            exit 1
        fi
        path=$(dirname -- "$path")
    done
    return 1
}

plan_file() {
    local source=$1 destination=$2 ancestor expected actual
    if ancestor=$(blocking_ancestor "$destination"); then
        add_action backup "$ancestor"
        NEEDS_STOW=1
        return
    fi

    if [[ -L $destination ]]; then
        if [[ ! -e $destination ]]; then
            add_action remove "$destination"
            NEEDS_STOW=1
            return
        fi
        expected=$(canonical_file "$source")
        actual=$(resolved_link "$destination")
        if [[ $actual != "$expected" ]]; then
            add_action backup "$destination"
            NEEDS_STOW=1
        fi
        return
    fi

    if [[ -e $destination ]]; then
        if [[ -d $destination ]]; then
            printf 'Managed file destination is a directory: %s\n' "$destination" >&2
            exit 1
        fi
        add_action backup "$destination"
        NEEDS_STOW=1
        return
    fi

    add_action link "$destination"
    NEEDS_STOW=1
}

scan_package() {
    local stow_dir=$1 package=$2 package_root source relative destination
    package_root=$stow_dir/$package
    [[ -d $package_root ]] || {
        printf 'Missing Stow package: %s\n' "$package_root" >&2
        exit 1
    }

    while IFS= read -r -d '' source; do
        relative=${source#"$package_root"/}
        destination=$HOME/$relative
        plan_file "$source" "$destination"
    done < <(find "$package_root" \( -type f -o -type l \) -print0)
}

for package in "${STOW_PACKAGES[@]}"; do
    scan_package "$ROOT" "$package"
done
scan_package "$ROOT/profiles" "$PROFILE"


print_plan() {
    local index
    printf 'Profile: %s\n' "$PROFILE"
    if ((${#MISSING_FORMULAE[@]} > 0)); then
        printf 'Install packages:\n'
        printf '  %s\n' "${MISSING_FORMULAE[@]}"
    fi
    if ((${#MISSING_CASKS[@]} > 0)); then
        printf 'Install casks:\n'
        printf '  %s\n' "${MISSING_CASKS[@]}"
    fi
    for ((index = 0; index < ${#ACTION_KINDS[@]}; index++)); do
        case ${ACTION_KINDS[index]} in
            backup) printf 'Backup and replace: %s\n' "${ACTION_PATHS[index]}" ;;
            remove) printf 'Remove broken link: %s\n' "${ACTION_PATHS[index]}" ;;
            link) printf 'Link: %s\n' "${ACTION_PATHS[index]}" ;;
        esac
    done
}

confirm_apply() {
    ((ASSUME_YES == 1)) && return 0
    printf 'Apply? [y/N] '
    read -r answer || return 1
    [[ $answer == y || $answer == Y ]]
}

install_packages() {
    if [[ $PACKAGE_MANAGER == pacman && ${#MISSING_FORMULAE[@]} -gt 0 ]]; then
        sudo pacman -S --needed -- "${MISSING_FORMULAE[@]}"
    elif [[ $PACKAGE_MANAGER == brew ]]; then
        if ((${#MISSING_FORMULAE[@]} > 0)); then
            HOMEBREW_NO_INSTALL_UPGRADE=1 \
            HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1 \
            HOMEBREW_NO_INSTALL_CLEANUP=1 \
                brew install --formula "${MISSING_FORMULAE[@]}"
        fi
        if ((${#MISSING_CASKS[@]} > 0)); then
            HOMEBREW_NO_INSTALL_CLEANUP=1 brew install --cask "${MISSING_CASKS[@]}"
        fi
    fi
}

apply_file_actions() {
    local backup_root index kind path relative backup
    backup_root=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backups/$(date +%Y%m%d-%H%M%S)
    for ((index = 0; index < ${#ACTION_KINDS[@]}; index++)); do
        kind=${ACTION_KINDS[index]}
        path=${ACTION_PATHS[index]}
        case $kind in
            backup)
                relative=${path#"$HOME"/}
                backup=$backup_root/$relative
                mkdir -p "$(dirname -- "$backup")"
                mv -- "$path" "$backup"
                ;;
            remove)
                rm -- "$path"
                ;;
        esac
    done
}

maybe_set_login_shell() {
    local fish_path current_shell answer
    fish_path=$(command -v fish 2>/dev/null || true)
    [[ -n $fish_path ]] || return

    if [[ $PROFILE == linux ]] && command -v getent >/dev/null 2>&1; then
        current_shell=$(getent passwd "${USER:-$(id -un)}" | awk -F: '{print $7}')
    elif [[ $PROFILE == macos ]] && command -v dscl >/dev/null 2>&1; then
        current_shell=$(dscl . -read "/Users/${USER:-$(id -un)}" UserShell 2>/dev/null | awk '{print $2}')
    else
        current_shell=${SHELL:-}
    fi
    [[ $current_shell == "$fish_path" ]] && return

    if [[ ! -t 0 ]]; then
        printf 'Fish is not the login shell; rerun interactively to change it.\n'
        return
    fi

    printf 'Set Fish as the login shell (%s)? [y/N] ' "$fish_path"
    read -r answer || return
    [[ $answer == y || $answer == Y ]] || return

    if ! grep -Fx -- "$fish_path" /etc/shells >/dev/null 2>&1; then
        printf '%s\n' "$fish_path" | sudo tee -a /etc/shells >/dev/null
    fi
    chsh -s "$fish_path"
}

changes=${#MISSING_FORMULAE[@]}
changes=$((changes + ${#MISSING_CASKS[@]} + ${#ACTION_KINDS[@]}))
if ((changes > 0)); then
    print_plan
    confirm_apply || {
        printf 'Cancelled.\n'
        exit 1
    }
    install_packages
    apply_file_actions
    if ((NEEDS_STOW == 1)); then
        stow --dir="$ROOT" --target="$HOME" --no-folding --restow "${STOW_PACKAGES[@]}"
        stow --dir="$ROOT/profiles" --target="$HOME" --no-folding --restow "$PROFILE"
    fi
    printf 'Dotfiles installed.\n'
else
    printf 'Dotfiles are already installed.\n'
fi

maybe_set_login_shell

if ! command -v rex >/dev/null 2>&1; then
    printf 'Rex is not installed; install it manually if wanted.\n'
fi
printf 'Optional one-time imports:\n'
printf '  atuin import fish\n'
printf '  atuin threads import\n'
printf 'Atuin sync remains manual: atuin sync\n'
