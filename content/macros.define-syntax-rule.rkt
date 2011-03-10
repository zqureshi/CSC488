#lang racket

#| Syntax-rules is a macro system where transformations are in a
    special transformation language: pattern of code to transform
    and pattern for transformed version. No (regular) Scheme runs.
   A Syntax-rules preprocessor could be made without using a Scheme
    compiler nor interpreter. In this way, it's the approach for C
    preprocessing, or people doing C++ template meta-programming. |#

(define-syntax-rule
  ; Operation to match, as a code pattern.
  ; Syntax-rules language understands nesting and '...' (as 0 or more).
  (Let ((<id> <exp>) ; angle brackets still just a convention for reader.
        ...)
       <body>)
  ; Result pattern.
  ((λ (<id> ...) ; some of the intelligence of '...'.
     <body>)
   <exp> ...))
;
(Let ((x 488)
      (y 2107))
     (Let ((x (+ x 1)))
          (+ x y)))

#| Syntax-rules knows about lexical (syntactic) scope, hence runtime scope
    since equivalent in Scheme (like most languages now, which are then
    called "lexically scoped"). |#
;
(define-syntax-rule
  (swap! x y) ; '!' convention alerting reader to the mutation side-effect
  (let ([t x])
    (set! x y)
    (set! y t)))
(define t "tee")
(define y "wye")
(swap! t y)
t
y
; Run the Macro Stepper, and hover over the t's and y's to see their scopes.
;   Names in the source pattern ('x' 'y'), if they refer to names in the source
;    ('t' 'y', as opposed to '<body>' in 'Let', which most of the time ends up
;    referring to non-variable expressions) end up meaning those names with
;    their original scope (where the macro was used) in the result pattern
;    (as if the result was copied and pasted in wherever the macro was used).
;   Other names in the result pattern ('let' 't' 'set!') are taken literally,
;    and scoped to where the macro was defined (like call-by-value functions).

; It came up again in lecture: why can't swap be a function?
(define (swap x y)
  (let ([t x])
    (set! x y)
    (set! y t)))
