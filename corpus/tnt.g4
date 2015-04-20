grammar tnt;

equation
    : expression '=' expression
    ;

atom
    : number
    | variable
    ;

number
    : SUCCESSOR* ZERO
    ;

variable
    : SUCCESSOR* (A | B | C | D | E) PRIME*
    ;     

expression
    : atom
    | expression '+' expression
    | expression '*' expression
    | '(' expression ')'
    | '~' expression
    | forevery expression
    | exists expression  
    ;

forevery
    : FOREVERY variable ':'
    ;

exists
    : EXISTS variable ':'
    ;
          
ZERO
    : '0'
    ;

SUCCESSOR
    : 'S'
    ;

A
    : 'a'
    ;

B
    : 'b'
    ;

C
    : 'c'
    ;

D
    : 'd'
    ;

E
    : 'e'
    ;

PRIME
    : '\''
    ;

FOREVERY
    : 'A'
    ;

EXISTS
    : 'E'
    ;

WS
    : [ \r\t\n]->skip
    ;

