#lang racket
#| Annotate tail calls in Scheme code built from
    non-quoted literals, variables, 'if', 'set!', 'λ',
    and function call.
   Tail calls are annotated as (τ: <fn-exp> <arg> ...). |#
(provide annotate-tails)
(require (only-in "match-diamond.rkt" match◇))
(define (annotate-tails code [tail? #t])
  (let ([tail (λ (code) (annotate-tails code #t))]
        [not-tail (λ (code) (annotate-tails code #f))]
        [preserve-tail (λ (code) (annotate-tails code tail?))])
    (match◇ code
            ((λ <formals>
               <body> ...
               <return>)
             (λ <formals>
               ,@(map not-tail `<body>)
               ,(tail `<return>)))
            ((if <test>
                 <then>
                 <else>)
             (if ,(not-tail `<test>)
                 ,(preserve-tail `<then>)
                 ,(preserve-tail `<else>)))
            ((set! <var> <exp>)
             (set! <var> ,(not-tail `<exp>)))
            ((<fn-exp> <arg> ...)
             (,@(if tail? '(τ:) '())
              ,(not-tail `<fn-exp>) ,@(map not-tail `<arg>)))
            (<var/literal>
             <var/literal>))))
