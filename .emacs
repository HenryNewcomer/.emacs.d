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
      (git-gutter telephone-line rainbow-delimiters projectile org-bullets nlinum-relative neotree multiple-cursors highlight-indent-guides helm evil-surround evil-magit evil-leader dumb-jump doom-themes dashboard auto-complete ace-window)))
 '(safe-local-variable-values
    (quote
      ((eval progn
         (henry:custom-build-process:setBuild "cd ${PWD%%/src/*}/../build && cmake ..")
         (henry:custom-build-process:setCompile "cd ${PWD%%/src/*}/../build && make all")
         (henry:custom-build-process:setRun "cd ${PWD%%/src/*}/../build && ./pong++.exe")
         (add-hook
           (quote prog-mode-hook)
           (lambda nil
             (add-hook
               (quote after-save-hook)
               (lambda nil
                 (henry:custom-build-process:build)
                 (message "TEMP - auto building..."))))))
        (eval progn
          (henry:custom-build-process:setBuild "cd ${PWD%%/src/*}/../build && cmake ..")
          (henry:custom-build-process:setCompile "cd ${PWD%%/src/*}/../build && make all")
          (henry:custom-build-process:setRun "cd ${PWD%%/src/*}/../build && ./pong++.exe")
          (add-hook
            (quote prog-mode-hook)
            (lambda nil
              (add-hook
                (quote after-save-hook)
                (lambda nil
                  (henry:custom-build-process:build))))))
        (eval progn
          (henry:custom-build-process:setBuild "cd ${PWD%%/src/*}/../build && cmake ..")
          (henry:custom-build-process:setCompile "cd ${PWD%%/src/*}/../build && make all")
          (henry:custom-build-process:setRun "cd ${PWD%%/src/*}/../build && ./pong++.exe"))
        (eval progn
          (henry:custom-build-process:setBuild "cd ${PWD%%/src/*}../build && cmake .."))
        (eval progn
          (henry:custom-build-process:setBuild "cd ${PWD%%/src/*}/build && cmake ../src"))
        (eval progn
          (henry:custom-build-process:setBuild "cd"))
        (eval setq henry:custom-build-process:build "test")))))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
  '(org-document-info ((t (:foreground "dark orange"))))
  '(org-link ((t (:foreground "royal blue" :underline t))))
  '(org-tag ((t (:weight bold height 0.8))))
  '(org-verbatim ((t (:weight bold height 0.8)))))
