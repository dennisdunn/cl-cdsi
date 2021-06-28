(in-package :supporting-data)

(defparameter *data-files-location* #P"/home/owner/source/cdsi/cl-cdsi/data-files/supporting-data/4.10/")

(defparameter *schedule-fname* #P"ScheduleSupportingData.xml")

(defparameter *antigen-file-re* "AntigenSupportingData- (.*)-508.xml")

(defun antigen-names ()
  "Return a list of antigen names."
  (remove-if #'null 
             (mapcar (lambda (fname)
                       (ppcre:register-groups-bind (antigen)
                                                   (*antigen-file-re* (namestring fname))
                                                   antigen))
                     (uiop:directory-files *data-files-location*))))


(defun read-antigen (name)
  "Load and parse the antigen file identified by the name."
  (let* ((fname (ppcre:regex-replace "[(.*)]+" *antigen-file-re* name))
         (path (merge-pathnames *data-files-location* fname)))
    (xmls:parse (uiop:read-file-string path))))

;;; Exported functions

;; Antigen

(defun antigen-keys ()
  "Get the antigen names as keyword symbols."
  (mapcar #'util:name->keyword (antigen-names)))

(defun get-antigen (key)
  "Get the xml associated with this keyword symbol."
  (let ((name (getf (symbol-plist key) :name)))
    (read-antigen name)))

(defun antigen-series (antigen)
  "Get the series' associated with this antigen."
  (xmls:xmlrep-find-child-tags 'series antigen))

;; Series

(defun series-type (series)
  "Return the series type of the series. :STANDARD or :RISK"
  (util:name->keyword (xmls:xmlrep-string-child (xmls:xmlrep-find-child-tag 'seriestype series) "risk")))

(defun series-indications (series)
  "Get the indications associated with this series."
  (xmls:xmlrep-find-child-tags 'indication series))  

(defun series-required-genders (series)
  "Get the required genders of the series."
  (remove-if #'null
             (mapcar #'util:name->keyword 
                     (mapcar (lambda (x) (xmls:xmlrep-string-child x nil)) 
                             (xmls:xmlrep-find-child-tags 'requiredgender series)))))

;; Schedule

(defun get-schedule ()
  "Get the schedule supporting data."
  (xmls:parse (uiop:read-file-string (merge-pathnames *data-files-location* *schedule-fname*))))



