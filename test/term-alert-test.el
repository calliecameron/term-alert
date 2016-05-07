;;; term-alert-test.el --- Term-alert: tests.            -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Callum Cameron

;; Author: Callum Cameron <callum@CallumPC>
;; Keywords: terminals

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

;;; Code:

(require 'f)

(defconst term-alert-test--root (f-parent (f-parent load-file-name)))
(defconst term-alert-test--setup (f-join term-alert-test--root "setup"))

(setq user-emacs-directory (f-join term-alert-test--root "emacs.d"))

(add-to-list 'load-path term-alert-test--root)

(require 'term-alert)

(ert-deftest term-alert-files ()
  (should (f-directory? term-alert--bin-dir))
  (should (f-file? (f-join term-alert--bin-dir "setup.zsh")))
  (should (f-file? (f-join term-alert--bin-dir "setup.bash")))
  (should (eq (call-process
               "cmp"
               nil
               nil
               nil
               "-s"
               (f-join term-alert-test--setup "setup.zsh")
               (f-join term-alert--bin-dir "setup.zsh"))
              0))
  (should (eq (call-process
               "cmp"
               nil
               nil
               nil
               "-s"
               (f-join term-alert-test--setup "setup.bash")
               (f-join term-alert--bin-dir "setup.bash"))
              0)))

;;; term-alert-test.el ends here
