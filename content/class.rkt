#lang racket
#| Capturing Object Orientation with closures. |#

#| Initial Counter class, single constructor taking count,
    single anonymous method returning count. |#
(let () ; isolate this example from later code
  (define Counter
    (λ (count)
      (λ () count)))
  (define c1 (Counter 488))
  (displayln (c1)) ; 488
  (define c2 (Counter 2107))
  (displayln (c2)) ; 2107
  (displayln (c1)) ; 488
  )

#| Two methods with no arguments. |#
(let () ; isolate this example from later code
  (define Counter
    (λ (count)
      (λ (msg)
        (cond [(equal? msg 'count) count]
              [(equal? msg 'increment!) (set! count (+ count 1))
                                        count]))))
  (define c1 (Counter 488))
  (displayln (c1 'count)) ; 488
  (define c2 (Counter 2107))
  (displayln (c2 'count)) ; 2107
  (displayln (c1 'increment!)) ; 489
  )

#| Define 'class', taking instance variables to set via arguments to constructor,
    and method names with statements. |#
(let ()
  (define-syntax-rule
    (class (<instance-variable> ...)
      (<method-name> <statement>
                     ...)
      ...)
    (λ (<instance-variable> ...)
      (λ (message)
        (cond [(equal? message '<method-name>) <statement>
                                               ...]
              ...))))
  (define Counter
    (class (count)
      (count count)
      (increment! (set! count (+ count 1))
                  count)))
  (define c1 (Counter 488))
  (displayln (c1 'count)) ; 488
  (define c2 (Counter 2107))
  (displayln (c2 'count)) ; 2107
  (displayln (c1 'increment!)) ; 489
  )
#| Let's go the next useful (and quite usable!) step: arguments to methods. |#
(define-syntax-rule
  (class (<instance-variable> ...)
         ((<method-name> <parameter> ...) <statement>
                                          ...)
         ...)
  (λ (<instance-variable> ...)
    (λ (message . arguments)
      (cond [(equal? message '<method-name>)
             (apply (λ (<parameter> ...) <statement> ...)
                    arguments)]
            ...))))
(define Adder
  (class (count)
         ((count) count)
         ((increment-by! by) (set! count (+ count by))
                             count)))
(define a (Adder 488))
(a 'count)
(a 'increment-by! 2107)