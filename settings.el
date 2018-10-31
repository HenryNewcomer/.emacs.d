(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

(package-initialize)

(defvar my-packages

  '(evil
    evil-leader
    nlinum-relative
    org-bullets
    neotree
    projectile
    undo-tree)

  "A list of packages to ensure are installed at launch.")

(defun my-packages-installed-p ()
  (cl-loop for p in my-packages
           when (not (package-installed-p p)) do (cl-return nil)
           finally (cl-return t)))
(unless (my-packages-installed-p)
  ;; Check for new packages (package versions)
  (package-refresh-contents)
  ;; Install the missing packages
  (dolist (p my-packages)
    (when (not (package-installed-p p))
      (package-install p))))

;; *Make sure this is placed before evil mode*
(require 'evil-leader)
(global-evil-leader-mode)
(evil-leader/set-leader "<SPC>")

;;(add-to-list 'load-path "~/.emacs.d/from_backup/evil")
(setq evil-want-C-u-scroll t)
(require 'evil)
(evil-mode 1)

;; (add-to-list 'load-path "~/.emacs.d/from_backup/wrap-region.el")
;; (require 'wrap-region)

(add-to-list 'load-path "/some/path/neotree")
(require 'neotree)
(global-set-key [f8] 'neotree-toggle)
;;setq neo-theme (if (display-graphic-p) 'icons 'arrow))

(projectile-mode +1)
;;(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

;;(add-to-list 'load-path "~/.emacs.d/from_backup/undo-tree")
(global-undo-tree-mode)

;;(setq display-line-numbers 'relative) 
(setq-default display-line-numbers 'relative
	      display-line-numbers-type 'visual
              display-line-numbers-current-absolute t
              display-line-numbers-width 4
              display-line-numbers-widen t)
(add-hook 'text-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

  ;; (require 'nlinum-relative)
  ;; (nlinum-relative-setup-evil)                    ;; setup for evil
  ;; (add-hook 'prog-mode-hook 'nlinum-relative-mode)
  ;; (setq nlinum-relative-redisplay-delay 0)        ;; delay
  ;; (setq nlinum-relative-current-symbol "")        ;; "" to display current line number (was "->")
  ;; (setq nlinum-relative-offset 0)                 ;; 1 if you want 0, 2, 3...

;; Check OS
(cond
  ((string-equal system-type "gnu/linux")
    (require 'org-bullets)
    (setq org-bullets-bullet-list
	'("◉" "◎" "⚫" "○" "►" "◇"))
    ;;    '("?" "?" "?" "?" "?" "?"))
    :config
	(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))))

;;(add-to-list 'load-path "~/.emacs.d/from_backup/php-mode")
;;(require 'php-mode)

(menu-bar-mode -1)
(tool-bar-mode -1)

(set-window-scroll-bars (minibuffer-window) nil nil)

(setq inhibit-startup-screen t)

(add-to-list 'default-frame-alist '(fullscreen . maximized))

(setenv "LANG" "en_US.UTF-8")
(setenv "LC_ALL" "en_US.UTF-8")
(setenv "LC_CTYPE" "en_US")
(set-locale-environment "English")
(set-language-environment 'English)
(prefer-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(set-file-name-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)

(recentf-mode 1)
(setq recentf-max-menu-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

;;; Source; https://www.emacswiki.org/emacs/ForceBackups
;; Default and per-save backups go here:
(setq backup-directory-alist '(("" . "~/.emacs.d/backup/per-save")))

(defun force-backup-of-buffer ()
;; Make a special "per session" backup at the first save of each
;; emacs session.
(when (not buffer-backed-up)
    ;; Override the default parameters for per-session backups.
    (let ((backup-directory-alist '(("" . "~/.emacs.d/backup/per-session")))
	(kept-new-versions 3))
    (backup-buffer)))
;; Make a "per save" backup on each save.  The first save results in
;; both a per-session and a per-save backup, to keep the numbering
;; of per-save backups consistent.
(let ((buffer-backed-up nil))
    (backup-buffer)))

(add-hook 'before-save-hook  'force-backup-of-buffer)

(define-key evil-normal-state-map (kbd "SPC") nil)
;;(define-key evil-insert-state-map (kbd "SPC") (kbd "SPC"))
;;(global-set-key (kbd "SPC") nil)

(define-key evil-normal-state-map (kbd "SPC s") (lambda() (interactive)(find-file "~/.emacs.d/settings.org")))

(define-key evil-normal-state-map (kbd "SPC SPC") (kbd "i SPC ESC"))

(define-key evil-normal-state-map (kbd "SPC d") 'dired)

(define-key evil-normal-state-map (kbd "SPC l") (kbd "$"))

(define-key evil-normal-state-map (kbd "SPC h") 'split-window-below)
(define-key evil-normal-state-map (kbd "SPC v") 'split-window-right)

(define-key evil-normal-state-map (kbd "C-M-h") 'windmove-left)
(define-key evil-normal-state-map (kbd "C-M-l") 'windmove-right)
(define-key evil-normal-state-map (kbd "C-M-k") 'windmove-up)
(define-key evil-normal-state-map (kbd "C-M-j") 'windmove-down)

(define-key evil-normal-state-map (kbd "SPC j") #'other-window)
(define-key evil-normal-state-map (kbd "SPC k") #'prev-window)
(defun prev-window ()
  (interactive)
  (other-window -1))

(define-key evil-normal-state-map (kbd "SPC r") 'recentf-open-most-recent-file)

(define-key evil-normal-state-map (kbd "SPC t") 'term)

(define-key evil-normal-state-map (kbd "SPC w") 'save-buffer)

(define-key evil-normal-state-map (kbd "SPC q") 'save-buffers-kill-emacs)

(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C-_") 'text-scale-decrease)
