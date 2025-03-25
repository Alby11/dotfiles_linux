# Revised .zshenv
# vim: ft=zsh
# 
# NOTE: Revised .zshenv
# 

# Ensure a user-defined ZDOTDIR or default to HOME
export XDG_CONFIG_HOME=${HOME}/.config
export ZDOTDIR=${XDG_CONFIG_HOME}/zsh
mkdir -p ${ZDOTDIR}

# Profile debug system
export ZSH_DEBUG=1
if [ "$ZSH_DEBUG" -eq 1 ]; then
    echo "\n\n++++++++++++++++++++++++++++++++++++" > ${ZDOTDIR}/.zsh_debug.log
    echo "$SHELL dotfiles setup starts here...\n" >> ${ZDOTDIR}/.zsh_debug.log
else
    rm -fv ${ZDOTDIR}/.zsh_debug.log
fi

ZSH_DEBUG_LOG_STARTFILE() {
    if [ "$ZSH_DEBUG" -eq 1 ]; then
    echo "\n\n------------------------------------" >> ${ZDOTDIR}/.zsh_debug.log
        # Add a timestamp
        date +"%Y-%m-%d %H:%M:%S" >> ${ZDOTDIR}/.zsh_debug.log
        # Log that the file has been sourced
        echo "$1 is being sourced" >> ${ZDOTDIR}/.zsh_debug.log
    fi
}

ZSH_DEBUG_LOG_ENDFILE() {
    if [ "$ZSH_DEBUG" -eq 1 ]; then
        # Add a timestamp
        date +"%Y-%m-%d %H:%M:%S" >> ${ZDOTDIR}/.zsh_debug.log
        # Log that the file has been sourced
        echo "$1 has been sourced" >> ${ZDOTDIR}/.zsh_debug.log
    echo "\n\n------------------------------------" >> ${ZDOTDIR}/.zsh_debug.log
    fi
}

ZSH_DEBUG_LOG_STARTFILE "${(%):-%N}"

# Autostart tmux if conditions are met
if command -v tmux &> /dev/null && \
   [ -n "$PS1" ] && \
   [[ ! "$TERM" =~ screen ]] && \
   [[ ! "$TERM" =~ tmux ]] && \
   [ -z "$TMUX" ]; then
    # Determine the terminal emulator by checking the parent process name.
    parent_proc=$(ps -o comm= -p $PPID)
    if [[ -n "$ALACRITTY_LOG" || "$parent_proc" == "com.github.amez" || "$parent_proc" == "gjs" ]]; then
        session_name="Session_$(date -u +%Y-%m-%dT%H:%M:%S%Z)"
        tmux -lu new -s $session_name\; split-window -h \; split-window -v \; attach \; select-pane -L\; new-window \; next-window ;
    fi
fi

# Language and locale settings
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# export TERM color variable
export TERM="xterm-256color"
# export COLORTERM
export COLORTERM="truecolor"
# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Determine distro for later use
if [[ -f /etc/fedora-release ]]; then
    export DISTRO="fedora"
    # (sudo -n dnf install -y fontconfig-devel freetype-devel libX11-xcb libX11-devel \
    #     libstdc++-static libstdc++-devel atk-devel glib2-devel pango-devel gtk4-devel ccache \
    #     golang-go &>/dev/null || true) &
    #     # golang-go rustup cargo &>/dev/null || true) &
    # disown
    # (sudo -n dnf group install -y "development-tools" "development-libs" &>/dev/null || true) &
    # disown
elif [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ $NAME == "Ubuntu" ]]; then
        export DISTRO="ubuntu"
        # (sudo -n apt install -y curl \
        #     gnupg ca-certificates git \
        #     gcc-multilib g++-multilib cmake libssl-dev pkg-config \
        #     libfreetype6-dev libasound2-dev libexpat1-dev libxcb-composite0-dev \
        #     libbz2-dev libsndio-dev freeglut3-dev libxmu-dev libxi-dev libfontconfig1-dev \
        #     libxcursor-dev libgtk-4-dev ccache golang-go rustup cargo > /dev/null 2>&1 || true) &
        # disown
    elif [[ $ID == "arch" || $ID_LIKE == "arch" ]]; then
        export DISTRO="arch"
        # (sudo -n pacman -S --noconfirm base-devel fontconfig freetype2 libglvnd sndio cmake \
        #     git gtk3 python sdl2 vulkan-intel libxkbcommon-x11 ccache golang-go rustup cargo > /dev/null 2>&1 || true) &
        # disown
    fi
fi

# Include custom tools
[[ -f "${ZDOTDIR}/.ztools" ]] && source "${ZDOTDIR}/.ztools"

# Include custom path management
[[ -f "${ZDOTDIR}/.zpath" ]] && source "${ZDOTDIR}/.zpath"

# set default rust toolchain to nightly
[[ ! $(rustup default | grep nightly) ]] && \
    rustup default nightly

# Export GOPATH
[[ -d "${HOME}/go" ]] && export GOPATH="${HOME}/go"

# Export JAVA_HOME from default alternative
if ! javac_path=$(readlink -f "$(which javac)"); then
    echo "Failed to locate javac"
fi
export JAVA_HOME="$(dirname $(dirname $javac_path))"

# Python environment management
[[ -f "${ZDOTDIR}/.zpyenv" ]] && source "${ZDOTDIR}/.zpyenv"

# Export environment variables for FZF and related tools
# Check if fd, rg, and fzf are installed
if [[ ! $(command -v fd) || ! $(command -v rg) || ! $(command -v fzf) ]]; then
  # Determine the package manager and install the packages
  # package_manager_install fzf
  # package_manager_install ripgrep
  echo "fd, rg, or fzf not found, please install them manually"
  if [[ -f /etc/lsb-release ]]; then
    # package_manager_install fd-find
    echo "fd-find not found, please install it manually"
  else
    # package_manager_install fd
    echo "fd not found, please install it manually"
  fi
fi

export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude '.git'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="\
    --height=100% \
    --reverse \
    --border=sharp \
    --color=bg+:#313244,gutter:-1,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
    --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
    --color=selected-bg:#45475a \
    --multi" # catppuccin colors

# Fetch secrets
[[ ! $(command -v aws) ]] && \
    # package_manager_install awscli && \
    # aws configure
    echo "awscli not found, please install it manually and run aws configure"
# Check if the script exists and is executable
if [[ -x $ZDOTDIR/.fetch_secrets.sh ]]; then
  # Run the script and evaluate each line in the current shell
  while IFS= read -r line; do
      # if echo "$line" | grep -q 'BW_SESSION='; then
          # line=$(echo "$line" | sed 's/BW_SESSION=//')
      # fi
      eval "$line"
  done < <($ZDOTDIR/.fetch_secrets.sh)
fi

# For security, prevent core dumps
ulimit -c 0

ZSH_DEBUG_LOG_ENDFILE "${(%):-%N}"
