;; ========================================================================
;; ************************************************************************
;;                          Henry's Emacs Config
;;   Description: Loads an org-mode version of my custom settings
;; ************************************************************************
;; ========================================================================

;;; Code:

(defconst emacs-start-time (current-time))

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
      (goto-char (point-max))))
  (message "!!!"))

;; Load custom settings
(require 'org)
(org-babel-load-file
  (expand-file-name "~/.emacs.d/settings.org"
    user-emacs-directory))

;; ----------------------------
;; Emacs auto-generation: START
;; ----------------------------
;; TODO REMOVE THESE (implement them within settings.org)

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
  '(package-selected-packages
     (quote
       (smartparens telephone-line realgud rainbow-delimiters org-bullets modern-cpp-font-lock mmm-mode highlight-indent-guides google-this git-gutter flycheck-inline evil-surround evil-nerd-commenter evil-magit esup emmet-mode dumb-jump doom-themes dimmer dashboard counsel-etags company column-enforce-mode cmake-font-lock clang-format beacon auto-package-update aggressive-indent ace-window))))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
  '(org-document-info ((t (:foreground "dark orange"))))
  '(org-link ((t (:foreground "royal blue" :underline t))))
  '(org-tag ((t (:weight bold height 0.8))))
  '(org-verbatim ((t (:weight bold height 0.8)))))

;; ----------------------------
;; Emacs auto-generation: END
;; ----------------------------

(provide '.emacs)


(let ((elapsed (float-time (time-subtract (current-time)
                             emacs-start-time))))
  (message "Loading %s...done (%.3fs)" load-file-name elapsed))

(add-hook 'after-init-hook
  `(lambda ()
     (let ((elapsed
             (float-time
               (time-subtract (current-time) emacs-start-time))))
       (message "Loading %s...done (%.3fs) [after-init]"
         ,load-file-name elapsed))) t)

;;; .emacs ends here
