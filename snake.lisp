;;;; Author: Chrisotpher Segale
;;;; Version: 1.00

(defun main ()
  (macrolet ((car-last (sequence)
	       `(car (last ,sequence)))
	     (clear-screen (ren)
	       `(progn
		  (sdl2:set-render-draw-color ,ren 255 255 255 255)
		  (sdl2:render-clear ,ren)))
	     (draw-head (ren head)
	       `(progn
		  (sdl2:set-render-draw-color ,ren 153 76 0 255)
		  (sdl2:render-fill-rect ,ren ,head)
		  (sdl2:render-draw-rect ,ren ,head)))
	     (draw-fruit (ren fruit)
	       `(progn
		  (sdl2:set-render-draw-color ,ren 255 0 0 255)
		  (sdl2:render-fill-rect ,ren ,fruit)
		  (sdl2:render-draw-rect ,ren ,fruit)))
	     (move-rect (r x y w h)
	       `(progn
		  (sdl2:free-rect ,r)
		  (setf ,r (sdl2:make-rect ,x ,y ,w ,h))))
	     (move-snake (s x y)
	       `(move-rect ,s ,x ,y 20 20))
	     (intersect-body (r b)
	       `(block intersect
		 (if ,b
		     (loop for i from 0 to (1- (length ,b)) do
			  (when (sdl2:has-intersect ,r (elt ,b i))
			    (return-from intersect t)))
		     nil))))
    (let ((width 800) (height 600))
      (labels ((twentyp (n)
	       (= (mod n 20) 0))
	       (gen-fruit ()
		 (loop with x = (random width) and y = (random height) while t do
		      (if (or (not (twentyp x)) (not (twentyp y)))
			  (setf x (random width) y (random height))
			  (return-from gen-fruit (sdl2:make-rect x y 20 20))))))
	(sdl2:with-init (:video)
	  (sdl2:with-window (win :title "snake" :w width :h height :flags '(:shown))
	    (sdl2:with-renderer (ren win :index -1 :flags '(:accelerated :presentvsync))
	      (let* ((currentx (/ width 2))
		     (currenty (/ height 2))
		     previousx
		     previousy
		     (direction 'left)
		     (head (sdl2:make-rect currentx currenty 20 20))
		     (s-body (make-list 0))
		     (fruit (gen-fruit)))
		(sdl2:with-event-loop (:method :poll)
		  (:keyup
		   (:keysym keysym)
		   (when (sdl2:scancode= (sdl2:scancode-value keysym) :scancode-escape)
		     (sdl2:push-event :quit)))
		  (:keydown
		   (:keysym keysym)
		   (cond ((sdl2:scancode= (sdl2:scancode-value keysym) :scancode-up)
			  (setf direction 'up))
			 ((sdl2:scancode= (sdl2:scancode-value keysym) :scancode-down)
			  (setf direction 'down))
			 ((sdl2:scancode= (sdl2:scancode-value keysym) :scancode-left)
			  (setf direction 'left))
			 ((sdl2:scancode= (sdl2:scancode-value keysym) :scancode-right)
			  (setf direction 'right))
			 (t nil)))
		  (:idle
		   ()
		   (clear-screen ren)
		   (if (or (< currentx 0) (>= currentx width) (< currenty 0) (>= currenty height) (intersect-body head s-body))
		       (sdl2:push-event :quit)
		       (progn
			 (setf previousx currentx previousy currenty)
			 (cond ((eq direction 'up)
				(decf currenty 20))
			       ((eq direction 'down)
				(incf currenty 20))
			       ((eq direction 'left)
				(decf currentx 20))
			       ((eq direction 'right)
				(incf currentx 20))
			       (t nil))
			 (move-snake head currentx currenty)
			 (when (intersect-body head s-body)
			   (sdl2:push-event :quit))
			 (when (sdl2:has-intersect head fruit)
			   (sdl2:free-rect fruit)
			   (push (sdl2:make-rect previousx previousy 20 20) s-body)
			   (setf fruit (gen-fruit))
			   (loop while (intersect-body fruit s-body) do
				(setf fruit (gen-fruit))))))
		   (draw-head ren head)
		   (sdl2:set-render-draw-color ren 0 255 0 255)
		   (push (sdl2:make-rect previousx previousy 20 20) s-body)
		   (sdl2:free-rect (car-last s-body))
		   (setf s-body (butlast s-body))
		   (when s-body
		     (loop for i from 0 to (1- (length s-body)) do
			  (sdl2:render-fill-rect ren (elt s-body i))
			  (sdl2:render-draw-rect ren (elt s-body i))))
		   (draw-fruit ren fruit)
		   (sdl2:render-present ren)
		   (sdl2:delay 130))
		  (:quit () t))))))))))
