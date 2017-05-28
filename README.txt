This is example for turtle-graphics and l-system with cepl.

To run it you need to clone into ~/quicklisp/local-projects

https://github.com/ebrasca/turtle-graphics
https://github.com/ebrasca/example-for-turtle-graphics-and-l-system

Run it with

(ql:quickload :example-for-turtle-graphics-and-l-system)
(in-package :example-for-turtle-graphics-and-l-system)

;; start with
(progn (repl *width* *height* 3.3)
       (run-loop))

;; If you change test after start.
(run-loop)
