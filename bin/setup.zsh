function term-alert-preexec() {
    emacs-term-cmd term-alert-started
}

function term-alert-precmd() {
    emacs-term-cmd term-alert-done
}

preexec_functions=($preexec_functions term-alert-preexec)
precmd_functions=($precmd_functions term-alert-precmd)
