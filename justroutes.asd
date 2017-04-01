#|
  This file is a part of justroutes project.
|#

(in-package :cl-user)
(defpackage justroutes-asd
  (:use :cl :asdf))
(in-package :justroutes-asd)

(defsystem justroutes
  :version "0.1"
  :author ""
  :license ""
  :depends-on ()
  :components ((:module "src"
                :components
                ((:file "justroutes"))))
  :description "Minimal routing library for Clack/Common Lisp."
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (test-op justroutes-test))))
