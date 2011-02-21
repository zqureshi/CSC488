#lang racket
#| CSC 488 Winter 2011 - Assignment 1
 
   Zeeshan Qureshi <g0zee@cdf.toronto.edu>
   Note: Extension till sunday night granted by 
         Professor Baumgartner. |#

#| Scheme Interpreter in Scheme.
   Step I: Desugar many common forms.
   
 I.e. expand some forms which are just combinations of more core forms,
  that require no non-local context.
 
 Approach: rewrite rules and pattern matching.
 Will apply to source code given to final interpreter,
  can also try incrementally in Scheme via define-macro. |#


#| A. Pattern-Matching Rewrite Rules. |#

; Since Racket allows 'λ', let's allow it in name 'match-λ'.
(require (rename-in (only-in racket/match match-lambda)
                    (match-lambda match-λ)))

(provide match-rewriter)
#| Write a syntactic form 'match-rewriter' that behaves like 'match-[lambda|λ]' in
    this form described in the documentation (i.e. the '=>' form isn't required):
      (match-lambda clause ...)
      clause = [pat body ...+]
    but if no clause matches then it defaults to just returning its argument.

 Use the first of:
   (define-syntax-rule _ ...)
   (define-syntax _ (syntax-rules _ ...))
   (define-macro _ ...)
  that suffices (without requiring a convoluted implementation).

 If you know or are interested in 'syntax-case' or 'syntax-parse' and want to
  use them for better error messages, you may (but it isn't required at all).

 Style note: if using 'define-syntax[-rule]', try to express as much of the required
  structure as possible via the pattern, e.g. "1 or more" vs "0 or more", sub-parts, etc.
  Do this even if the level of detail isn't necessary for the result template, since
  this easily provides more error checking and documentation. |#

(define-syntax-rule (match-rewriter clause ...)
  (lambda (id)
    (match id
      clause ...
      ; Add the extra no-match clause
      (_ id))))

#| Test Cases
(define test-rewriter
  (match-rewriter
    ('match 'YES)
    ('matched 'YESed))) |#

#| B. Rules for Desugaring Various Binders. |#
(require "rewrite.rkt")
(provide let→λ&call
         letrec→let&set!
         let*→nested-unary-lets)

#| Write rules (that can be passed to 'rewrite') to do (one step) of rewriting:
     
     'let' using 'λ' and function call
       - the "named let" form isn't required
     'letrec' using 'let' and 'set!'
     'let*' using nested unary 'let's
 
 Style note: use as appropriate at least "`", ",", "." from the 'match' pattern language
   (and Scheme s-expression construction syntax), to express the pattern and result. |#

(define let→λ&call
  (match-rewriter
   (`(let ([,var ,val] ...) ,body ..1) `((λ ,var . ,body) . ,val))))

(define letrec→let&set!
  (match-rewriter
   (`(letrec ([,var ,val] ...) ,body ..1) (append 
                                         `(let ,(map (λ (x) `(,x (void))) var))
                                         (map (λ (var val) `(set! ,var ,val)) var val)
                                         body))))

(define let*→nested-unary-lets
  (match-rewriter
   (`(let* (,vars ...) ,body ..1) (foldr
                                 (λ (vars acc) `(let (,vars) ,acc))
                                 `(let () . ,body)  ; append body to a let to make it executable
                                 vars))))

#| Test Cases
(rewrite let→λ&call '(let ([x 4] [y 5]) (+ x y) (+ y x)))
(rewrite let→λ&call '(let ([x 4] [y 5]) x y))
(rewrite let*→nested-unary-lets '(let* ([x 5] [y (+ x 5)] [z (+ y 5)]) (+ z 5))) |#

#| C. Rules for Desugaring Various Conditionals. |#
(provide
   when→if unless→when
   and→if or→if
   cond→if)

#| Write rules (that can be passed to 'rewrite') to do (one step) of rewriting:

     'when' using 'if'
       - to group a sequence of statements as one, use (let () _ ...), not 'begin'
     'unless' using 'when'
     'and' using 'if'
     'or' using 'if'
       - to ponder: why not use DeMorgan; and why aren't we desugaring 'not'?
     'cond' using 'if'
       - the '=>' form isn't required
 
   Be sure to avoid inserting an expression into the result multiple times in a way
    that if the result is run it might evaluate the expression multiple times: any
    side-effects will be repeated! |#

(define when→if
  (match-rewriter
   (`(when ,expr ,body ..1) `(if ,expr (let () . ,body) (void)))))

(define unless→when
  (match-rewriter
   (`(unless ,expr ,body ..1) `(when ,(not expr) (let () . ,body)))))

(define and→if
  (match-rewriter 
   (`(and ,expr ...) (foldr (λ (expr acc) `(if ,expr ,acc #f)) #t expr))))

(define or→if
  (match-rewriter 
   (`(or ,expr ...) (foldr (λ (expr acc) `(if ,expr #t ,acc)) #f expr))))

(define cond→if
  (match-rewriter 
   (`(cond [,expr . ,body] ... [else ,else-body ..1]) (foldr (λ (expr body acc)
                                                               (if (empty? body)
                                                                   `(if ,expr #t ,acc)
                                                                   `(if ,expr (let () . ,body) ,acc)))
                                                             `(let () . ,else-body)
                                                             expr
                                                             body))
   (`(cond [,(and expr (not 'else)) . ,body] ...) (foldr (λ (expr body acc)
                                                           (if (empty? body)
                                                               `(if ,expr #t ,acc)
                                                               `(if ,expr (let () . ,body) ,acc)))
                                                         `(void)
                                                         expr
                                                         body))))
