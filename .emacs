;; ============================================================================
;; ****************************************************************************
;;                          Henry's Emacs Config
;;   Description: Loads an org-mode version of my custom settings
;; ****************************************************************************
;; ============================================================================

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
 '(ansi-color-names-vector
   ["black" "#d55e00" "#009e73" "#f8ec59" "#0072b2" "#cc79a7" "#56b4e9" "white"])
 '(custom-enabled-themes (quote (deeper-blue)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
