#!/bin/bash

set -eu

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

EMACS_TO_RUN="${CASK_EMACS:-}"
if [ -z "${EMACS_TO_RUN}" ]; then
    EMACS_TO_RUN='emacs'
fi

function test-it() {
    "${EMACS_TO_RUN}" -Q --eval \
        "(progn
   (setq debug-on-error t)
   (setq user-emacs-directory \"$(readlink -f "${THIS_DIR}/../emacs.d")/\")
   (setq package-user-dir \"$(readlink -f "${THIS_DIR}/../emacs.d/elpa")/\")
   (require 'package)
   (setq package-archives '((\"melpa-stable\" . \"https://stable.melpa.org/packages/\")
                            (\"melpa\" . \"https://melpa.org/packages/\")
                            (\"nongnu\" . \"https://elpa.nongnu.org/nongnu/\")
                            (\"gnu\" . \"https://elpa.gnu.org/packages/\")))
   (package-initialize)
   (package-refresh-contents)
   (package-install 'eat)
   (package-install-file \"$(readlink -f "${THIS_DIR}/../dist/term-alert-1.3.tar")\")
   (setq alert-default-style 'notifications)
${1})"
}

function test-term() {
    test-it "
   (define-key term-raw-map (kbd \"C-#\") 'term-alert-next-command-toggle)
   (define-key term-raw-map (kbd \"M-#\") 'term-alert-all-toggle)
   (define-key term-raw-map (kbd \"C-'\") 'term-alert-runtime)
   (ansi-term \"$(readlink -f "${THIS_DIR}/ansi-term-test-${1}.sh")\")
   (sleep-for 5)
   (term-send-string (get-buffer-process (current-buffer)) \"echo \\\"Testing for ${1}. C-# to toggle alert on next command, M-# to toggle alert on all commands, C-' to check runtime (only available in zsh). Try a few commands to make sure it works, then quit emacs.\\\"\")
   (term-send-input)
   (term-send-string (get-buffer-process (current-buffer)) \"source \\\"$(readlink -f "${THIS_DIR}/../setup/setup.${1}")\\\"\")
   (term-send-input)"
}

function test-eat() {
    test-it "
   (define-key eat-mode-map (kbd \"C-#\") 'term-alert-next-command-toggle)
   (define-key eat-semi-char-mode-map (kbd \"M-#\") 'term-alert-all-toggle)
   (define-key eat-mode-map (kbd \"C-'\") 'term-alert-runtime)
   (eat \"$(readlink -f "${THIS_DIR}/ansi-term-test-${1}.sh")\")
   (sleep-for 5)
   (process-send-string (get-buffer-process (get-buffer \"*eat*\")) \"echo \\\"Testing for ${1}. C-# to toggle alert on next command, M-# to toggle alert on all commands, C-' to check runtime (only available in zsh). Try a few commands to make sure it works, then quit emacs.\\\"\n\")
   (process-send-string (get-buffer-process (get-buffer \"*eat*\")) \"source \\\"\${EAT_SHELL_INTEGRATION_DIR}/${1}\\\"; source \\\"$(readlink -f "${THIS_DIR}/../setup/setup.${1}")\\\"\n\")"
}

cd "${THIS_DIR}/.."
cask package
cd ~
test-term bash
test-term zsh
test-eat bash
test-eat zsh
