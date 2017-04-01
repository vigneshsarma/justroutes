(in-package :cl-user)
(defpackage justroutes
  (:use :cl :clack.request))
(in-package :justroutes)

(defun mprint (&rest args)
  (format t "~{~a ~}" args))

(defun make-route (method path handler &key (type :function) (meta nil))
  (mprint method path handler type meta)
  (list (cons :method method) (cons :path path) (cons :handler handler)
        (cons :type type) (cons :meta meta)))

(defun resolve-route (route-table env)
  (declaim (optimize (debug 3)))
  (let* ((r (cdr (assoc (getf env :request-uri) route-table :test #'equal)))
         (h (cdr (assoc :handler r))))
    (funcall h env)))

(defun make-clack-handler (routes)
  (let ((route-table (reduce
                     #'(lambda (acc item)
                         (let* ((r (apply #'make-route item))
                                (path (cdr (assoc :path r))))
                           (acons path r acc)))
                      routes :initial-value nil)))
    (lambda (env)
      (resolve-route route-table env))))
