;;;; cube-world.asd

(asdf:defsystem #:example-for-turtle-graphics-and-l-system
  :description "Describe example-for-turtle-graphics-and-l-system here"
  :author "Bruno Cichon <ebrasca.ebrasca@openmailbox.org>"
  :license "Specify license here"
  :depends-on (#:cepl
	       #:varjo
	       #:cepl.camera
               #:livesupport
	       #:cepl.sdl2

               #:l-system
               #:turtle-graphics)
  :serial t
  :components ((:file "package")
               (:file "example-for-turtle-graphics-and-l-system")))
