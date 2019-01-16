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
