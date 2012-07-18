;;; deferred-flyspell.el --- Defer spell checking

;; Copyright (C) 2012 Takafumi Arakaki

;; Author: Takafumi Arakaki <aka.tkf at gmail.com>

;; This file is NOT part of GNU Emacs.

;; deferred-flyspell.el is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; deferred-flyspell.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with deferred-flyspell.el.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Entry points:

;; 1. C-u M-x deferred-flyspell:install-hooks
;;    to use deferred-flyspell in the current buffer.

;; 2. Put `(deferred-flyspell:config)' in Emacs setup to automatically
;;    setup deferred-flyspell via `flyspell-mode-hook'.

;;; Code:

(eval-when-compile (require 'cl))
(require 'deferred)
(require 'flyspell)


(defcustom deferred-flyspell:auto-setup t
  "Automatically enable `deferred-flyspell' via `flyspell-mode-hook'."
  :group 'deferred-flyspell)

(defun deferred-flyspell:post-command-hook ()
  "Execute `flyspell-post-command-hook' later."
  (lexical-let ((this-command this-command))
    (deferred:$
      (deferred:run-with-idle-timer 0.1
        (lambda ()
          (let ((this-command this-command))
            (flyspell-post-command-hook)))))))

;;;###autoload
(defun deferred-flyspell:install-hooks (&rest local)
  "Install `deferred-flyspell:post-command-hook' and remove
the original `flyspell-post-command-hook'.
LOCAL will be passed to `remove-hook' and `add-hook'."
  (interactive "P")
  (remove-hook 'post-command-hook 'flyspell-post-command-hook local)
  (add-hook 'post-command-hook 'deferred-flyspell:post-command-hook nil local))

(defun deferred-flyspell:uninstall-hooks (&rest local)
  "Uninstall `deferred-flyspell:post-command-hook' and restore
the original `flyspell-post-command-hook'.
LOCAL will be passed to `remove-hook' and `add-hook'."
  (interactive "P")
  (add-hook 'post-command-hook 'flyspell-post-command-hook nil local)
  (remove-hook 'post-command-hook 'deferred-flyspell:post-command-hook local))

(defun deferred-flyspell:auto-setup ()
  "Setup deferred-flyspell.  Called via `flyspell-mode-hook'."
  (when deferred-flyspell:auto-setup
    (deferred-flyspell:install-hooks t)))

;;;###autoload
(defun deferred-flyspell:config ()
  "Add `deferred-flyspell:auto-setup' to `flyspell-mode-hook'."
  (interactive)
  (add-hook 'flyspell-mode-hook 'deferred-flyspell:auto-setup))

(provide 'deferred-flyspell)

;;; deferred-flyspell.el ends here
