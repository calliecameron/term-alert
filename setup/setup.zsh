function term-alert-preexec() {
    type emacs-term-cmd &>/dev/null && emacs-term-cmd term-alert-started
}

function term-alert-precmd() {
    type emacs-term-cmd &>/dev/null && emacs-term-cmd term-alert-done
}

preexec_functions=($preexec_functions term-alert-preexec)
precmd_functions=($precmd_functions term-alert-precmd)
