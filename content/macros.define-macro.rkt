#lang racket
#| User-Defined Syntactic Forms, aka Macros.
   
 Some consider it meta-programming.

 I'm reluctant to make such a distinction.
   Because people try to reason about the good/bad based on that.
   C++ was originally C preprocessor macros, but not now.
    Does that make C++ good or bad? Silly question.
   Originally couldn't add new datatypes in languages, that would be
    "changing the language". But now common, i.e. OO adds new types.
    Is that changing the language? Yet, people fuss over whether one
    should have Scheme/Lisp's power to "change the language".
   Originally couldn't even add named functions (used goto's).

  Do you want to work in First Order Logic? Then every time you use
   Induction you have to write it out for the particular predicate,
   and then assume it for that predicate. That would be put in a book
   of "Design Patterns for Mathematicians", as a recipe you follow for
   each predicate. Well, Design Patterns for programming are programs
   for programmers to follow to write out the code pattern every time
   an instance of the pattern comes up, in languages where they can't
   express the pattern (for all instances), name it, put it in a library.

  But now Meta-Programming has a positive connotation to many people.
   So is it good?

  Let's just see some of the Macro systems from Lisp/Scheme, understand
   the mechanisms, and use them a bit. They're a tool to be aware of.

  At worst they're useful, or at least practice, for program transformation. |#

#| The semantics of local variables (while still accessing higher scopes)
    can be captured with closures. E.g. Scheme/ML/Haskell let: |#
#;(let ([y 2])
    (let ([x 1])
      (+ x y)))
;  can be implemented as make and call clousures immediately:
#;((λ (y)
     ((λ (x)
        (+ x y))
      1))
   2)

#| One system: A Scheme program transforms another Scheme program's code
    during a pre-processing step.
   Roughly: read in code, transform, write out, call Scheme on written code.

   Notice that in this model the transformer code and transformed code run
    separately (and at different times): no mingling of their code.

   Could just inline the code to be transformed as a literal, and also call
    eval on the result. |#
#;(begin
    (define (transformer sexp) <return-transformed-version>)
    (define (program-source '<code-to-be-transformed-then-run>))
    (eval
     (transformer
      program-source)))
#| Common, most Lisp/Schemes have various ways to specify transformer and source
    in the same file. |#

#| Get the defmacro system, module 'defmacro' from package 'mzlib'. |#
(require #;mzlib/defmacro ;{gets everything}
         (only-in mzlib/defmacro define-macro) #;{gets just define-macro})

#| Introduce a transformer/Pre-processor that automatically runs on (the parts of)
    the non-transformer code. Is given any 'Let' expressions via sub-expressions
    as arguments (as lists of symbols, numbers, etc, lists of lists of ...).
   Calling it 'Let' to keep separate from existing 'let'. |#
;
; The Transformer Environment (which libraries automatically included for its use)
;  doesn't contain 'first'. So require the racket standard library for use in the
;  pre-processing phase. 
(require (for-syntax racket)) ; so 'racket' library usable in define-macro
;
(define-macro (Let <bindings> <body>)
    `((λ ,(map first <bindings>)
        ,<body>)
      . ,(map second <bindings>)))
;
; It works:
(Let ((x 488)
      (y 2107))
     (Let ((x (+ x 1)))
          (+ x y)))
;
; Exercise: Run the Macro Stepper (the Foot Icon beside "Run").
; Exercise: Rewrite the macro using 'match-lambda'.
; Exercise: Write a 'Define' macro that turns
#;(Define (<id> <formals>)
          <body>)
;  into a simple define with λ (see the posted "rewriting.rkt").
