
(in-package :cl-jupyter-user)

(format t "Loading tools~%")

(defparameter *ff* (energy:setup-amber))

;;; Start a swank server
(defun start-swank-server ()
  (load "/home/app/slime/swank-loader.lisp")
  (let ((swank-loader-init (find-symbol "INIT" "SWANK-LOADER")))
    (funcall swank-loader-init :delete nil :reload nil :load-contribs nil))
  (let ((swank-create-server (find-symbol "CREATE-SERVER" "SWANK")))
    (mp:process-run-function 'swank-main
			     (lambda () (funcall swank-create-server
						 :port 4005
						 :interface "0.0.0.0")))))

(defun hello-world ()
  (print "Hello world"))


;;; Set the stereoisomer using a list of (atom-name config) pairs
;;; Example:  (set-stereoisomer-mapping *agg* '((:C1 :R) (:C2 :S))
(defun set-stereoisomer-mapping (matter atom-name-to-config)
  (loop for (name config) in atom-name-to-config          
     do (let ((atom (chem:first-atom-with-name matter name)))
	  (format t "Atom name: ~a  atom: ~a config: ~a~%" name atom config)
	  (chem:set-configuration atom config))))

;;; Set a list of stereocenters using an integer
;;; A 0 bit is :S and 1 bit is :R
;;; The value 13 is #b1101  and it sets the configuration of the atoms
;;;    to (:R :S :R :R ).
;;;  The least significant bit is the first stereocenter and the most significant bit is the last.
(defun set-stereoisomer-using-number (list-of-centers num)
  (loop for atom across list-of-centers
     for tnum = num then (ash tnum -1)
     for config = (if (= (logand 1 tnum) 0) :s :r)
     do (format t "~a -> ~a   num: ~a~%" atom config tnum)))

;;; Return a vector of stereocenters sorted by name
(defun stereocenters-sorted-by-name (matter)
  (sort (cando:gather-stereocenters matter) #'string< :key #'chem:get-name))

;;; Set all of the stereocenters to config (:S or :R)
(defun set-all-stereocenters-to (list-of-centers config &key show)
  (cando:set-stereoisomer-func list-of-centers (constantly config) :show show))

(defun calculate-all-stereochemistry (vector-of-centers)
  (dotimes (i (length vector-of-centers))
    (format t "Center: ~a  config: ~a~%" (elt vector-of-centers i) (chem:calculate-stereochemical-configuration (elt vector-of-centers i)))))

;;; Return the number of stereoisomers 
(defun number-of-stereoisomers (vector-of-centers)
  (expt 2 (length vector-of-centers)))

;;; Return a full pathname or signal an error if the file does not exist
(defun ensure-filename (file)
  (let ((p (probe-file file)))
    (or p (error "Could not find the file ~a" file))))

;;; Load a structure from a chemdraw file
(defun load-chemdraw (file &optional name)
  (let ((cd (with-open-file (fin (ensure-filename file)  :direction :input)
	      (chem:make-chem-draw fin))))
    (if name
	(error "Add code to pull a named structure out of a chemdraw file")
	(chem:as-aggregate cd))))

#++(defun carboxylic-acid-atoms (matter unique-name)
  (let ((c (chem:first-atom-with-name matter unique-name))
	(carb (core:make-cxx-object 'chem:chem-info)))
    (chem:compile-smarts carb "C1(~O2)~O3")
    (or (chem:matches carb c)
	(error "The atom ~a is not a carboxylic acid carbon" c))
    (let* ((m (chem:get-match carb))
	   (o2 (chem:get-atom-with-tag m :2))
	   (o3 (chem:get-atom-with-tag m :3)))
      (list c o2 o3))))

    
