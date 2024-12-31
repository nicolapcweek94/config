;;; early-init.el --- Initialization code for Emacs -*- lexical-binding: t -*-

;; Author: Nicola "nicolapcweek94" Zangrandi <wasp@wasp.dev>

;; This file is not part of GNU Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; My commentary

;;; Code:

(setq lexical-binding t)

(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(pixel-scroll-precision-mode 1)

;; Disable package.el
(setq package-enable-at-startup nil)

;; Disable startup screen
(setq inhibit-startup-screen t)

(setq default-frame-alist
      (append
       '(;;(undecorated . t)
         ;;(fullscreen . maximized)
         (alpha . (90 . 90)))
       default-frame-alist))

(provide 'early-init)
;;; early-init.el ends here.
