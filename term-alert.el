;;; term-alert.el --- Get notifications when commands complete in the Emacs terminal emulator

;; Copyright (C) 2014 Callum J. Cameron

;; Author: Callum J. Cameron <cjcameron7@gmail.com>
;; Version: 1.0
;; Url: https://github.com/CallumCameron/term-alert
;; Keywords: notifications processes
;; Package-Requires: ((term-cmd "1.0") (alert "1.1"))

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Get notifications when commands complete in the Emacs terminal
;; emulator.
;;
;;
;; Usage:
;;
;; Suppose you start a command in the terminal emulator, but it's
;; taking much longer than expected.  You want to go and do other
;; things, but don't want to have to keep checking the terminal buffer
;; to see if that command has finished.  So you use term-alert mode:
;;
;;   1. In the terminal buffer, run `term-alert-next-command-toggle`
;;   2. When the running command finishes, a notification pops up to
;;      tell you
;;
;; If you want to get notifications for all commands in a buffer (not
;; just the current/next one), run `term-alert-all-toggle`, and all
;; commands will generate alerts until you explicitly turn it off.
;;
;; Because it's entirely inside Emacs, you don't need to stop the
;; command to enable an alert on it (an advantage over 'alert' shell
;; commands, which usually require you to pause the command and
;; restart it).  And because it uses 'term-cmd'
;; (https://github.com/CallumCameron/term-cmd), you can alert commands
;; running over SSH, too (as long as the remote shell is set up
;; correctly).
;;
;;
;; Installation:
;;
;; You need to install the Emacs package, and configure your shell to
;; interact with it.
;;
;; Emacs:
;;
;; Install the 'term-alert' package from MELPA.
;;
;; Or, for a manual install:
;;
;;   1. Install the dependencies: 'term-cmd'
;;      (https://github.com/CallumCameron/term-cmd) and 'alert'
;;      (https://github.com/jwiegley/alert)
;;   2. Make sure this file is on your load path
;;   3. (require 'term-alert)
;;
;; You'll want to set up key bindings for
;; `term-alert-next-command-toggle` and `term-alert-all-toggle`.  My
;; configuration looks like this (I use 'multi-term'
;; (http://www.emacswiki.org/emacs/MultiTerm); a plain term.el setup
;; will be slightly different):
;;
;;     ;; I'm on a UK keyboard, where '#' is next to Enter, and easily accessible
;;     (add-hook 'term-mode-hook
;;               (lambda ()
;;                 (local-set-key (kbd "C-#") 'term-alert-next-command-toggle)
;;                 (local-set-key (kbd "M-#") 'term-alert-all-toggle)))
;;
;;     (add-to-list 'term-bind-key-alist '("C-#" . term-alert-next-command-toggle))
;;     (add-to-list 'term-bind-key-alist '("M-#" . term-alert-all-toggle))
;;
;; Shell:
;;
;; You need to configure your shell to emit a 'magic escape sequence'
;; whenever a command finishes.  The escape sequence looks like:
;;
;;     # Using GNU printf
;;     /usr/bin/printf '\eTeRmCmD term-alert-done\n'
;;
;;     # With a shell built-in (ZSH shown)
;;     print '\033TeRmCmD term-alert-done'
;;
;; Exactly how you do this depends on your shell.  For ZSH, you can
;; use the 'precmd' hook (strictly speaking, this is called when the
;; prompt is displayed, rather than when a command finishes, but the
;; effect is the same):
;;
;;     function term-alert-precmd()
;;     {
;;         if [[ "${TERM}" =~ 'eterm' ]]; then
;;             env printf '\033TeRmCmD term-alert-done\n'
;;         elif [ "${TERM}" = 'screen' ] && [ ! -z "${TMUX}" ] &&
;;                  [[ "$(tmux display-message -p '#{client_termname}')" =~ 'eterm' ]]; then
;;             env printf '\033Ptmux;\033\033TeRmCmD term-alert-done\n\033\\'
;;         fi
;;     }
;;
;;     precmd_functions=($precmd_functions term-alert-precmd)
;;
;; The file 'enable.zsh' in this package's git repository does exactly
;; that; source it in your zshrc and everything will be set up
;; correctly.
;;
;; In other shells, check the manual for how to do this.

;;; Code:

(require 'term)
(require 'term-cmd)
(require 'alert)

(defvar term-alert-count -1 "Number of alerts to display for this buffer, after which alert mode will disable itself; if < 0, no limit.")
(make-variable-buffer-local 'term-alert-count)


(define-minor-mode term-alert-mode
  "Toggle Term Alert mode. Interactively with no argument, this command
toggles the mode. A positive prefix argument enables the mode, any
other prefix argument disables it. From Lisp, argument omitted or nil
enables the mode, `toggle' toggles the state.

When Term Alert mode is enabled, alerts will be displayed after each
completed command in the terminal. (Note that this requires
cooperation from the shell process; see the readme for this package.)
The variable `term-alert-count' controls how many commands should be
alerted; if it is positive, it will be decremented after each command,
and Term Alert mode will disable itself when the value reaches 0. If
it is negative, commands will be alerted until Term Alert mode is
explicitly disabled."
  nil
  (:eval (concat " alert" (if (> term-alert-count 0) (format "[%d]" term-alert-count) "")))
  nil)


(defun term-alert-set-count (number)
  "Set the NUMBER of commands to alert, and enable/disable Term Alert mode accordingly.  If num is equal to `term-alert-count', disable the mode."
  (setq term-alert-count (if (eq number term-alert-count) 0 number))
  (if (eq term-alert-count 0)
      (when term-alert-mode
        (term-alert-mode -1))
    (when (not term-alert-mode)
      (term-alert-mode)))
  (force-mode-line-update))

;;;###autoload
(defun term-alert-next-command-toggle (num)
  "Toggle whether to display an alert when a command next completes in this buffer.  If NUM is equal to `term-alert-count', disable Term Alert mode.  With prefix arg, alert for that number of commands."
  (interactive "p")
  (term-alert-set-count (if (< num 1) 1 num)))

;;;###autoload
(defun term-alert-all-toggle ()
  "Toggle whether to display an alert after all commands until further notice."
  (interactive)
  (term-alert-set-count -1))

;;;###autoload
(defun term-alert-callback (c a)
  "Respond to a completed command.  C and A are unused."
  (when term-alert-mode
    (when (not (eq term-alert-count 0))
      (alert
       (concat "Command completed in " (buffer-name))
       :title "Emacs")
      (when (> term-alert-count 0)
        (term-alert-set-count (- term-alert-count 1))))))

;;;###autoload
(add-to-list 'term-cmd-commands-alist '("term-alert-done" . term-alert-callback))

(provide 'term-alert)

;;; term-alert.el ends here
