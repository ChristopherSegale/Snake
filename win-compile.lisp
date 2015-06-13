(load "snake.asd")
(asdf:load-system :snake)
(save-lisp-and-die "snake.exe" :toplevel #'main :executable t :application-type :gui)
