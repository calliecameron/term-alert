;;; term-alert.el --- get notifications when commands complete in the Emacs terminal emulator

;; Copyright (C) 2014 Callum J. Cameron

;; Author: Callum J. Cameron <cjcameron7@gmail.com>
;; Keywords: notifications processes

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

;;

;;; Code:

(require 'term)
(require 'term-cmd)
(require 'simple-notify)

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
      (term-alert-mode))))

(defun term-alert-next-command-toggle (num)
  "Toggle whether to display an alert when a command next completes in this buffer.  If NUM is equal to `term-alert-count', disable Term Alert mode.  With prefix arg, alert for that number of commands."
  (interactive "p")
  (term-alert-set-count (if (< num 1) 1 num)))

(defun term-alert-all-toggle ()
  "Toggle whether to display an alert after all commands until further notice."
  (interactive)
  (term-alert-set-count -1))

(defun term-alert-callback (c a)
  "Respond to a completed command.  C and A are unused."
  (when term-alert-mode
    (when (not (eq term-alert-count 0))
      (simple-notify
       (concat "Command completed in " (buffer-name)))
      (when (> term-alert-count 0)
        (term-alert-set-count (- term-alert-count 1))))))

(add-to-list 'term-cmd-commands-alist '("term-alert-done" . term-alert-callback))

(provide 'term-alert)

;;; term-alert.el ends here
