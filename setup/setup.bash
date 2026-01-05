function term-alert-done() {
    if type _eat_msg &>/dev/null; then
        _eat_msg term-alert-done
    elif type emacs-term-cmd &>/dev/null; then
        emacs-term-cmd term-alert-done
    fi
}

# The sleep seems to force bash/ssh/tmux/... to flush, thereby avoiding a
# problem where bash's built-in rudimentary dir-tracking string gets split
# mid-line, and appears on the screen rather than working (not the ansi-term dir
# tracking (which is fixed by term-cmd), but the *other* one, hardcoded into
# bash). At some point I should really fix this in term-cmd, but this hack does
# the job for now. Alternatively, just use zsh :)
if [ -z "${PROMPT_COMMAND}" ]; then
    PROMPT_COMMAND='term-alert-done; sleep 0.05'
else
    PROMPT_COMMAND="${PROMPT_COMMAND}; term-alert-done; sleep 0.05"
fi
