function term-alert-done() {
    type emacs-term-cmd &>/dev/null && emacs-term-cmd term-alert-done
}

if [ -z "${PROMPT_COMMAND}" ]; then
    PROMPT_COMMAND='emacs-term-cmd term-alert-done'
else
    PROMPT_COMMAND="${PROMPT_COMMAND}; emacs-term-cmd term-alert-done"
fi
