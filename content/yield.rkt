#lang racket
#| Python's 'yield'.
   Make re-enterable functions, that yield and can be called again
    to resume where they left off.
   Actually, make function to return yieldable instances, so can
    have more than one copy running, each independent. |#

#| Save current continuation in an existing variable (outside the expression). |#
(define-syntax-rule
  (set!/cc <var>
           <stmt>
           ...)
  (let/cc k
    (set! <var> k)
    <stmt>
    ...))

#| Warm-up versions. |#
#; ; Each call to f breaks out to return 2.
(define f
  (λ ()
    (let/cc yield
      (yield 2)
      (yield 1)
      (yield 0)
      (yield 7))))
#; ; Simplest resume: calls produce 2, 1, 1, 1, ...
(define f
  (let ([called? #f]
        [resume (void)])
  (λ ()
    (when called? (resume)) ; abort this call, resume into first
    (set! called? #t)
    (let/cc yield
      (set!/cc resume
               (yield 2))
      (yield 1)
      (yield 0)
      (yield 7)))))

#; ; Manually-coded full version, pattern captured below by yieldable.
(define g
  (λ ()
    (let ([called? #f]
          [resume (void)])
      (λ ()
        (if called?
            (resume)
            (let/cc yield
              (set! called? #t)
              (set!/cc resume
                       (yield 1))
              (set!/cc resume
                       (yield 2))
              (set!/cc resume
                       (yield 3))))))))

(define-syntax-rule
  (yieldable <yield-name>
             <stmt>
             ...)
  (λ () ; Call to produce yieldable instance (the λ below).
    (let ([called? #f]
          [yield (void)]
          [resume (void)])
      ; In lecture we (sharp students!) used let*, could use letrec.
      ; Moving the function to a 'define' makes finer distinction,
      ;  and allows sweeter name-and-make function syntax.
      ;
      ; Also, changed signature to allow arbitrary number of return values
      ;  (usually 0 or 1), so also calling 'apply' to pass them to 'yield'.
      (define (<yield-name> . return-values)
        ; Called by user body code in order to yield.
        ;   Jumps out via 'yield', with 'resume' saving ability to jump back
        ;   (to after '(apply yield _)') which returns to (finishes)
        ;   user's body call to <yield-name>.
        (set!/cc resume
                 (apply yield return-values)))
      (λ () (if called? (resume) ; abort this call, jump back into first call
                (set!/cc yield
                         (set! called? #t)
                         <stmt>
                         ...))))))

(define f
  (yieldable yield! ; changed name from 'yield' for reader's sake
             (yield! 1)
             (yield! 2)
             (yield! 3)))
(define f0 (f))
(f0)
(define f1 (f))
(f1)
(f0)
(f0)
(f1)

(define t ((yieldable y (y (begin (y 1) 2)))))
(t) (t) (t) (t)
