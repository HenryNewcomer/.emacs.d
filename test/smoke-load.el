;;; smoke-load.el --- Disposable source-load smoke test -*- lexical-binding: t; -*-

;;; Commentary:

;; This file is loaded only by scripts/smoke-config in a child Emacs whose HOME
;; and user-emacs-directory are temporary.  It reuses installed packages for
;; reading, redirects future package writes, and blocks network/package changes.

;;; Code:

(require 'package)
(require 'url)

(defun henry-config-smoke--blocked-package-refresh (&rest arguments)
  "Reject package refresh with ARGUMENTS during an isolated smoke test."
  (error "SMOKE: package refresh is disabled: %S" arguments))

(defun henry-config-smoke--blocked-package-install (&rest arguments)
  "Reject package installation with ARGUMENTS during an isolated smoke test."
  (error "SMOKE: package installation is disabled: %S" arguments))

(defun henry-config-smoke--blocked-network (&rest arguments)
  "Reject network retrieval with ARGUMENTS during an isolated smoke test."
  (error "SMOKE: network retrieval is disabled: %S" arguments))

(defun henry-config-smoke--blocked-external-install (&rest arguments)
  "Reject asynchronous external installation with ARGUMENTS."
  (error "SMOKE: asynchronous external installation is disabled: %S"
         arguments))

(let ((candidate (getenv "SMOKE_CANDIDATE"))
      (installed-elpa (getenv "SMOKE_INSTALLED_ELPA")))
  (unless (and candidate (file-regular-p candidate))
    (error "SMOKE_CANDIDATE is not a readable file: %S" candidate))
  (unless (and installed-elpa (file-directory-p installed-elpa))
    (error "SMOKE_INSTALLED_ELPA is not a directory: %S" installed-elpa))

  (setq user-emacs-directory
        (file-name-as-directory
         (expand-file-name ".emacs.d" (getenv "HOME")))
        package-user-dir installed-elpa)
  (package-initialize)
  (package-read-all-archive-contents)

  ;; Keep the descriptors and load-path populated above, but ensure any later
  ;; package state would be written only beneath the disposable HOME.
  (setq package-user-dir
        (expand-file-name "elpa" user-emacs-directory)
        package-gnupghome-dir
        (expand-file-name "gnupg" user-emacs-directory))
  (make-directory package-user-dir t)
  (make-directory package-gnupghome-dir t)

  (advice-add 'package-initialize :override
              (lambda (&optional _no-activate) package-alist))
  (advice-add 'package-refresh-contents :override
              #'henry-config-smoke--blocked-package-refresh)
  (advice-add 'package-install :override
              #'henry-config-smoke--blocked-package-install)
  (advice-add 'url-retrieve :override
              #'henry-config-smoke--blocked-network)
  (advice-add 'url-retrieve-synchronously :override
              #'henry-config-smoke--blocked-network)
  (advice-add 'async-shell-command :override
              #'henry-config-smoke--blocked-external-install)

  (let ((started-at (current-time)))
    (condition-case error-data
        (progn
          (load candidate nil nil t)
          (princ
           (format "SMOKE_LOAD_OK seconds=%.3f source=%s\n"
                   (float-time
                    (time-subtract (current-time) started-at))
                   candidate))
          (kill-emacs 0))
      (error
       (princ (format "SMOKE_FAIL %S\n" error-data)
              'external-debugging-output)
       (backtrace)
       (kill-emacs 1)))))

;;; smoke-load.el ends here
