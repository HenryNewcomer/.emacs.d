;; =====================================================================
;; *********************************************************************
;;                          Henry's Emacs Config
;;   Description: Loads an org-mode version of my custom settings
;; *********************************************************************
;; =====================================================================

;;; Code:

;; Stop script/compilation if running an older version of Emacs
(setq henry:emacs-version-required "26.1")
;; TODO If version is too low, prevent script from finishing
(if (version< emacs-version henry:emacs-version-required)
  (progn
    (setq inhibit-startup-screen t)
    (switch-to-buffer "*scratch*")
    (insert (format "WARNING: Emacs version must be %s or newer. Aborting initialization!" henry:emacs-version-required))
    (redisplay)
    (with-current-buffer " *load*"
      (goto-char (point-max)))))

;; Load custom settings
(require 'org)
(org-babel-load-file
  (expand-file-name "~/.emacs.d/settings.org"
    user-emacs-directory))

;; TODO Move these into theme
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-document-info ((t (:foreground "dark orange"))))
 '(org-link ((t (:foreground "royal blue" :underline t))))
 '(org-tag ((t (:weight bold height 0.8))))
 '(org-verbatim ((t (:weight bold height 0.8)))))

;;; .emacs ends here
