term-alert
==========

[![MELPA](https://melpa.org/packages/term-alert-badge.svg)](https://melpa.org/#/term-alert)
[![MELPA Stable](https://stable.melpa.org/packages/term-alert-badge.svg)](https://stable.melpa.org/#/term-alert)

Notifications when commands complete in term.el.


Usage
-----

Suppose you start a command in the terminal emulator, but it's taking
much longer than expected. You want to go and do other things, but
don't want to have to keep checking the terminal buffer to see if that
command has finished. So you use term-alert:

1. In the terminal buffer, run `term-alert-next-command-toggle`.
2. When the running command finishes, a notification pops up to tell
   you.

If you want to get notifications for all commands in a buffer (not
just the current/next one), run `term-alert-all-toggle`, and all
commands will generate alerts until you explicitly turn it off.

Because it's entirely inside Emacs, you don't need to stop the command
to enable an alert on it (an advantage over `alert` shell commands,
which usually require you to pause the command and restart it). And
because it uses [term-cmd](https://github.com/CallumCameron/term-cmd),
you can alert commands running in tmux or over SSH, too (as long as
the remote shell is set up correctly).

Set up keybindings:

    ;; I'm on a UK keyboard, where # and ' are next to Enter
    (define-key term-raw-map (kbd "C-#") 'term-alert-next-command-toggle)
    (define-key term-raw-map (kbd "M-#") 'term-alert-all-toggle)
    (define-key term-raw-map (kbd "C-'") 'term-alert-runtime)


Installation
------------

Install the `term-alert` package from MELPA.

Set up your shell; in zsh you also get timing information in
notifications.

- zsh: `source ~/.emacs.d/term-alert/setup.zsh`
- bash: `source ~/.emacs.d/term-alert/setup.bash`

(Replace ~/.emacs.d with wherever your `user-emacs-directory` is.)


License
-------

Copyright (C) 2014--2016 Callum J. Cameron

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
