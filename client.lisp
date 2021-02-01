;;;; Networking

(in-package #:cl-cdsi)

(defparameter *base-url* "https://cdsi-api.herokuapp.com/api")

(defun fetch (&rest fragments)
  (let* ((path (format nil "~{~A~^/~}" (push *base-url* fragments)))
         (url (cl-ppcre:regex-replace-all " " path "%20"))
         (yason:*parse-object-key-fn* #'parse-keyword)
         (stream (drakma:http-request url :want-stream t)))
    (setf (flexi-streams:flexi-stream-external-format stream) :utf-8)
    (convert-all (yason:parse stream :object-as :plist))))

;;; Parsing tools

(defun is-empty (thing)
  (and (stringp thing) (= (length thing) 0)))

(defun is-parsable (thing)
  (and (stringp thing) (> (length thing) 0)))

(defun parse-boolean (thing)
  (cond ((or (eq thing "Y") (eq thing "Yes") (eq thing "1") (eq thing 1)) t)
        (t nil)))

(defun parse-keyword (thing)
  (intern (string-upcase (kebab:to-kebab-case thing)) "KEYWORD"))

(defun safe-parse (fn thing)
  (cond ((is-parsable thing) (funcall fn thing))
        ((is-empty thing) nil)
        (t thing)))

(defun safe-parse-timestring (thing)
  (safe-parse #'local-time:parse-timestring thing))

(defun safe-parse-keyword (thing)
  (safe-parse #'parse-keyword thing))

(defun safe-parse-float (thing)
  (safe-parse #'parse-float thing))

(defun safe-parse-integer (thing)
  (safe-parse #'parse-integer thing))

(defun safe-parse-boolean (thing)
  (safe-parse #'parse-boolean thing))

(defun safe-parse-interval (thing)
  (safe-parse #'cdsi-dt:parse-interval thing))

;;; Property list tools

(defun plist-keys (plist)
  (loop :for (a b) :on plist :by #'cddr
        :while b
        :collect a))

(defun plist-values (plist)
  (loop :for (a b) :on plist :by #'cddr
        :while b
        :collect b))

(defun is-plist (thing)
  (and
   (consp thing)
   (eq 0 (rem (length thing) 2))
   (every #'identity (mapcar #'symbolp (plist-keys thing)))))

(defun with-plist-key (fn key)
  "Create a function that will apply the function (fn) to the value returned by (getf plist key)"
  (lambda (plist)
    (let ((value (getf plist key)))
      (when value
            (setf (getf plist key) (funcall fn value))))))

(defun visit (fn thing)
  "Visit each node in a 'property tree' and apply fn to the node. A 'property tree' is a property list with values that can be another property list or a list of property lists."
  (if (is-plist thing) (funcall fn thing))
  (if (listp thing) (mapc #'(lambda (thing) (visit fn thing)) thing))
  thing)

;;; Conversion tools

(defparameter *date-keys* '(:DATE-ADMINISTERED
			    :DOB
			    :ASSESSMENT-DATE
			    :EARLIEST-DATE
			    :PAST-DUE-DATE
			    :RECOMMENDED-DATE
			    :DATE-ADDED
			    :DATE-UPDATED))

(defparameter *keyword-keys* '(:MVX
			       :ANTIGEN
			       :VACCINE-NAME
			       :GENDER
			       :DOSE-NUMBER
			       :EVALUATION-STATUS
			       :SERIES-STATUS
			       :VACCINE-GROUP
			       :TARGET-DISEASE
			       :SERIES-TYPE
			       :SERIES-PRIORITY
			       :SERIES-GROUP-NAME))

(defparameter *integer-keys* '(:CVX
			       :GUIDELINE-CODE
			       :CODE
			       :SERIES-GROUP
			       :FORECAST-NUM
			       :FROM-TARGET-DOSE
			       :SERIES-TYPE
			       :SERIES-PREFERENCE
			       :EQUIVALENT-SERIES-GROUPS))

(defparameter *float-keys* '(:VOLUME
			     :CHANGED-IN-VERSION))

(defparameter *boolean-keys* '(:RECURRING-DOSE
			       :FORECAST-VACCINE-TYPE
			       :FROM-PREVIOUS
			       :DEFAULT-SERIES
			       :PRODUCT-PATH ))

(defparameter *interval-keys* '(:ABS-MIN-AGE
				:MIN-AGE
				:EARLIEST-REC-AGE
				:LATEST-REC-AGE
				:MAX-AGE				
				:EFFECTIVE-DATE
				:CESSATION-DATE
				:BEGIN-AGE
				:END-AGE
				:ABS-MIN-INT
				:MIN-INT
				:EARLIEST-REC-INT
				:LATEST-REC-INT
				:MIN-AGE-TO-START
				:MAX-AGE-TO-START ))

(defun convert-values (fn keys thing)
  "Apply the function (fn) to each of the values retrieved by (getf key thing)"
  (let ((fns (mapcar (lambda (key) (with-plist-key fn key)) keys)))
    (mapc (lambda (fn) (visit fn thing)) fns))
  thing)

(defun convert-all (thing)
  (convert-values #'safe-parse-timestring *date-keys* thing)
  (convert-values #'safe-parse-keyword *keyword-keys* thing)
  (convert-values #'safe-parse-integer *integer-keys* thing)
  (convert-values #'safe-parse-float *float-keys* thing)
  (convert-values #'safe-parse-interval *interval-keys* thing)
  (convert-values #'safe-parse-boolean *boolean-keys* thing))