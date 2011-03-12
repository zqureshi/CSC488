#lang racket

#| Part I: Completely Manual Interpreter. |#
(provide interpret Binding)

#| Recall the language and IR from A1 Parts II and III.

The language (rephrased to emphasize the semantics):
    atomic literal (e.g. boolean, number and string constants)
    variable access, update
    two-way conditional
    closure literal (lambda expression)
    closure call

A modified syntax:
  (LOOKUP <variable>)
  (UPDATE! <variable> <expression>)
  (CLOSURE (<parameter-name> ...)
           <stmt0> <stmt> ...))
  (if <condition> <consequent> <alternative>)
  (CALL <function-expression>
        <argument-expression> ...)
  <atomic-literal>

Write 'interpret' taking such code as a value/data,
 i.e. as lists, symbols, booleans, numbers and strings,
 i.e. someone can quote the above forms and pass them in,
 i.e. you're working on the "Abstract Syntax Tree", not
  an unparsed string of characters.
It also takes an environment, as a list of 'Binding's. |#
(struct Binding (id (value #:mutable)) #:transparent)
(struct Closure (environment parameters body) #:transparent)

#|  Helper to locate specific binding |#
(define (find-binding env id)
  (findf (λ (binding)
           (equal? (Binding-id binding) id))
         env))

(define (LOOKUP env id)
  (Binding-value (find-binding env id)))

(define (UPDATE! env id val)
  (set-Binding-value! (find-binding env id) val))

(define (interpret exp env)
  (match exp
    [`(LOOKUP ,var) (LOOKUP env var)]
    [`(UPDATE! ,var ,expr) (let ([val (interpret expr env)])
                            (UPDATE! env var val))]
    [`(CLOSURE (,param ...) ,body ...) (Closure env param body)]
    [`(CALL ,func-expr . ,args-expr) (let* ([clojure (interpret func-expr env)]
                                            [args (map (λ (expr) (interpret expr env)) args-expr)]
                                            [env (append
                                                      (map Binding (Closure-parameters clojure) args)
                                                      (Closure-environment clojure))])
                                       (foldl (λ (stmt prev) (interpret stmt env)) 
                                              (void) (Closure-body clojure)))]
    [atomic-literal atomic-literal]))

#| Approach: you are now managing code traversal, closure code
    and environments. In particular, don't use 'eval', nor try
    to create Scheme closures from the code.

   You'll still want a Closure struct containing an environment
    and parameter names, but instead of a 'function' field have a
    'body' field containing code to interpret manually when the
    instance of a closure is called. |#
