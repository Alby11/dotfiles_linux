# vim: ft=zsh

# NOTE: .logout: executed when login shell exits.

[[ -e $ZSH_DEBUG ]] && ZSH_DEBUG_LOG_STARTFILE "${(%):-%N}"

# when leaving the console clear the screen to increase privacy
if [ "$SHLVL" = 1 ]; then
    [ -x /usr/bin/clear ] && /usr/bin/clear -q
fi

[[ -e $ZSH_DEBUG ]] && ZSH_DEBUG_LOG_ENDFILE "${(%):-%N}"
