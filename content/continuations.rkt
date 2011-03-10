#lang racket
#| Introduction to Continuations. |#

; Control flow of
(+ (* 2 3)
   (* 4 5))
;  is
(* 2 3)
(* 4 5)
(+ 6 20)

; Continuation of (* 2 3) is:
(λ (x)
  (+ x
     (* 4 5)))
; I.e. there's expression (* 2 3), and what will be done with its result.

; Continuation of (* 4 5) is:
(λ (x)
  (+ 6
     x))

; let/cc assigns continuation of whole let/cc to <name>
#;(let/cc <name>
    <stmt>
    ...) ; <name> is function that jumps here and returns its argument

(define k0 (void))
; No effect on vale of this expression:
(+ (let/cc k
     (set! k0 k)
     (* 2 3))
   (* 4 5))
; But now k0 has saved continuation of (* 2 3) (see the λ above).
(k0 0)
(k0 488)
(k0 (* 2 3))
; But more than just the closure, also aborts control flow and jumps there.
(+ (let/cc k
     (k 488) ; jumps out (an "escaping" continuation) of this let/cc,
             ;  uses 488 for its value instead of 6
     (* 2 3))
   (* 4 5))

(+ 1 (k0 2107)) ; aborts the (+ 1 _) and goes back to earlier expression
; but Racket protects top-level statements, won't re-execute the statements
;  following that earlier expression.

