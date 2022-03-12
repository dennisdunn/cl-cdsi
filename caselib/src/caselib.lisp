(in-package :caselib)

(defparameter *data-path* "./caselib/data/")
(defparameter *file-name* "cdsi-healthy-childhood-and-adult-test-cases-v4.8.csv")

(defun mk-catalog (header row)
<<<<<<< HEAD
  (make-catalog :id (csv-value header row "CDC_Test_ID")
=======
 (make-catalog :id (csv-value header row "CDC_Test_ID")
>>>>>>> 9d80208d7fae6719b95588e4cb137b0f044e595b
                :name (csv-value header row "TestCase_Name")
                :text (csv-value header row "General_Description")))

(defun mk-testcase (header row)
<<<<<<< HEAD
  (make-testcase :id (csv-value header row "CDC_Test_ID")
                 :name (csv-value header row "TestCase_Name")
                 :text (csv-value header row "General_Description")
                 :patient (mk-patient header row)
                 :evaluation (mk-evaluation header row)
                 :forecast (mk-forecast header row)
                 :doses (mk-doses header row)))
=======
 (make-testcase :id (csv-value header row "CDC_Test_ID")
                :name (csv-value header row "TestCase_Name")
                :text (csv-value header row "General_Description")
                :patient (mk-patient header row)
                :evaluation (mk-evaluation header row)
                :forecast (mk-forecast header row)
                :doses (mk-doses header row)))
>>>>>>> 9d80208d7fae6719b95588e4cb137b0f044e595b

(defun mk-patient (header row)
  (make-patient :dob (csv-value header row "DOB")
                :gender (csv-value header row "gender")
                :assessment (csv-value header row "Assessment_Date")))

(defun mk-forecast (header row)
  (make-forecast :number (csv-value header row "Forecast_#")
<<<<<<< HEAD
                 :earliest (csv-value header row "Earliest_Date")
                 :recommended (csv-value header row "Recommended_Date")
                 :past-due (csv-value header row "Past_Due_Date")
                 :vaccine-group (csv-value header row "Vaccine_Group")
                 :forecast-type (csv-value header row "Forecast_Test_Type")))

(defun mk-evaluation (header row)
  (make-evaluation :series-status (csv-value header row "Series_Status")
                   :evaluation-type (csv-value header row "Evaluation_Test_Type")))

(defun mk-doses (header row)
  (loop for n from 1 to 7
        when (csv-value header row (format nil "Date_Administered_~a" n))
        collect (make-dose :number (format nil "~a" n)
                           :date-administered (csv-value header row (format nil "Date_Administered_~a" n))
                           :vaccine-name (csv-value header row (format nil "Vaccine_Name_~a" n))
                           :cvx (csv-value header row (format nil "CVX_~a" n))
                           :mvx (csv-value header row (format nil "MVX_~a" n))
                           :evaluation-status (csv-value header row (format nil "Evaluation_Status_~a" n))
                           :evaluation-reason (csv-value header row (format nil "Evaluation_Reason_~a" n)))))
=======
                  :earliest (csv-value header row "Earliest_Date")
                  :recommended (csv-value header row "Recommended_Date")
                  :past-due (csv-value header row "Past_Due_Date")
                  :vaccine-group (csv-value header row "Vaccine_Group")
                  :forecast-type (csv-value header row "Forecast_Test_Type")))

(defun mk-evaluation (header row)
  (make-evaluation :series-status (csv-value header row "Series_Status")
                :evaluation-type (csv-value header row "Evaluation_Test_Type")))

(defun mk-doses (header row)
  (loop for n from 1 to 7
    when (csv-value header row  (format nil "Date_Administered_~a" n))
    collect (make-dose :number (format nil "~a" n)
                      :date-administered (csv-value header row  (format nil "Date_Administered_~a" n))
                      :vaccine-name (csv-value header row  (format nil "Vaccine_Name_~a" n))
                      :cvx (csv-value header row (format nil "CVX_~a" n))
                      :mvx (csv-value header row (format nil "MVX_~a" n))
                      :evaluation-status (csv-value header row  (format nil "Evaluation_Status_~a" n))
                      :evaluation-reason (csv-value header row  (format nil "Evaluation_Reason_~a" n)))))
>>>>>>> 9d80208d7fae6719b95588e4cb137b0f044e595b

(defun get-catalog ()
  "Get a catalog of all testcases."
  (let* ((path (merge-pathnames *data-path* *file-name*)))
    (multiple-value-bind (header rows) (csv-read path)
      (mapcar (lambda (row) (mk-catalog header row)) rows))))

(defun get-case (id)
  "Load the testcase identified by the argument."
  (find-if (lambda (x) (string= id (testcase-id x))) (catalog)))
