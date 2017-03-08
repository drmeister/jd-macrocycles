;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Work with the structures
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(progn
  (setf *default-pathname-defaults* (pathname "/src/cando/jd-macrocycles/"))
  (defparameter *cd*
    (with-open-file
        (fin (probe-file "macro1.cdxml") :direction :input)
      (chem:make-chem-draw fin)))
  (defparameter *agg* (chem:as-aggregate *cd*)))
(print "Done")

(progn
  (defparameter *stereocenters*
    (sort (cando:gather-stereocenters *agg*) #'string< :key #'chem:get-name))
  (cando:set-stereoisomer-func *stereocenters* (constantly :S) :show t)
  (let ((quat-matcher (core:make-cxx-object 'chem:chem-info)))
    (chem:compile-smarts quat-matcher "[C&H0&D4]")
    (chem:map-atoms nil (lambda (a) (when (chem:matches quat-matcher a)
				      (chem:set-configuration a :S)
				      (format t "Set atom ~a to :S~%" (chem:get-name a))))
		    *agg*)))

(defparameter *ff* (energy:setup-amber))

(cando:jostle *agg* 40)

(energy:minimize *agg* :force-field *ff* :restraints-on nil)

(cando:save-mol2 *agg* "macro1.mol2")

