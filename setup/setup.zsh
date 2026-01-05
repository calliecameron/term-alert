function term-alert-cmd() {
    if type _eat_msg &>/dev/null; then
        _eat_msg "${1}"
    elif type emacs-term-cmd &>/dev/null; then
        emacs-term-cmd "${1}"
    fi
}

function term-alert-preexec() {
    term-alert-cmd term-alert-started
}

function term-alert-precmd() {
    term-alert-cmd term-alert-done
}

preexec_functions=($preexec_functions term-alert-preexec)
precmd_functions=($precmd_functions term-alert-precmd)
