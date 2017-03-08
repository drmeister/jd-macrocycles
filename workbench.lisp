;;;
;;; Initialize everything
;;;

(setf asdf:*user-cache* "/src/.cache/")
(load "/root/quicklisp/setup.lisp")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Work with the structures
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq *default-pathname-defaults* (pathname "/src/"))

(progn
  (setq *default-pathname-defaults* (pathname "/src/"))
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

(defparameter *fix-atoms*
  (sort (select:atoms-with-property *agg* :fix) #'string<
	:key (lambda (a) (string (getf (chem:properties a) :fix)))))

(progn
  (defparameter *fix-points* (anchor:circle-points 40 (length *fix-atoms*)))
;;; Anchor the :fix atoms to *fixed-points*
  (anchor:on-points *fix-atoms* *fix-points*))


(defparameter *ff* (energy:setup-amber))

(cando:jostle *agg* 40)

(energy:minimize *agg* :force-field *ff* :restraints-on nil)

(cando:save-mol2 *agg* "/src/mc.mol2")

(chem:save-mol2 *agg* "/src/mc-test.mol2")

