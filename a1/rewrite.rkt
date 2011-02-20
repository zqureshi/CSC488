#lang racket
(provide rewrite)
#| (rewrite rule s) repeatedly calls unary function 'rule' on every "part" 
    of s-expr s, in unspecified order, replacing each part with result of rule, 
    until calling rule makes no more changes to any part. 
 
   Parts are s, elements of s, and (recursively) parts of the elements of s. 
    
   Change is detected by value (with 'equal?', like Java '.equals()'), vs 
    identity/pointer/reference (i.e. 'eq?', like Java '=='). 
  
   The implementation here is in very minimal/core Scheme: 
     Syntactic forms 'define', 'λ', 'if', and function call. 
     Functions 'list?', 'map' and 'equal?' |#
(define (rewrite rule s)
  (let* ([with-subparts-rewritten
          (if (list? s) (map (λ (element) (rewrite rule element))
                             s)
              s)]
         [with-also-rule-self (rule with-subparts-rewritten)])
    (if (equal? with-also-rule-self with-subparts-rewritten)
        with-also-rule-self
        (rewrite rule with-also-rule-self))))
