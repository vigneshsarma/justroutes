(in-package :cl-user)
(defpackage justroutes
  (:use :cl)
  (:export make-resolver
           make-router
           make-clack-handler))
(in-package :justroutes)

(defun mprint (&rest args)
  "Print function similar to the one found in python/clojure"
  (format t "~{~a ~}" args))

(defun make-route (method path handler &key (type :function) (meta nil))
  (list :method method :path path :handler handler
        :type type :meta meta))

(defun make-resolver (route-table)
  (lambda (env)
    (let* ((r-uri (getf env :request-uri))
           (r-method (getf env :REQUEST-METHOD))
           (route (loop for r in route-table
                     do (when (and (equal (getf r :path) r-uri)
                                   (or (equal (getf r :method) :ALL)
                                       (equal (getf r :method) r-method)))
                          (return r)))))
      (if route
          (funcall (getf route :handler) env)
          '(404 (:content-type "text/plain")
            ("not found"))))))

(defun make-router (routes)
  (make-resolver (reduce
                  #'(lambda (acc item)
                      (let* ((r (apply #'make-route item)))
                        (cons r acc)))
                  routes :initial-value nil)))

(defun make-clack-handler (routes)
  (make-router routes))
