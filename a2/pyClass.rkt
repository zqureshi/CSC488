#lang racket

#| Part I. CSC148/50 Pythonic classes. |#
#;(provide pyClass)

#| Write 'pyClass', a variant of the posted 'class' from lecture.
   Part III will compile some CSC148/50 Python classes to this. |#

#; ; A small example of usage.
(define Stack
  (pyClass ((storage '())
            (size 0)) ; yes, tracking size manually is silly
           ((empty? self) (zero? (self 'size))) ; or (length (self 'storage))
           ((push! self o) (self 'storage `(,o . (self 'storage)))
                           (self 'size (add1 (self 'size))))
           ((pop! self) (begin0 (first (self 'storage))
                                (self 'storage (rest (self 'storage)))
                                (self 'size (sub1 (self 'size)))))))
#;(let () ; so I can just comment out one big statement
    (define s (Stack))
    (displayln (s 'empty?))
    (s 'push! 488)
    (s 'push! 2107)
    (displayln (s 'pop!))
    (displayln (s 'size))
    (s 'size 2) ; a bad idea
    )

#| Details, including suggestion for steps to modify 'class':
   (a) Instance variables *all* specify initial values (a single expression).
       If 'class' isn't changed, this will be handled (and optional) automatically,
        since Racket's λ allows (<parameter> <default-value>) instead of <parameter>.
       But, in the next step, the instance variable names will be separately needed.
       So make a small change to 'class' to make it more specific.
   (b) Public getter/setters for instance variables are automatically created.
       Ignore 'self', but make the public usage work (e.g. (s 'size) and (s 'size 2)).
       Add to the 'cond', detecting these new messages, and check whether arguments
        is empty or not, and return or set the instance variable.
       Assume method and instance variable names are never the same (this is called
        "share a namespace"): so it doesn't matter whether you put the getter/setter
        clauses before or after the method clauses.
   (c) Now for 'self': it's used internally to refer to the instance.
       The name is a Python (actually older) convention, vs e.g. "this" in Java.
       First, name the "instance λ" (versus the "constructor λ") 'self' in a 'letrec',
        and return it in the 'letrec' body.
       Second, pass it to the methods, now assumed to have an extra initial parameter
        (with name given by the user, which is okay because even if it isn't 'self'
        it will shadow the 'letrec' 'self') to receive it: replace 'arguments' with
        'self arguments' --- 'apply' can take initial arguments before the list of
        the rest. |#
#;(define-syntax-rule
    (pyClass ???)
    (λ ???))
