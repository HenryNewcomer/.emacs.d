;;; henry-config-build.el --- Checked literate configuration builds -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Henry Newcomer

;; Author: Henry Newcomer
;; Keywords: convenience, lisp, tools
;; Package-Requires: ((emacs "30.1") (org "9.7"))

;;; Commentary:

;; Validate settings.org in a disposable staging directory.  A build never
;; writes the generated settings.el to its final destination until Org lint,
;; tangle planning, Lisp reading, expected-definition checks, and byte
;; compilation have succeeded.

;;; Code:

(require 'bytecomp)
(require 'cl-lib)
(require 'org)
(require 'org-lint)
(require 'ob-tangle)
(require 'package)
(require 'subr-x)

(define-error 'henry-config-build-error
  "Checked Emacs configuration build failed")

(defconst henry-config-build-root
  (let* ((library-file (or load-file-name buffer-file-name))
         (library-directory (file-name-directory library-file)))
    (file-name-directory (directory-file-name library-directory)))
  "Repository root containing the checked configuration builder.")

(defcustom henry-config-source-file
  (expand-file-name "settings.org" henry-config-build-root)
  "Default literate configuration source."
  :type 'file
  :group 'environment)

(defcustom henry-config-output-file
  (expand-file-name "var/last-known-good/settings.el"
                    henry-config-build-root)
  "Default destination for a validated generated configuration."
  :type 'file
  :group 'environment)

(defcustom henry-config-required-definitions
  '(henry:copy-thing-at-point-or-region)
  "Definitions that must survive tangling from the full configuration."
  :type '(repeat symbol)
  :group 'environment)

(defconst henry-config-build--fatal-lint-checkers
  '(empty-header-argument
    invalid-block
    invalid-keyword-syntax
    missing-language-in-src-block
    wrong-header-argument
    wrong-header-value)
  "Org lint checkers that make a configuration build unsafe.")

(defun henry-config-build--fail (format-string &rest arguments)
  "Signal a checked-build error described by FORMAT-STRING and ARGUMENTS."
  (signal 'henry-config-build-error
          (list (apply #'format format-string arguments))))

(defun henry-config-build--run-phase (name function)
  "Run FUNCTION as build phase NAME and add phase context to errors."
  (condition-case error-data
      (funcall function)
    (henry-config-build-error
     (signal (car error-data) (cdr error-data)))
    (error
     (henry-config-build--fail
      "%s failed: %s" name (error-message-string error-data)))))

(defun henry-config-build--lint-reports (source)
  "Return normalized Org lint reports for SOURCE.

The return format of `org-lint' is not a public API, so fail clearly if the
installed Org version changes it."
  (with-temp-buffer
    (insert-file-contents source)
    (setq buffer-file-name source
          default-directory (file-name-directory source))
    (let ((org-mode-hook nil))
      (org-mode))
    (mapcar
     (lambda (raw-report)
       (let ((report (cadr raw-report)))
         (unless (and (vectorp report) (= (length report) 4))
           (henry-config-build--fail
            "Unsupported org-lint report format: %S" raw-report))
         (let ((checker-data (aref report 3)))
           (list
            :line (string-to-number
                   (substring-no-properties (aref report 0)))
            :trust (aref report 1)
            :message (aref report 2)
            :checker
            (if (fboundp 'org-lint-checker-name)
                (org-lint-checker-name checker-data)
              (henry-config-build--fail
               "This Org version does not expose lint checker names"))))))
     (org-lint))))

(defun henry-config-build--format-lint-report (source report)
  "Format one lint REPORT for SOURCE as a compiler-style diagnostic."
  (format "%s:%d: %s: [%s] %s"
          source
          (plist-get report :line)
          (if (memq (plist-get report :checker)
                    henry-config-build--fatal-lint-checkers)
              "error"
            "warning")
          (plist-get report :checker)
          (plist-get report :message)))

(defun henry-config-build--lint (source &optional display-source)
  "Lint SOURCE and fail when a structurally unsafe report is present.

Use DISPLAY-SOURCE in diagnostics when SOURCE is a staged snapshot."
  (let* ((reports (henry-config-build--lint-reports source))
         (display-source (or display-source source))
         (fatal-reports
          (cl-remove-if-not
           (lambda (report)
             (memq (plist-get report :checker)
                   henry-config-build--fatal-lint-checkers))
           reports)))
    (when fatal-reports
      (henry-config-build--fail
       "Org structure is unsafe:\n%s"
       (mapconcat
        (lambda (report)
          (henry-config-build--format-lint-report display-source report))
        reports
        "\n")))
    reports))

(defun henry-config-build--guard-tangle-blocks ()
  "Reject active Emacs Lisp blocks that require tangle-time evaluation."
  (org-babel-map-src-blocks (buffer-file-name)
    (let* ((info (org-babel-get-src-block-info 'no-eval))
           (language (nth 0 info))
           (parameters (nth 2 info))
           (tangle (cdr (assq :tangle parameters))))
      (when (and (string= language "emacs-lisp")
                 (not (string= tangle "no")))
        (when (assq :var parameters)
          (henry-config-build--fail
           "%s:%d: active configuration blocks may not use :var"
           buffer-file-name (line-number-at-pos)))
        (when (org-babel-noweb-p parameters :tangle)
          (henry-config-build--fail
           "%s:%d: active configuration blocks may not expand noweb while tangling"
           buffer-file-name (line-number-at-pos)))))))

(defun henry-config-build--normalize-output (file base-directory)
  "Return absolute FILE, resolving relative paths from BASE-DIRECTORY."
  (expand-file-name file base-directory))

(defun henry-config-build--tangle (source candidate)
  "Tangle SOURCE to the single staging file CANDIDATE.

Reject any explicit block destination that would escape CANDIDATE before Org
has an opportunity to write it.  Return the number of tangled blocks."
  (with-temp-buffer
    (insert-file-contents source)
    (setq buffer-file-name source
          default-directory (file-name-directory source))
    (let ((org-mode-hook nil))
      (org-mode))
    (let* ((language-regexp "\\`emacs-lisp\\'")
           (org-babel-pre-tangle-hook nil)
           (org-babel-tangle-body-hook nil)
           (org-babel-post-tangle-hook nil)
           (org-babel-tangle-finished-hook nil)
           (org-babel-default-header-args
            (org-babel-merge-params
             org-babel-default-header-args
             `((:tangle . ,candidate)))))
      (henry-config-build--guard-tangle-blocks)
      (cl-letf (((symbol-function 'org-babel-ref-resolve)
                 (lambda (&rest arguments)
                   (henry-config-build--fail
                    "Tangle attempted to resolve a Babel reference: %S"
                    arguments))))
        (let* ((plan (org-babel-tangle-collect-blocks language-regexp))
               (planned-files
                (mapcar
                 (lambda (entry)
                   (henry-config-build--normalize-output
                    (car entry) default-directory))
                 plan)))
          (unless (and (= (length planned-files) 1)
                       (string= (car planned-files)
                                (expand-file-name candidate)))
            (henry-config-build--fail
             "Configuration must tangle to exactly one staging file; planned %S"
             planned-files))
          (let ((outputs (org-babel-tangle nil candidate language-regexp)))
            (unless (and (= (length outputs) 1)
                         (string= (henry-config-build--normalize-output
                                   (car outputs) default-directory)
                                  (expand-file-name candidate))
                         (file-exists-p candidate))
              (henry-config-build--fail
               "Unexpected tangle outputs: %S" outputs)))
          (apply #'+ (mapcar (lambda (entry) (length (cdr entry))) plan)))))))

(defun henry-config-build--definitions-in-form (form)
  "Return definitions introduced directly by top-level FORM."
  (pcase form
    (`(,(and kind (or 'defalias 'defconst 'defcustom 'defmacro
                      'defsubst 'defun 'defvar))
       ,name . ,_)
     (when (and kind (symbolp name)) (list name)))
    (`(progn . ,body)
     (mapcan #'henry-config-build--definitions-in-form body))
    (_ nil)))

(defun henry-config-build--read (candidate)
  "Check CANDIDATE with `check-parens' and the Lisp reader.

Return a plist containing the number of forms and visible top-level
definitions."
  (with-temp-buffer
    (insert-file-contents candidate)
    (emacs-lisp-mode)
    (check-parens)
    (goto-char (point-min))
    (let ((form-count 0)
          definitions)
      (while (progn
               (forward-comment (point-max))
               (not (eobp)))
        (let ((start (point)))
          (condition-case error-data
              (let ((form (read (current-buffer))))
                (cl-incf form-count)
                (setq definitions
                      (nconc definitions
                             (henry-config-build--definitions-in-form form))))
            (end-of-file
             (henry-config-build--fail
              "%s:%d: unexpected EOF while reading a Lisp form"
              candidate (line-number-at-pos start)))
            (invalid-read-syntax
             (henry-config-build--fail
              "%s:%d: %s"
              candidate (line-number-at-pos start)
              (error-message-string error-data))))))
      (list :form-count form-count
            :definitions (delete-dups definitions)))))

(defun henry-config-build--check-required-definitions
    (candidate definitions required-definitions)
  "Require REQUIRED-DEFINITIONS to appear in DEFINITIONS from CANDIDATE."
  (let ((missing
         (cl-remove-if
          (lambda (definition) (memq definition definitions))
          required-definitions)))
    (when missing
      (henry-config-build--fail
       "%s is missing expected definitions after tangling: %S"
       candidate missing))))

(defun henry-config-build--prepare-package-load-path ()
  "Expose installed packages to the compiler without installing anything."
  (let ((installed-directory
         (or (getenv "HENRY_CONFIG_INSTALLED_ELPA")
             (expand-file-name "elpa" henry-config-build-root))))
    (when (file-directory-p installed-directory)
      (setq package-user-dir installed-directory)
      (package-initialize))))

(defun henry-config-build--compile (candidate strict-warnings)
  "Byte-compile CANDIDATE and return all diagnostics.

When STRICT-WARNINGS is non-nil, collect every warning before failing.  The
generated byte-code file is always discarded because compilation is only a
validation phase."
  (henry-config-build--prepare-package-load-path)
  (let* ((compile-log-name "*Henry Config Compile*")
         (byte-compile-log-buffer compile-log-name)
         (byte-compile-error-on-warn nil)
         (byte-compile-warnings t)
         (base-handler byte-compile-log-warning-function)
         diagnostics
         (compiled-file (byte-compile-dest-file candidate)))
    (when (get-buffer compile-log-name)
      (kill-buffer compile-log-name))
    (unwind-protect
        (condition-case error-data
            (cl-letf
                (((symbol-function 'package-refresh-contents)
                  (lambda (&rest arguments)
                    (henry-config-build--fail
                     "Package refresh is forbidden during validation: %S"
                     arguments)))
                 ((symbol-function 'package-install)
                  (lambda (&rest arguments)
                    (henry-config-build--fail
                     "Package installation is forbidden during validation: %S"
                     arguments))))
              (let ((byte-compile-log-warning-function
                     (lambda (text position fill level)
                       (push (list :level (or level :warning)
                                   :text text
                                   :position position)
                             diagnostics)
                       (when (functionp base-handler)
                         (funcall base-handler text position fill level)))))
                (unless (byte-compile-file candidate)
                  (henry-config-build--fail
                   "Byte compilation returned failure:\n%s"
                   (if-let ((buffer (get-buffer compile-log-name)))
                       (with-current-buffer buffer (buffer-string))
                     "No compiler log was produced"))))
              (setq diagnostics (nreverse diagnostics))
              (when (and strict-warnings
                         (cl-find-if
                          (lambda (diagnostic)
                            (eq (plist-get diagnostic :level) :warning))
                          diagnostics))
                (henry-config-build--fail
                 "Strict compilation rejected %d warning(s):\n%s"
                 (length diagnostics)
                 (if-let ((buffer (get-buffer compile-log-name)))
                     (with-current-buffer buffer (buffer-string))
                   "No compiler log was produced")))
              diagnostics)
          (henry-config-build-error
           (signal (car error-data) (cdr error-data)))
          (error
           (henry-config-build--fail
            "Byte compilation failed: %s\n%s"
            (error-message-string error-data)
            (if-let ((buffer (get-buffer compile-log-name)))
                (with-current-buffer buffer (buffer-string))
              "No compiler log was produced"))))
      (when (file-exists-p compiled-file)
        (delete-file compiled-file)))))

(defun henry-config-build--hash (file)
  "Return the SHA-256 digest of FILE."
  (with-temp-buffer
    (insert-file-contents-literally file)
    (secure-hash 'sha256 (current-buffer))))

(defun henry-config-build--promote (candidate destination)
  "Atomically promote CANDIDATE to local, non-symlink DESTINATION."
  (when (file-remote-p destination)
    (henry-config-build--fail
     "Refusing to promote configuration to a remote path: %s" destination))
  (when (file-symlink-p destination)
    (henry-config-build--fail
     "Refusing to replace a symlinked configuration target: %s" destination))
  (when (file-directory-p destination)
    (henry-config-build--fail
     "Configuration output is a directory: %s" destination))
  (if (and (file-exists-p destination)
           (string= (henry-config-build--hash candidate)
                    (henry-config-build--hash destination)))
      'unchanged
    (when (file-exists-p destination)
      (set-file-modes candidate (file-modes destination)))
    (rename-file candidate destination t)
    'updated))

(cl-defun henry-config-build--run
    (source &key destination
            (required-definitions henry-config-required-definitions)
            strict-warnings)
  "Validate SOURCE and optionally promote it to DESTINATION."
  (setq source (expand-file-name source)
        destination (and destination (expand-file-name destination)))
  (unless (file-regular-p source)
    (henry-config-build--fail
     "Configuration source is not a regular file: %s" source))
  (when (file-remote-p source)
    (henry-config-build--fail
     "Refusing to validate a remote configuration source: %s" source))
  (when (and destination (string= source destination))
    (henry-config-build--fail
     "Source and generated destination must differ: %s" source))
  (let* ((destination-directory
          (if destination
              (file-name-directory destination)
            temporary-file-directory)))
    (when destination
      (make-directory destination-directory t))
    (let* ((stage-directory
            (make-temp-file
             (expand-file-name ".henry-config-build-"
                               destination-directory)
             t))
           (snapshot (expand-file-name "settings.org" stage-directory))
           (candidate (expand-file-name "settings.el" stage-directory))
           started-at)
      (unwind-protect
          (progn
            (copy-file source snapshot t)
            (setq started-at (current-time))
            (let* ((lint-reports
                    (henry-config-build--run-phase
                     "Org lint"
                     (lambda () (henry-config-build--lint snapshot source))))
                   (block-count
                    (henry-config-build--run-phase
                     "Org tangle"
                     (lambda ()
                       (henry-config-build--tangle snapshot candidate))))
                   (reader-report
                    (henry-config-build--run-phase
                     "Lisp reader"
                     (lambda () (henry-config-build--read candidate))))
                   (_required-check
                    (henry-config-build--run-phase
                     "Expected definitions"
                     (lambda ()
                       (henry-config-build--check-required-definitions
                        candidate
                        (plist-get reader-report :definitions)
                        required-definitions))))
                   (compile-diagnostics
                    (henry-config-build--run-phase
                     "Byte compilation"
                     (lambda ()
                       (henry-config-build--compile
                        candidate strict-warnings))))
                   (promotion
                    (and destination
                         (henry-config-build--run-phase
                          "Atomic promotion"
                          (lambda ()
                            (henry-config-build--promote
                             candidate destination))))))
              (list
               :source source
               :output destination
               :promotion promotion
               :lint-reports lint-reports
               :block-count block-count
               :form-count (plist-get reader-report :form-count)
               :definitions (plist-get reader-report :definitions)
               :compile-diagnostics compile-diagnostics
               :seconds (float-time
                         (time-subtract (current-time) started-at)))))
        (when (file-directory-p stage-directory)
          (delete-directory stage-directory t))))))

(cl-defun henry-config-check-file
    (&optional (source henry-config-source-file)
               &key
               (required-definitions henry-config-required-definitions)
               strict-warnings)
  "Validate SOURCE without promoting generated output."
  (henry-config-build--run
   source
   :required-definitions required-definitions
   :strict-warnings strict-warnings))

(cl-defun henry-config-build-file
    (&optional (source henry-config-source-file)
               (destination henry-config-output-file)
               &key
               (required-definitions henry-config-required-definitions)
               strict-warnings)
  "Validate SOURCE and atomically promote it to DESTINATION."
  (henry-config-build--run
   source
   :destination destination
   :required-definitions required-definitions
   :strict-warnings strict-warnings))

(defun henry-config-build--print-report (report)
  "Print a concise human-readable build REPORT."
  (princ (format "[config] source: %s\n" (plist-get report :source)))
  (dolist (lint-report (plist-get report :lint-reports))
    (princ
     (format "[config] %s\n"
             (henry-config-build--format-lint-report
              (plist-get report :source) lint-report))))
  (princ
   (format "[config] tangle: %d blocks, %d top-level forms\n"
           (plist-get report :block-count)
           (plist-get report :form-count)))
  (let ((diagnostics (plist-get report :compile-diagnostics)))
    (princ (format "[config] compile: ok (%d diagnostic%s)\n"
                   (length diagnostics)
                   (if (= (length diagnostics) 1) "" "s"))))
  (when-let ((output (plist-get report :output)))
    (princ (format "[config] output: %s (%s)\n"
                   output (plist-get report :promotion))))
  (princ (format "[config] PASS in %.3fs\n"
                 (plist-get report :seconds))))

(defun henry-config-build--batch-run (build-p)
  "Run a noninteractive check, promoting output when BUILD-P is non-nil."
  (let ((source (or (getenv "HENRY_CONFIG_SOURCE")
                    henry-config-source-file))
        (output (or (getenv "HENRY_CONFIG_OUTPUT")
                    henry-config-output-file))
        (strict-warnings
         (equal (getenv "HENRY_CONFIG_STRICT_WARNINGS") "1")))
    (condition-case error-data
        (let ((report
               (if build-p
                   (henry-config-build-file
                    source output :strict-warnings strict-warnings)
                 (henry-config-check-file
                  source :strict-warnings strict-warnings))))
          (henry-config-build--print-report report)
          (kill-emacs 0))
      (error
       (princ (format "[config] FAIL: %s\n"
                      (error-message-string error-data))
              'external-debugging-output)
       (kill-emacs 1)))))

(defun henry-config-batch-check ()
  "Batch entry point for validating the literate configuration."
  (henry-config-build--batch-run nil))

(defun henry-config-batch-build ()
  "Batch entry point for validating and promoting generated configuration."
  (henry-config-build--batch-run t))

(provide 'henry-config-build)

;;; henry-config-build.el ends here
