# Optimized Version of .zprofile

ZSH_DEBUG_LOG_STARTFILE "${(%):-%N}"

# Python environment management
[[ -f "${ZDOTDIR}/.zpyenv" ]] && source "${ZDOTDIR}/.zpyenv"

ZSH_DEBUG_LOG_ENDFILE "${(%):-%N}"
