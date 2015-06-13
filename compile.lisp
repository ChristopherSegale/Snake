(load "snake.asd")
(asdf:load-system :snake)
(save-lisp-and-die "snake" :toplevel #'main :executable t)
