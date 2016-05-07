function term-alert-done() {
    type emacs-term-cmd &>/dev/null && emacs-term-cmd term-alert-done
}

# The sleep seems to force bash/ssh/tmux/... to flush, thereby
# avoiding a problem where bash's built-in rudimentary dir-tracking
# string gets split mid-line, and appears on the screen rather than
# working (not the ansi-term dir tracking (which is fixed by
# term-cmd), but the *other* one, hardcoded into bash). At some point
# I should really fix this in term-cmd, but this hack does the job for
# now. Alternatively, just use zsh :)
if [ -z "${PROMPT_COMMAND}" ]; then
    PROMPT_COMMAND='emacs-term-cmd term-alert-done; sleep 0.05'
else
    PROMPT_COMMAND="${PROMPT_COMMAND}; emacs-term-cmd term-alert-done; sleep 0.05"
fi
