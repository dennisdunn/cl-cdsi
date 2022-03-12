(in-package :caselib)

(defun csv-read (path)
  "Read the csv file and return the list of rows."
  (let ((data (cl-csv:read-csv path :unquoted-empty-string-is-nil t
                               :trim-outer-whitespace t )))
    (values (make-header (car data)) (cdr data))))

(defun make-header (row)
  "Read the first line of the testcase file and return an alist mapping column name to column number."
  (loop for key in  row
        for idx from 0
        collect (cons key idx)))

(defun csv-value (header row column)
  "Read the nth item of the row as identified by the header and column name."
  (nth (cdr (assoc column header :test #'string=)) row))
