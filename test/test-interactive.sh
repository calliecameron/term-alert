#!/bin/bash

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

EMACS_TO_RUN="${CASK_EMACS}"
if [ -z "${CASK_EMACS}" ]; then
    EMACS_TO_RUN='emacs'
fi

function test-it() {
    "${EMACS_TO_RUN}" -Q --eval \
        "(progn
   (setq debug-on-error t)
   (setq user-emacs-directory \"${THIS_DIR}/../emacs.d/\")
   (require 'package)
   (setq package-archives '((\"melpa-stable\" . \"https://stable.melpa.org/packages/\")
                            (\"melpa\" . \"https://melpa.org/packages/\")
                            (\"gnu\" . \"https://elpa.gnu.org/packages/\")))
   (package-initialize)
   (package-refresh-contents)
   (package-install-file \"${THIS_DIR}/../dist/term-alert-1.2.tar\")
   (define-key term-raw-map (kbd \"C-#\") 'term-alert-next-command-toggle)
   (define-key term-raw-map (kbd \"M-#\") 'term-alert-all-toggle)
   (define-key term-raw-map (kbd \"C-'\") 'term-alert-runtime)
   (setq alert-default-style 'notifications)
   (ansi-term \"${THIS_DIR}/ansi-term-test-${1}.sh\")
   (sleep-for 5)
   (term-send-string (get-buffer-process (current-buffer)) \"echo \\\"Testing for ${1}. C-# to toggle alert on next command, M-# to toggle alert on all commands, C-' to check runtime (only available in zsh). Try a few commands to make sure it works, then quit emacs.\\\"\")
   (term-send-input)
   (term-send-string (get-buffer-process (current-buffer)) \"source \\\"${THIS_DIR}/../setup/setup.${1}\\\"\")
   (term-send-input))"
}

cd "${THIS_DIR}/.." &&
    cask package &&
    cd ~ &&
    test-it bash &&
    test-it zsh
