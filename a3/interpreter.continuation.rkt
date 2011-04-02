#lang racket
#| Interpreter with Runtime-Stack handling, and Continuations.

   This part adds manual handling of the runtime stack, previously
    mirrored and handled by Scheme's stack during the interpreter's
    recursion on the code, as discussed in last week's letcure.
   This part's 'interpret' is tail-recursive, managing an explicit
    stack of continuations --- roughly "expressions to come back to"
    and the environments they were in. Implementing continuations
    for the interpreted language is then an easy stack manipulation! |#
(provide If Set! Sequence Call Call/CC Get Λ
         Binding
         RTS
         interpret interpret-value)

#| Structures representing code. |#
(define-syntax-rule (structs (<name> <field> ...) ...)
  (begin (struct <name> (<field> ...) #:transparent) ...))

(structs
 (If test then else)
 (Set! id value)
 (Sequence statements)
 (Call closure argument)
 (Call/CC closure)
 (Get id)
 (Λ parameter body))

#| Bindings for environments. |#
(structs (Binding id (value #:mutable)))
(define (get-binding id env)
  (findf (match-lambda [(Binding i _) (equal? id i)]) env))

#| The Runtime Stack |#
(define RTS '())
(define (push! top) (set! RTS `(,top . ,RTS)))
(define (pop!) (match RTS [`(,top . ,new-RTS)
                           (set! RTS new-RTS)
                           top]))

#| Structures representing runtime values. |#
(structs
 (Closure environment parameter body)
 (Continuation stack))

#| Interpretation has two main behaviours:
     1. Interpret an expression requiring interpreting a next sub-expression
         then continuing based on its value and the expression.
      For 'If', 'Set!' and 'Sequence': push the expression and environment,
       and interpret the sub-expression.
      For 'Call' and 'Call/CC': push a new (Call '_ <argument>) where <argument> is
       the argument expression or a 'Continuation' containing the current stack,
       and interpret the closure expression.
     2. Make a value and continue by performing the most recent continuation.
      Get/make/pass the runtime value to 'interpret-value'.
 
 Hints to save time / code (and hence bugs due to incomplete coverage).
   There's a pattern to the recursive calls: make a local helper to get
    rid of the repeated statement(s) and fixed argument(s).
   Structures are recognized by 'match' --- see 'get-binding' above.
   Boolean operations are also recognized by match: 'or' is quite useful.
   [And I used 'as' in 'unstable/match' to combine Call, Call/CC clauses.] |#
(define (interpret exp env)
  (match exp
    [(or
      (If <e> _ _)
      (Set! _ <e>)
      (Sequence `(,<e> . ,_))) (push! exp) (push! env) (interpret <e> env)]
    [value (interpret-value value)]))

#| To interpet a value use the environment and waiting expression
    on the stack to determine what to do.

   If the stack is empty simply return the value.

   'If' and 'Set!' are straightforward adaptations of A2.

   'Sequence': the handling is short, be sure to think about it first.

   'Call': the first time it will have the closure/continuation,
    so send it back as a 'Call' with that value instead of '_ .
    To call a 'Continuation', set the stack to be the continuation's
    stack and interpret the value again in this context. |#
(define (interpret-value v)
  (if (empty? RTS) v
      (let ([env (pop!)]
            [exp (pop!)])
        (match exp
          [(If _ then else) (if v (interpret then env) (interpret else env))]
          [(Set! id _) (set-Binding-value! (get-binding id env) v)]
          [(Sequence `(,<e> . ,<rest>)) (if (empty? <rest>) 
                                            v
                                            (interpret (Sequence <rest>) env))]))))

; Easy as 122.
#;(for-each display
          (list (interpret 1 '())
                (interpret (If 1 2 3) '())
                (interpret (Call/CC
                            (Λ 'x (Sequence (list
                                             1
                                             (Call (Get 'x) 2)
                                             3))))
                       '())))