#lang racket 
#| (rewrite rule s) repeatedly calls unary function 'rule' on every "part" 
    of s-expr s, in unspecified order, replacing each part with result of rule, 
    until calling rule makes no more changes to any part. 
 
   Parts are s, elements of s, and (recursively) parts of the elements of s. 
    
   Change is detected by value (with 'equal?', like Java '.equals()'), vs 
    identity/pointer/reference (i.e. 'eq?', like Java '=='). 
  
   The implementation here is in very minimal/core Scheme: 
     Syntactic forms 'define', 'λ', 'if', and function call. 
     Functions 'list?', 'map' and 'equal?' |# 
(define rewrite 
  (λ (rule s) 
    (define with-subparts-rewritten 
      (if (list? s) 
          (map (λ (element) (rewrite rule element)) 
               s) 
          s)) 
    (define with-also-rule-self 
      (rule with-subparts-rewritten)) 
    (if (equal? with-also-rule-self with-subparts-rewritten) 
        with-also-rule-self 
        (rewrite rule with-also-rule-self)))) 
 
#| E.g. post-order ability (recall/review post/pre/in-order depth-first tree traversal). |# 
(define arithmetic 
   ; 'match-lambda': syntactic form making a unary function pattern matching on argument. 
   ;  Combines λ and match: Guide 12, Reference 8. 
   ; Quoting and Quasiquoting for literal and semi-literal data: Guide 4.10 & 11. 
  (match-lambda (`(+ ,a ,b) (+ a b)) 
                (`(* ,a ,b) (* a b)) 
                (a a))) 
(rewrite arithmetic '(+ (* 2 (+ 3 4)) 5)) 
 
#| E.g. pre-order ability ... |# 
(define differentiation 
  (match-lambda (`(d/dx (+ ,f ,g)) `(+ (d/dx ,f) (d/dx ,g))) 
                (`(d/dx (- ,f ,g)) `(- (d/dx ,f) (d/dx ,g))) 
                (`(d/dx (* ,f ,g)) `(+ (* (d/dx ,f) ,g) 
                                       (* ,f (d/dx ,g)))) 
                (`(d/dx sin) `cos) 
                (`(d/dx cos) `(- 0 sin)) 
                (`(d/dx 0) 0) 
                (f f))) 
(rewrite differentiation '(d/dx (+ (* cos cos) (* sin sin)))) 
;  ... and a mixture: 
(rewrite differentiation '(d/dx (d/dx sin))) 
 
#| Implementation of 'rewrite' using 'define' syntactic sugar for make-and-name function, 
    and sequential local binding with 'let*'. Let's use 'rewrite' to do part of it! |# 
(rewrite 
 (match-lambda ; Rule for make-and-name function. 
   ; Angle brackets are valid in Scheme identifiers, not meaningful to Scheme, just 
   ;  a convention for the reader, indicating non-literals in code. 
   ; The '.' means rest/tail, like '|' in Prolog; infix version of 'cons': Guide 3.8.  
   ; "Formals" is the unambiguous term (vs "parameters"/"arguments") for parameter names 
   ;  of a function. 
   (`(define ,<id> (λ ,<formals> . ,<body>)) 
    `(define (,<id> . ,<formals>) . ,<body>)) 
   (<s> <s>)) 
 '(define rewrite 
    (λ (rule s) 
      (let* ([with-subparts-rewritten 
              (if (list? s) (map (λ (element) (rewrite rule element)) s) s)] 
             [with-also-rule-self (rule with-subparts-rewritten)]) 
        (if (equal? with-also-rule-self with-subparts-rewritten) 
            with-also-rule-self 
            (rewrite rule with-also-rule-self))))))
