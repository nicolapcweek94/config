;;; init.el --- Initialization code for Emacs -*- lexical-binding: t -*-

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

;; Install straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Install and configure use-package to use straight for package retrieval
(straight-use-package 'use-package)
(use-package emacs
  :straight (:type built-in)
  :defer nil
  :config
  (set-face-attribute 'default nil :font "SF Mono-12")
  (set-face-attribute 'variable-pitch nil :font "SF Pro Display-12")
  (set-face-attribute 'fixed-pitch nil :font "SF Mono-12")
  :custom
  ;; All files are and should be UTF-8
  (buffer-file-coding-system 'utf-8-unix)
  ;; Fix up straight.el/use-package integration
  (straight-use-package-by-default t)
  (use-package-always-ensure t)
  ;; Always defer loading packages unless otherwise specified
  (use-package-always-defer t)
  ;; Show stray whitespace.
  (show-trailing-whitespace t)
  (indicate-empty-lines t)
  (indicate-buffer-boundaries 'left)
  ;; Use spaces, not tabs, for indentation.
  (indent-tabs-mode nil)
  ;; Display the distance between two tab stops as 2 characters wide.
  (tab-width 2)
  ;; Drop some annoying default behaviours
  (custom-file (make-temp-file "emacs-custom"))
  (backup-directory-alist `(("." . "~/.saves")))
  (backup-by-copying t)
  (create-lockfiles nil)
  (sentence-end-double-space nil)
  (initial-major-mode 'org-mode)
  (browse-url-browser-function 'eww-browse-url)
  (read-extended-command-predicate #'command-completion-default-include-p)
  (large-file-warning-threshold nil)
  (vc-follow-symlinks t)
  (ad-redefinition-action 'accept)
  ;; Override default  completion behaviour to improve corfu
  (completion-cycle-threshold 3)
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  ;; Make matching paren show up faster
  (show-paren-delay 0)
  :config
  (set-default-coding-systems 'utf-8)
  :hook
  (after-init . show-paren-mode)
  (prog-mode . (lambda () (display-line-numbers-mode 1))))

(use-package diminish)

(use-package doom-modeline
  :hook (after-init . doom-modeline-mode))

(use-package doom-themes
  :defer nil
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  :config
  (load-theme 'doom-tokyo-night t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package golden-ratio
  :hook (after-init . (lambda () (golden-ratio-mode 1))))

;; Load the PATH from the login shell
(use-package exec-path-from-shell
  :hook (after-init . exec-path-from-shell-initialize))

;; Setup which-key for showing available keybindings after an interval
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

(use-package savehist
  :init (savehist-mode))

(use-package cape
  :hook
  (eglot-managed-mode . (lambda ()
                          (setq-local completion-at-point-functions
                                      (list (#'eglot-completion-at-point
                                             #'cape-file))))))

(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-quit-no-match 'separator)
  :hook
  (after-init . global-corfu-mode))

(use-package vertico
  :init
  (vertico-mode)
  (define-key vertico-map "?" #'minibuffer-completion-help)
  (define-key vertico-map (kbd "M-RET") #'minibuffer-force-complete-and-exit)
  (define-key vertico-map (kbd "M-TAB") #'minibuffer-complete))

(use-package orderless
  :custom
  (completion-styles '(orderless))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))
  :init (marginalia-mode))

(use-package embark
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init (setq prefix-help-command #'embark-prefix-help-command)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :after (embark consult)
  :demand t ; only necessary if you have the hook below
  ;; if you want to have consult previews as you move around an
  ;; auto-updating embark collect buffer
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package consult
  :bind (("C-c m" . consult-mode-command)
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings (goto-map)
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings (search-map)
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("C-s"   . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s m" . consult-multi-occur)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi))           ;; needed by consult-line to detect isearch

  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  (setq register-preview-delay 0
        register-preview-function #'consult-register-format)
  (advice-add #'register-preview :override #'consult-register-window)
  (advice-add #'completing-read-multiple :override #'consult-completing-read-multiple)
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  (consult-customize
   consult-theme
   :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-recent-file consult--source-project-recent-file consult--source-bookmark
   :preview-key (kbd "M-."))
  (setq consult-narrow-key "<") ;; (kbd "C-+")
  (setq consult-project-root-function
        (lambda ()
          (when-let (project (project-current))
            (car (project-roots project))))))

;; Use dabbrev with Corfu!
(use-package dabbrev
  ;; Swap M-/ and C-M-/
  :bind (("M-/" . dabbrev-completion)
         ("C-M-/" . dabbrev-expand)))

(use-package project
  :custom
  (project-switch-command 'project-dired)
  :bind-keymap
  (("C-c p" . project-prefix-map)))

(use-package magit
  :custom
  (magit-repository-directories '(("~/Code" . 1)
                                  ("~/go/src/git.sr.ht/~wasp" . 1)))
  :bind
  (("C-x g" . magit-status)))

(use-package eglot
  :config
  (setq-default eglot-workspace-configuration
                '(:yaml
                  (:format
                   (:enable t
                            :singleQuote nil
                            :bracketSpacing t
                            ;; preserve/always/never
                            :proseWrap "preserve"
                            :printWidth 80))
                  :validate t
                  :hover t
                  :completion t
                  :schemas ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json" "/docker-compose.*.yml"
                            "https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/playbook.json" "/playbook-*.yml"]
                  ;; (:schemaStore ...)
                  ;; custom tags for the parser to use
                  :customTags nil
                  :maxItemsComputed 5000)))

(use-package org
  :custom
  (org-hide-leading-stars t)
  (org-return-follows-link t)
  (org-startup-truncated nil)
  (org-id-link-to-org-use-id 'use-existing)
  (org-src-tab-acts-natively t)
  (org-edit-src-content-indentation 0)
  (org-directory "~/Org")
  (org-archive-location "~/Org/Archive.org::")
  (org-default-notes-file "~/Org/Notes.org")
  (org-agenda-files '("~/Org/GTD.org"))
  (org-capture-templates
   '(("t" "Todo" entry (file+headline "~/Org/GTD.org" "Tasks")
      "* TODO %?\n  %i\n  %a")
     ("j" "Journal" entry (file+datetree "~/Org/Journal.org")
      "* %?\nEntered on %U\n  %i\n  %a")
     ("w" "Web site" entry (file "")
      "* %a :website:\n\n%U %?\n\n%:initial")))
  ;; active Babel languages
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((ledger . t)
     *emacs-lisp . t))
  :bind
  (("C-c l" . org-store-link)
   ("C-c C-l" . org-insert-link)))

(use-package org-superstar
  :after org
  :custom
  (org-superstar-special-todo-items t)
  :hook
  (org-mode . org-superstar-mode))

(use-package ox-hugo
  :after org)

(use-package org-journal
 :custom (org-journal-dir "~/Org/journal/"))

(use-package org-web-tools)

(use-package pocket-reader)
(use-package all-the-icons)

;; Custom code
(defun replace-in-string (what with in)
  "Return a string with WHAT replaced with WITH in IN."
  (replace-regexp-in-string (regexp-quote what) with in nil 'literal))

(defun www-get-page-title (url)
  "Get the title of the page at URL."
  (with-current-buffer (url-retrieve-synchronously url)
    (goto-char 0)
    (re-search-forward "<title>\\(.*\\)<[/]title>" nil t 1)
    (decode-coding-string (match-string 1) 'utf-8)))

(defun wasp/url-to-org (link-url destination-file)
  "Save the content of LINK-URL as an org file in DESTINATION-FILE."
  (interactive)
  (let ((link-title (www-get-page-title link-url))
        (buffer (generate-new-buffer "temp.org")) link-title)
    (with-current-buffer buffer
      (unless (fboundp 'org-web-tools-insert-web-page-as-entry)
        (use-package org-web-tools))
      (org-mode)
      (org-web-tools-insert-web-page-as-entry link-url)
      (write-region (point-min) (point-max) destination-file)
      (kill-buffer))))

(defun wasp/archive-url-and-make-entry ()
  "Archive an url from clipboard to a file.
Defauls to storing in the Org/web directory asking for file name,
then opening a new entry in the daily journal."
  (interactive)
  (let ((url (gui-get-selection 'CLIPBOARD))
        (destination (concat "~/Org/Web/" (read-string "Enter target file name (without extension):") ".org")))
    (wasp/url-to-org url destination)
    (find-file destination)))

(defun wasp/eshell ()
  "Start eshell from project root if in a project, in current directory otherwise."
  (interactive)
  (if (project-current)
      (project-eshell)
    (eshell)))

(global-set-key (kbd "C-c p") 'wasp/archive-url-and-make-entry)
(global-set-key (kbd "C-c t") 'org-capture)
(global-set-key (kbd "C-x s") 'wasp/eshell)
(global-set-key (kbd "<f9>") (lambda()
                               (interactive)
                               (find-file "~/.config/emacs/init.el")))
(global-set-key (kbd "<f12>") 'compile)

(provide 'init)
;;; init.el ends here
