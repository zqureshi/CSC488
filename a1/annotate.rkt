#lang racket
#| Scheme Interpreter in Scheme.
   Step II: Annotate Implicit Operations to Create an Intermediate Represention.

 Steps I, II and III are in fact compilers from a large subset of Scheme forms
  to a very small subset (of Racket).

 Approach: tree traversal and pattern matching.
 Will apply to source code given to final interpreter,
  will also run in Racket by implementing the annotations. |#

#| Consider the subset of Scheme consisting of:

    atomic literals

    'if'
     - with both branches
    
    variable access
    'set!'

    'λ|lambda'
     - without variable-arity, keywords or default arguments
    function call
     - without keyword arguments

   Write 'annotate'.
   It takes code in this language and makes syntactically explicit:
     variable lookup
     function call
     dependence of variables and closures on an environment

   Do this by changing:

     <variable> → (LOOKUP ENV '<variable>)
     (set! <variable> <expression>) → (UPDATE! ENV '<variable> <expression>)
 
     (<function-expression> <argument-expression> ...)
       → (CALL <function-expression> (list <argument-expression> ...))
     ([λ|lambda] (<parameter-name> ...) <stmt0> <stmt> ...)
       → (CLOSURE ENV
                  '(<parameter-name> ...)
                  (λ (ENV) <stmt0> <stmt> ...) |#
(provide annotate)

(define (annotate code)
  (match code
    [`(if ,expr ,br1 ,br2) `(if ,(annotate expr) ,(annotate br1) ,(annotate br2))]
    [`(set! ,var ,expr) `(UPDATE! ENV ',var ,(annotate expr))]
    [`(,(and (or 'lambda 'λ) lambda/λ) (,params ...) . ,body) `(CLOSURE ENV ',params
                                                                        (λ (ENV) . ,(map annotate body)))]
    [`(,fn ,args ...) `(CALL ,(annotate fn) (list . ,(map annotate args)))]
    [(? symbol?) `(LOOKUP ENV ',code)]
    [_ code]))

#| Test Case
> (annotate '(set! moo (λ (x) (+ x 1))))
'(UPDATE! ENV 'moo (CLOSURE ENV '(x) (λ (ENV) (CALL (LOOKUP ENV '+) (list (LOOKUP ENV 'x) 1))))) |#
