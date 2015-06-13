;;;; snake.asd

(asdf:defsystem #:snake
  :serial t
  :description "Basic snake game."
  :author "Christopher Segale"
  :license "MIT"

  :depends-on (:sdl2)

  :components
  ((:file "snake")))
