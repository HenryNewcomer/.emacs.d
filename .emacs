;; ========================================================================
;; ************************************************************************
;;                          Henry's Emacs Config
;;   Description: Loads an org-mode version of my custom settings
;; ************************************************************************
;; ========================================================================

(require 'org)
(org-babel-load-file
 (expand-file-name "~/.emacs.d/settings.org"
    user-emacs-directory))

;; End of my code

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (git-gutter telephone-line rainbow-delimiters projectile org-bullets nlinum-relative neotree multiple-cursors highlight-indent-guides helm evil-surround evil-magit evil-leader dumb-jump doom-themes dashboard auto-complete ace-window))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
