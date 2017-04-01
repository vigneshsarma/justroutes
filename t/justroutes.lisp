(in-package :cl-user)
(defpackage justroutes-test
  (:use :cl
        :justroutes
        :prove))
(in-package :justroutes-test)

;; NOTE: To run this test file, execute `(asdf:test-system :justroutes)' in your Lisp.

(plan nil)

(defparameter simple-routes (list
                             (list :GET "/home/"
                                   #'(lambda (env)
                                       (declare (ignore env))
                                       '(200 (:content-type "text/plain")
                                         ("get home"))))
                             (list :POST "/home/"
                                   #'(lambda (env)
                                       (declare (ignore env))
                                       '(201 (:content-type "text/plain")
                                         ("POST home"))))
                             (list :ALL "/user/"
                                   #'(lambda (env)
                                       (declare (ignore env))
                                       '(200 (:content-type "text/plain")
                                         ("every user"))))))
;; blah blah blah.

(finalize)
