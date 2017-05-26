;;;; cube-world.lisp

(in-package #:example-for-turtle-graphics-and-l-system)

;;; "cube-world" goes here. Hacks and glory await!

(defparameter *width* 1920)
(defparameter *height* 1080)

(defparameter *verts* nil)
(defparameter *indicies* nil)
(defparameter *stream* nil)
(defparameter *running* nil)

(defconstant +pi+ 3.1415927)

(defvar *camera* nil)
(defparameter *i* 1.0)

;;; GPU
(defstruct-g pos-col
  (position :vec3 :accessor pos)
  (color :vec3 :accessor col))

(defun-g tri-vert ((vert pos-col) &uniform (model->world :mat4) (world->cam :mat4) (cam->clip :mat4))
  (values (* cam->clip
             world->cam
             model->world
             (v! (/ (pos vert)
                    (expt 2 3))
                 1.0))
          (:smooth (col vert))))

(defun-g test-g ((color :vec3) (i :float))
  (let ((n (/ (mod i 1000) 1000)))
    (/ (sin (* (+ (* (- 1 n) (- 1 n) color)
                  (* 2 (- 1 n) color))))
       2)))

(defun-g tri-frag ((color :vec3) &uniform (i :float))
  (test-g color i))

(def-g-> prog-1 ()
  :vertex (tri-vert pos-col)
  :fragment (tri-frag :vec3))

;;; CPU
(defun step-demo ()
  (step-host)
  (update-repl-link)
  (clear)

  (map-g #'prog-1
         *stream*
         :i (incf *i*)
         :model->world (m4:* (m4:translation (v! 0.0 -0.5 -1.0))
                             (m4:rotation-from-euler (v! 0
                                                         (/ *i* 100)
                                                         0)))
         :world->cam (m4:translation (v! 0.0 0.0 0.0))
         :cam->clip (cam->clip *camera*))

  (swap))

(defun run-loop ()
  (time (test))
  (loop :while (and *running* (not (shutting-down-p))) :do
     (continuable (step-demo))))

(defun stop-loop ()
  (setf *running* nil))

;;; Mesh
(-> forward (x)
  (let ((n (/ +pi+ 16)))
    `((roll ,n)
      (forward ,(* 1.0 x))
      (push-turtle)
      (push-turtle)

      (roll ,n)
      (yaw ,(* 4 n))
      (pitch ,(* 4 n))
      (set-radius 0.5)
      (forward ,(* 1.0 x))
      (pop-turtle)

      (roll ,(- n))
      (yaw ,(* 4 (- n)))
      (pitch ,(* 4 (- n)))
      (set-radius 0.5)
      (forward ,(* 1.0 x))
      (pop-turtle)

      (pitch ,n)
      (forward ,(* 1.0 x)))))

(defun test ()
  (multiple-value-bind (verts index) (turtle-graphics::make-geometry
                                      (l-system #'parametric-grammar `((circle 4 ,(/ 1 (expt 2 3)))
                                                                       (set-radius 1.0)
                                                                       (forward 1.0))
                                                3))
    (setf *running* t
          *camera* (make-camera)
          *verts* (make-gpu-array (map 'list #'(lambda (x) (list x x))
                                       (remove-if-not #'arrayp verts))
                                  :element-type 'pos-col)
          *indicies* (make-gpu-array (append index (reverse index))
                                     :element-type :unsigned-short)
          *stream* (make-buffer-stream *verts* :index-array *indicies*))))
