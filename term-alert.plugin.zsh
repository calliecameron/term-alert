# Source this file in your zshrc to set everything up for term-alert

function term-alert-precmd() {
    if [[ "${TERM}" =~ 'eterm' ]]; then
        env printf '\033TeRmCmD term-alert-done\n'
    elif [ "${TERM}" = 'screen' ] && [ ! -z "${TMUX}" ] &&
             [[ "$(tmux display-message -p '#{client_termname}')" =~ 'eterm' ]]; then
        env printf '\033Ptmux;\033\033TeRmCmD term-alert-done\n\033\\'
    fi
}

precmd_functions=($precmd_functions term-alert-precmd)
