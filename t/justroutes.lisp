(in-package :cl-user)
(defpackage justroutes-test
  (:use :cl
        :justroutes
        :drakma
        :prove)
  (:import-from clack clackup)
  (:import-from clack.handler stop))
(in-package :justroutes-test)

;; NOTE: To run this test file, execute `(asdf:test-system :justroutes)' in your Lisp.

(setf prove:*default-reporter* :fiveam)
(setf prove:*enable-colors* nil) ;; slime does not support color.

(defparameter simple-resolver
  (make-router (list
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
                            ("every user"))))
                (list :GET "/user/:id/"
                      (lambda (env)
                          (list 200 (list :content-type "text/plain")
                                (list (format nil "user ~a"
                                              (getf (getf env :uri-params) :id))))))
                (list :GET "/user/:id/:location/"
                      (lambda (env)
                          (let ((p (getf env :uri-params)))
                            (print p)
                            (list 200 (list :content-type "text/plain")
                                  (list (format nil "user ~a ~a"
                                                (getf p :id)
                                                (getf p :location))))))))))

(defparameter nested-resolver
  (make-router (list
                (list :ALL "/repo/:name/"
                      (list
                       (list :GET "/comments/"
                             (lambda (env)
                               '(200 (:content-type "text/plain")
                                 ("repo comments"))))
                       (list :GET "/comments/:id/"
                             (lambda (env)
                               '(200 (:content-type "text/plain")
                                 ("repo comments id"))))
                       (list :GET "/issues/"
                             (lambda (env)
                               '(200 (:content-type "text/plain")
                                 ("repo issues"))))
                       (list :GET "/issues/:id/"
                             (lambda (env)
                               '(200 (:content-type "text/plain")
                                 ("repo issues id")))))))))

(plan :basic-routing)

(is (funcall simple-resolver (list :request-uri "/home/"
                                   :request-method :get))
    '(200 (:content-type "text/plain") ("get home")))

(is (funcall simple-resolver (list :request-uri "/home/"
                           :request-method :post))
    '(201 (:content-type "text/plain") ("POST home")))

(is (funcall simple-resolver (list :request-uri "/home1/"
                                   :request-method :post))
    '(404 (:content-type "text/plain") ("not found")))

(is (funcall simple-resolver (list :request-uri "/user/"
                                   :request-method :option))
    '(200 (:content-type "text/plain") ("every user")))

(is (funcall simple-resolver (list :request-uri "/user/"
                                   :request-method :post))
    '(200 (:content-type "text/plain") ("every user")))

(is (funcall simple-resolver (list :request-uri "/user/"
                                   :request-method :head))
    '(200 (:content-type "text/plain") ("every user")))

(is (funcall simple-resolver (list :request-uri "/user/12/"
                                   :request-method :get))
    '(200 (:content-type "text/plain") ("user 12")))

(is (funcall simple-resolver (list :request-uri "/user/12/india/"
                                   :request-method :get))
    '(200 (:content-type "text/plain") ("user 12 india")))

(is (funcall simple-resolver (list :request-uri "/user/12/"
                                   :request-method :post))
    '(404 (:content-type "text/plain") ("not found")))

(is (funcall simple-resolver (list :request-uri "/user/12/jks/283/"
                                   :request-method :post))
    '(404 (:content-type "text/plain") ("not found")))

(finalize)

(plan :routing-with-clack)

(let ((server (clackup simple-resolver)))
  (flet ((request (method path)
           (http-request (format nil "http://localhost:5000~a" path)
                         :method method)))
    (multiple-value-bind (body status) (request :get "/home/")
      (is body "get home")
      (is status 200))
    (multiple-value-bind (body status) (request :post "/home/")
      (is body "POST home")
      (is status 201))
    (multiple-value-bind (body status) (request :post "/home-not-found/")
      (is body "not found")
      (is status 404))
    (multiple-value-bind (body status) (request :post "/user/")
      (is body "every user")
      (is status 200))
    (multiple-value-bind (body status) (request :put "/user/")
      (is body "every user")
      (is status 200)))
  (stop server))


(finalize)
