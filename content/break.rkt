#lang racket
#| Continuations to implement break out of a loop. |#

; A manual loop, without even letrec.
(let ([loop (void)]
      [x 7])
  (set! loop
        (λ ()
          (displayln x)
          (when (> x 0)
            (set! x (- x 1))
            (loop))))
  (loop))

; Capture as 'while'.
(define-syntax-rule
  (while <condition> <break-name>
         <stmt>
         ...)
  (letrec ([loop (λ ()
                   (let/cc <break-name>
                     (when <condition>
                       <stmt>
                       ...
                       (loop))))])
    (loop)))

(define x 7)
(while (>= x 0) _
       (displayln x)
       (set! x (- x 1)))
(set! x 7)
(symbol?
 (while (>= x 0) stop!
        (displayln x)
        (when (= x 3) (stop! 'hi))
        (set! x (- x 1))))