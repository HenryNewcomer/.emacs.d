;; ========================================================================
;; ************************************************************************
;;                          Henry's Emacs Config
;;   Description: Loads an org-mode version of my custom settings
;; ************************************************************************
;; ========================================================================

;;; Code:
(require 'org)
(org-babel-load-file
 (expand-file-name "~/.emacs.d/settings.org"
		   user-emacs-directory))

;; End of my code

;; Proper eof closure
(provide '.emacs)
;;; .emacs ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
    (quote
      (smartparens telephone-line realgud rainbow-delimiters org-bullets multiple-cursors modern-cpp-font-lock mmm-mode highlight-indent-guides google-this git-gutter flycheck-inline evil-surround evil-nerd-commenter evil-magit esup emmet-mode dumb-jump doom-themes dimmer dashboard counsel-etags company column-enforce-mode cmake-font-lock clang-format beacon auto-package-update aggressive-indent ace-window))))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
  '(org-document-info ((t (:foreground "dark orange"))))
  '(org-link ((t (:foreground "royal blue" :underline t))))
  '(org-tag ((t (:weight bold height 0.8))))
  '(org-verbatim ((t (:weight bold height 0.8)))))
