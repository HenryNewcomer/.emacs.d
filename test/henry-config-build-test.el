;;; henry-config-build-test.el --- Tests for checked config builds -*- lexical-binding: t; -*-

;;; Code:

(require 'ert)
(require 'henry-config-build)

(defconst henry-config-test-directory
  (file-name-directory (or load-file-name buffer-file-name)))

(defconst henry-config-test-fixture-directory
  (expand-file-name "fixtures" henry-config-test-directory))

(defun henry-config-test-fixture (name)
  "Return the absolute fixture path for NAME."
  (expand-file-name name henry-config-test-fixture-directory))

(ert-deftest henry-config-build-valid-source-passes ()
  (let ((report
         (henry-config-check-file
          (henry-config-test-fixture "valid.org")
          :required-definitions '(fixture-command))))
    (should (= (plist-get report :block-count) 1))
    (should (= (plist-get report :form-count) 1))
    (should (memq 'fixture-command (plist-get report :definitions)))))

(ert-deftest henry-config-build-malformed-org-fails ()
  (should-error
   (henry-config-check-file
    (henry-config-test-fixture "invalid-block.org")
    :required-definitions nil)
   :type 'henry-config-build-error))

(ert-deftest henry-config-build-malformed-lisp-fails ()
  (should-error
   (henry-config-check-file
    (henry-config-test-fixture "invalid-lisp.org")
    :required-definitions nil)
   :type 'henry-config-build-error))

(ert-deftest henry-config-build-compile-error-fails ()
  (should-error
   (henry-config-check-file
    (henry-config-test-fixture "compile-error.org")
    :required-definitions nil)
   :type 'henry-config-build-error))

(ert-deftest henry-config-build-required-definition-is-enforced ()
  (should-error
   (henry-config-check-file
    (henry-config-test-fixture "valid.org")
    :required-definitions '(missing-fixture-command))
   :type 'henry-config-build-error))

(ert-deftest henry-config-build-strict-warning-policy-is-optional ()
  (should
   (henry-config-check-file
    (henry-config-test-fixture "compile-warning.org")
    :required-definitions '(fixture-warning)
    :strict-warnings nil))
  (should-error
   (henry-config-check-file
    (henry-config-test-fixture "compile-warning.org")
    :required-definitions '(fixture-warning)
    :strict-warnings t)
   :type 'henry-config-build-error))

(ert-deftest henry-config-build-failure-preserves-last-known-good ()
  (let* ((directory (make-temp-file "henry-config-promotion-test-" t))
         (destination (expand-file-name "settings.el" directory))
         (sentinel ";; last known good\n"))
    (unwind-protect
        (progn
          (with-temp-file destination (insert sentinel))
          (should-error
           (henry-config-build-file
            (henry-config-test-fixture "invalid-lisp.org")
            destination
            :required-definitions nil)
           :type 'henry-config-build-error)
          (with-temp-buffer
            (insert-file-contents destination)
            (should (string= (buffer-string) sentinel))))
      (delete-directory directory t))))

(ert-deftest henry-config-build-valid-source-promotes-atomically ()
  (let* ((directory (make-temp-file "henry-config-promotion-test-" t))
         (destination (expand-file-name "settings.el" directory)))
    (unwind-protect
        (let ((report
               (henry-config-build-file
                (henry-config-test-fixture "valid.org")
                destination
                :required-definitions '(fixture-command))))
          (should (eq (plist-get report :promotion) 'updated))
          (should (file-regular-p destination))
          (with-temp-buffer
            (insert-file-contents destination)
            (should (search-forward "(defun fixture-command" nil t))))
      (delete-directory directory t))))

(ert-deftest henry-config-build-explicit-tangle-cannot-escape-staging ()
  (let* ((directory (make-temp-file "henry-config-escape-test-" t))
         (source (expand-file-name "source.org" directory))
         (escape (expand-file-name "escape.el" directory)))
    (unwind-protect
        (progn
          (with-temp-file source
            (insert "#+BEGIN_SRC emacs-lisp :tangle " escape "\n")
            (insert "(message \"must not escape\")\n")
            (insert "#+END_SRC\n"))
          (should-error
           (henry-config-check-file source :required-definitions nil)
           :type 'henry-config-build-error)
          (should-not (file-exists-p escape)))
      (delete-directory directory t))))

(provide 'henry-config-build-test)

;;; henry-config-build-test.el ends here
