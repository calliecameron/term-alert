;;; term-alert.el --- Notifications when commands complete in term.el. -*- lexical-binding: t -*-

;; Copyright (C) 2014-2016 Callum J. Cameron

;; Author: Callum J. Cameron <cjcameron7@gmail.com>
;; Version: 1.1
;; Url: https://github.com/CallumCameron/term-alert
;; Keywords: notifications processes
;; Package-Requires: ((emacs "24.0") (term-cmd "1.1") (alert "1.1") (f "0.0"))

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

;; Notifications when commands complete in term.el.
;;
;; Usage
;;
;; Suppose you start a command in the terminal emulator, but it's
;; taking much longer than expected.  You want to go and do other
;; things, but don't want to have to keep checking the terminal buffer
;; to see if that command has finished.  So you use term-alert:
;;
;; 1. In the terminal buffer, run `term-alert-next-command-toggle'.
;; 2. When the running command finishes, a notification pops up to
;;    tell you.
;;
;; If you want to get notifications for all commands in a buffer (not
;; just the current/next one), run `term-alert-all-toggle', and all
;; commands will generate alerts until you explicitly turn it off.
;;
;; Because it's entirely inside Emacs, you don't need to stop the
;; command to enable an alert on it (an advantage over 'alert' shell
;; commands, which usually require you to pause the command and
;; restart it).  And because it uses term-cmd
;; (https://github.com/CallumCameron/term-cmd), you can alert commands
;; running in tmux or over SSH, too (as long as the remote shell is
;; set up correctly).
;;
;; Set up keybindings:
;;
;;     ;; I'm on a UK keyboard, where # and ' are next to Enter
;;     (define-key term-raw-map (kbd "C-#") 'term-alert-next-command-toggle)
;;     (define-key term-raw-map (kbd "M-#") 'term-alert-all-toggle)
;;     (define-key term-raw-map (kbd "C-'") 'term-alert-runtime)
;;
;;
;; Installation
;;
;; Install the term-alert package from MELPA.
;;
;; Set up your shell; in zsh you also get timing information in
;; notifications.
;;
;; - zsh: 'source ~/.emacs.d/term-alert/setup.zsh'
;; - bash: 'source ~/.emacs.d/term-alert/setup.bash'
;;
;; (Replace ~/.emacs.d with wherever your `user-emacs-directory' is.)

;;; Code:

(require 'term)
(require 'term-cmd)
(require 'alert)
(require 'f)

(defvar term-alert--count -1
  "Number of alerts to display for this buffer, after which alert mode will disable itself; if < 0, no limit.")
(make-variable-buffer-local 'term-alert--count)

(defvar term-alert--command-started-time nil
  "When the most recent shell command started.")
(make-variable-buffer-local 'term-alert--command-started-time)

(defvar term-alert--command-done-time nil
  "When the most recent shell command finished.")
(make-variable-buffer-local 'term-alert--command-done-time)


(define-minor-mode term-alert-mode
  "Toggle Term Alert mode. Interactively with no argument, this command
toggles the mode. A positive prefix argument enables the mode, any
other prefix argument disables it. From Lisp, argument omitted or nil
enables the mode, `toggle' toggles the state.

When Term Alert mode is enabled, alerts will be displayed after each
completed command in the terminal. (Note that this requires
cooperation from the shell process; see the readme for this package.)
Interactively, use `term-alert-next-command-toggle' and
`term-alert-all-toggle' to control how many commands will be alerted;
don't activate `term-alert-mode' directly."
  nil
  (:eval (concat " alert" (if (> term-alert--count 0) (format "[%d]" term-alert--count) "")))
  nil)


(defun term-alert--set-count (number)
  "Set the NUMBER of commands to alert, and enable/disable Term Alert mode accordingly.  If num is equal to `term-alert--count', disable the mode."
  (setq term-alert--count (if (eq number term-alert--count) 0 number))
  (if (eq term-alert--count 0)
      (when term-alert-mode
        (term-alert-mode -1))
    (when (not term-alert-mode)
      (term-alert-mode)))
  (force-mode-line-update))

;;;###autoload
(defun term-alert-next-command-toggle (num)
  "Toggle whether to display an alert when a command next completes in this buffer.  If NUM is equal to `term-alert--count', disable Term Alert mode.  With prefix arg, alert for that number of commands."
  (interactive "p")
  (term-alert--set-count (if (< num 1) 1 num)))

;;;###autoload
(defun term-alert-all-toggle ()
  "Toggle whether to display an alert after all commands until further notice."
  (interactive)
  (term-alert--set-count -1))

(defun term-alert--get-runtime ()
  "Pretty-formatted runtime of the most recent command."
  (if term-alert--command-started-time
      (format-seconds
       "%dd %hh %mm %z%ss"
       (time-to-seconds
        (if term-alert--command-done-time
            (time-subtract term-alert--command-done-time term-alert--command-started-time)
          (time-since term-alert--command-started-time))))
    ""))

;;;###autoload
(defun term-alert-runtime ()
  "Display the running time of the most recent command."
  (interactive)
  (alert
   (if term-alert--command-started-time
       (format
        "Most recent command started at %s (runtime %s)"
        (current-time-string term-alert--command-started-time)
        (term-alert--get-runtime))
     "No timing information available")
   :title "Emacs"))

;;;###autoload
(defun term-alert--started-callback (_c _a)
  ;; checkdoc-params: (_c _a)
  "Respond to a started command."
  (setq term-alert--command-started-time (current-time))
  (setq term-alert--command-done-time nil))

;;;###autoload
(defun term-alert--done-callback (_c _a)
  ;; checkdoc-params: (_c _a)
  "Respond to a completed command."
  (unless term-alert--command-done-time
    (setq term-alert--command-done-time (current-time)))
  (when term-alert-mode
    (when (not (eq term-alert--count 0))
      (alert
       (format
        "Command completed in %s%s"
        (buffer-name)
        (if term-alert--command-started-time
            (format " (runtime %s)" (term-alert--get-runtime))
          ""))
       :title "Emacs")
      (when (> term-alert--count 0)
        (term-alert--set-count (- term-alert--count 1))))))

(defconst term-alert--bin-dir (f-expand (f-join user-emacs-directory "term-alert")))

(defun term-alert--ensure-file (name)
  "Copy file NAME from the package directory to a stable path."
  (let ((source (f-join (f-parent load-file-name) "setup" name))
        (dest (f-join term-alert--bin-dir name)))
    (when (f-exists? dest)
      (f-delete dest))
    (f-copy source dest)))

;;;###autoload
(defun term-alert--init ()
  "Internal term-alert initialisation function."
  (f-mkdir user-emacs-directory)
  (f-mkdir term-alert--bin-dir)
  (term-alert--ensure-file "setup.zsh")
  (term-alert--ensure-file "setup.bash")
  (add-to-list 'term-cmd-commands-alist '("term-alert-started" . term-alert--started-callback))
  (add-to-list 'term-cmd-commands-alist '("term-alert-done" . term-alert--done-callback)))

;;;###autoload
(term-alert--init)


(provide 'term-alert)

;;; term-alert.el ends here
