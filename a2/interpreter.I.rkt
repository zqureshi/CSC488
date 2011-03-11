#lang racket

#| Part I: Completely Manual Interpreter. |#
(provide #;interpret Binding)

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
(struct Binding (id (value #:mutable)))
#;(define (interpret exp env))

#| Approach: you are now managing code traversal, closure code
    and environments. In particular, don't use 'eval', nor try
    to create Scheme closures from the code.

   You'll still want a Closure struct containing an environment
    and parameter names, but instead of a 'function' field have a
    'body' field containing code to interpret manually when the
    instance of a closure is called. |#
