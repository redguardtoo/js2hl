;;; js2hl-tests.el ---  unit tests for js2hl -*- coding: utf-8 -*-

;; Author: Chen Bin <chenbin DOT sh AT gmail DOT com>

;;; License:

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:
;;; Code:

(require 'ert)
(require 'js2hl)

(defun js2hl-test-curline ()
  "Get current line."
  ;; make ci server happy. Don't know why emacs25 does not support `string-trim'
  (let ((line (buffer-substring-no-properties (line-beginning-position)
                                              (line-end-position))))
    (replace-regexp-in-string "\\`[ \t\n]*" ""
                              (replace-regexp-in-string "[ \t\n]*\\'" "" line))))

(defun js2hl-test-insert-js-code ()
  "Insert code for test."
  (insert "function hello (a1) {\n")
  (insert " const b1 = 4;\n")
  (insert " a1.p2.p7.prop1 = 3;\n")
  (insert " a1.p2.test1.prop1 = 3;\n")
  (insert " console.log('a1.property1=', a1.p2.p7?.prop1);\n")
  (insert " a1.pp2 = 3;\n")
  (insert "}\n")
  (insert "hello();\n"))

(ert-deftest js2hl-test-renaming-function-variable ()
  (with-temp-buffer
    (js2hl-test-insert-js-code)

    ;; prepare ast
    (js2-mode)
    (js2-init-scanner)
    (js2-do-parse)

    ;; rename js function
    (goto-char (point-min))
    (search-forward "hello")
    (should (string= "hello" (thing-at-point 'symbol)))
    (js2hl-rename-thing-at-point-internal (lambda (old) "bye") nil)
    (forward-line 1)
    (search-forward "bye")
    (should (string= (js2hl-test-curline) "bye();"))

    ;; rename js variable
    (goto-char (point-min))
    (search-forward "a1")
    (should (string= "a1" (thing-at-point 'symbol)))
    (js2hl-rename-thing-at-point-internal (lambda (old) "var1") nil)
    (forward-word)
    (search-forward "var1")
    (should (string= (js2hl-test-curline) "var1.p2.p7.prop1 = 3;"))
    (forward-word)
    (search-forward "var1")
    (should (string= (js2hl-test-curline) "var1.p2.test1.prop1 = 3;"))
    (forward-word)
    (search-forward "var1")
    (should (string= (js2hl-test-curline) "console.log('a1.property1=', var1.p2.p7?.prop1);"))
    (forward-word)
    (search-forward "var1")
    (should (string= (js2hl-test-curline) "var1.pp2 = 3;"))
    (should (eq major-mode 'js2-mode))))

(ert-deftest js2hl-test-renaming-property ()
  (with-temp-buffer
    (js2hl-test-insert-js-code)

    ;; prepare ast
    (js2-mode)
    (js2-init-scanner)
    (js2-do-parse)

    ;; rename js function
    (goto-char (point-min))
    (search-forward "prop1")
    (should (string= "prop1" (thing-at-point 'symbol)))
    (js2hl-rename-thing-at-point-internal (lambda (old) "prop2") nil)
    (should (string= (js2hl-test-curline) "a1.p2.p7.prop2 = 3;"))
    (forward-word)
    ;; In this line, parent of "prop1" is different
    (search-forward "prop1")
    (should (string= (js2hl-test-curline) "a1.p2.test1.prop1 = 3;"))
    (search-forward "prop2")
    ;; parent is optional chaining operator
    (should (string= (js2hl-test-curline) "console.log('a1.property1=', a1.p2.p7?.prop2);"))

    (should (eq major-mode 'js2-mode))))
(ert-run-tests-batch-and-exit)
;;; evil-matchit-tests.el ends here
