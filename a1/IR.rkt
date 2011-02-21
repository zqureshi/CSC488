#lang racket
#| Scheme Interpreter in Scheme.
   Step III: Restricted Scheme as a Racket Domain Specific Language (DSL). |#

#| The operations in Restricted Scheme from Step II are:
     'if'
     'LOOKUP', 'UPDATE!'
     'CLOSURE', 'CALL'

 You'll implement 'LOOKUP', 'UPDATE!', 'CLOSURE' and 'CALL', managing the environment.
 But control flow and (non-closure) function values will be 'inherited' from Scheme.
 
 Approach: implement operations (advanced "runtime" support) in Racket.
 Will inspire an interpreter, which manually traverses the source code tree.
 Also runs in Racket. |#

#| Represent bindings (a value, and a variable name as symbol) with 'Binding': |#
(struct Binding (id (value #:mutable)))
(provide Binding)
#| Here Racket's 'struct' creates a type 'Binding' with named fields 'id' and 'value',
    with 'value' updatable, with the following support:

     a constructor function 'Binding' taking an id and value
     functions taking a Binding as first argument:
       'Binding?' : unary predicate
       'Binding-id', 'Binding-value' : accessors
       'set-Binding-value!' : mutator, taking new value as second argument |#

#| Represent environments as lists of Bindings.

 Notice that by adding/finding bindings to/from the front, more local bindings
  will shadow/hide less local ones automatically.
 
 Implement 'LOOKUP' and 'UPDATE!' to take an environment and variable name, so that:
   'LOOKUP' returns the value of the variable
   'UPDATE!' take a third argument value and changes the variable's value to it
 Hint for style: 'findf'. |#
#;(provide LOOKUP UPDATE!)

#| Make a struct 'Closure' with the fields 'environment', 'parameters' and 'function',
    for the three arguments to 'CLOSURE', so that one can simply: |#
#;(define CLOSURE Closure)
#;(provide CLOSURE Closure)

#| Write 'CALL' taking a Closure and list of arguments, calling the Closure's function
    with its environment extended by adding the arguments to the environment. |#
#;(provide CALL)