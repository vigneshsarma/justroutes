(in-package :cl-user)
(defpackage justroutes
  (:use :cl :cl-ppcre)
  (:import-from alexandria make-keyword)
  (:export make-resolver
           make-router
           make-clack-handler))
(in-package :justroutes)

(defun mprint (&rest args)
  "Print function similar to the one found in python/clojure"
  (format t "~{~a ~}" args))

(defparameter url-parameters (create-scanner "\:([^/]+)"))

(defun make-route (method path handler &key (type :function) (meta nil))
  (multiple-value-bind (new-path updated?)
      (regex-replace-all url-parameters path "(?<\\1>[a-zA-Z0-9]+)")
    (let ((test-fn
           (if updated?
               (let ((params (mapcar (lambda (p)
                                       (make-keyword (string-upcase (subseq p 1))))
                                     (all-matches-as-strings url-parameters path)))
                     (path-regex (create-scanner (format nil "^~a$" new-path))))
                 (lambda (url)
                   (multiple-value-bind (matched? param-vals)
                       (scan-to-strings path-regex url)
                     (when matched?
                       (values t (loop for name in params
                                    for val across param-vals
                                    append (list name val)))))))
               (lambda (url) (equal path url)))))
      (list :method method :test-fn test-fn :handler handler
            :type type :meta meta))))

(defun make-resolver (route-table)
  (lambda (env)
    (let* ((r-uri (getf env :request-uri))
           (r-method (getf env :REQUEST-METHOD)))
      (multiple-value-bind (route params)
          (loop for r in route-table
             do (multiple-value-bind (matched? params)
                    (funcall (getf r :test-fn) r-uri)
                  (when (and matched?
                             (or (equal (getf r :method) :ALL)
                                 (equal (getf r :method) r-method)))
                    (return (values r (list :uri-params params))))))
      (if route
          (funcall (getf route :handler) (append env params))
          '(404 (:content-type "text/plain")
            ("not found")))))))

(defun make-router (routes)
  (make-resolver (reduce
                  #'(lambda (acc item)
                      (let* ((r (apply #'make-route item)))
                        (cons r acc)))
                  routes :initial-value nil)))

(defun make-clack-handler (routes)
  (make-router routes))
