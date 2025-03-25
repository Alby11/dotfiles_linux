# vim: ft=zsh
#
# NOTE: Revised .zshrc
#

# Start debug logging if ZSH_DEBUG is set
ZSH_DEBUG_LOG_STARTFILE "${(%):-%N}"

# Set catppuccin flavours variables
source "$ZDOTDIR/.zcolors_catppuccin"

# LS and Eza colors
if command -v vivid > /dev/null 2>&1; then
    export LS_COLORS="$(vivid generate catppuccin-mocha)"
else
    echo "vivid not found, using default LS_COLORS"
    cargo install vivid
fi

# Enable Starship prompt
[[ ! $(command -v starship) ]] && \
    # curl -sS https://starship.rs/install.sh | sh
    echo "Starship not found, please install it manually"
[[ -f $XDG_CONFIG_HOME/starship/starship.toml ]] && \
    export STARSHIP_CONFIG=$XDG_CONFIG_HOME/starship/starship.toml
    eval "$(starship init zsh)"

# Set options for better shell experience
export COMPLETION_WAITING_DOTS="true"
export ENABLE_CORRECTION="true"
export HIST_STAMPS="%d/%m/%y %T"
export HISTFILE="$HOME/.local/share/zsh_history/.zsh_history"
export SAVEHIST=100000 # Number of history entries to save
export HISTSIZE=100000 # Number of commands to remember in history
export HISTFILESIZE=$HISTSIZE
mkdir -p "$(dirname $HISTFILE)"

# Enable various Zsh options
setopt EXTENDED_HISTORY           # Save timestamp of command in history
setopt HIST_IGNORE_SPACE          # Ignore commands starting with space
setopt auto_cd                    # Change to directory without 'cd'
setopt autocd                     # Automatically change to a directory when you type its name
setopt correct                    # Correct minor typos in directory names
setopt extendedglob               # Enable extended pattern matching
setopt histignorealldups          # Remove duplicate entries from history
setopt inc_append_history         # Add commands to history file as they are typed
setopt interactivecomments        # interpret # as comments during interactive sessions
setopt nonomatch                  # Avoid errors when no file matches a pattern
setopt sharehistory               # Share command history across multiple sessions

# Load all Zsh modules
for module in $(zmodload -L | awk '{print $2}'); do
    zmodload "$module"
done

# Shell setup for fnm NodeJS Manager
if ! command -v fnm > /dev/null 2>&1; then
    cargo install fnm
fi
eval "$(fnm env --use-on-cd)"
if ! command -v node > /dev/null 2>&1; then
    fnm install --lts
fi

# Set EDITOR
[[ -f $ZDOTDIR/.zeditor ]] && source "$ZDOTDIR/.zeditor"

# Set Zsh as VSCode default shell for the integrated terminal
if [[ "$TERM_PROGRAM" = "vscode" ]]; then
    vscode_shell_integration_path=$(code --locate-shell-integration-path zsh)
    if [[ -f "$vscode_shell_integration_path" ]]; then
        # shellcheck disable=SC1090
        source "$vscode_shell_integration_path"
    fi
fi


# Antidote setup for managing plugins
source "$ZDOTDIR/.zantidote"

# Github CLI Copilot support
[[ ! $(command -v gh) ]] && \
    # package_manager_install gh &&
    # gh auth login --web
    echo "gh not found, please install it manually"
[[ ! $(gh copilot) ]] && \
    gh extension install github/gh-copilot --force
eval "$(gh copilot alias -- zsh)"

# Navi widget for Zsh
[[ ! $(command -v navi) ]] && \
    # package_manager_install navi
    echo "navi not found, please install it manually"
eval "$(navi widget zsh)"

# Load custom configurations
source "$ZDOTDIR/.zaliases"

# Zoxide
[[ ! $(command -v zoxide) ]] && \
    # package_manager_install zoxide
    echo "zoxide not found, please install it manually"
eval "$(zoxide init zsh)" 

# Atuin setup
[[ ! -f ${HOME}/.atuin/bin/atuin ]] && \
    # curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    echo "Atuin not found, please install it manually"
source "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

## default key bindings
source "$ZDOTDIR/.zemacs"

# End debug logging if ZSH_DEBUG is set
ZSH_DEBUG_LOG_ENDFILE "Dotfiles processing complete:\n${(%):-%N}"