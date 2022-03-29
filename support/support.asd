;;;; cl-cdsi.asd

(defsystem :support
  :description "CDSi supporting data package."
  :author "Dennis Dunn <ansofive@gmail.com>"
  :license "MIT"
  :version "0.1.0"
  :serial t
  :depends-on (:cxml
               :xpath
               :cl-csv
               :cl-ppcre)
  :components ((:module "src"
                        :serial t
                        :components ((:file "package")
                                     (:file "config")
                                     (:file "antigen")
                                     (:file "schedule"))))
  :in-order-to ((test-op (test-op :support/tests))))

(defsystem :support/tests
  :author "Dennis Dunn <ansofive@gmail.com>"
  :license "MIT"
  :version "0.1.0"
  :depends-on (:support
               :fiveam)
  :components ((:module "t"
                        :serial t
                        :components ((:file "package")
                                     (:file "main")
                                     (:file "support"))))
  :perform (test-op (op c) (symbol-call :fiveam :run!
                                        (find-symbol* 'all-tests :support/tests))))
