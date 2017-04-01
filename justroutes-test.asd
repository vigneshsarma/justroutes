#|
  This file is a part of justroutes project.
|#

(in-package :cl-user)
(defpackage justroutes-test-asd
  (:use :cl :asdf))
(in-package :justroutes-test-asd)

(defsystem justroutes-test
  :author ""
  :license ""
  :depends-on (:justroutes
               :prove)
  :components ((:module "t"
                :components
                ((:test-file "justroutes"))))
  :description "Test system for justroutes"

  :defsystem-depends-on (:prove-asdf)
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run-test-system) :prove-asdf) c)
                    (asdf:clear-system c)))
