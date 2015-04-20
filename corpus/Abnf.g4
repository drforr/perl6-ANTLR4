grammar Abnf;

rulelist
    : rule_* EOF
;

rule_
    : ID ('=' | '=/') elements
;

elements
    : alternation
;

alternation:
    concatenation ('/' concatenation)*
;

concatenation:
    repetition (repetition)*
;

repetition
    : repeat? element
;

repeat
    : INT
    | (INT? '*' INT?)
;

element
    : ID
    | group
    | option
    | STRING
    | NumberValue
    | ProseValue
;

group
    : '(' alternation ')'
;

option
    : '[' alternation ']'
;

NumberValue
    : '%' (BinaryValue | DecimalValue | HexValue)
;

fragment BinaryValue
    : 'b' BIT+ (('.' BIT+)+ | ('-' BIT+))?
;

fragment DecimalValue
    : 'd' DIGIT+ (('.' DIGIT+)+ | ('-' DIGIT+))?
;

fragment HexValue
    : 'x' HEX_DIGIT+ (('.' HEX_DIGIT+)+ | ('-' HEX_DIGIT+))?
;

ProseValue
    : '<' (~'>')* '>'
;


ID
    : ('a'..'z'|'A'..'Z') ('a'..'z'|'A'..'Z'|'0'..'9'|'-')*
;

INT
    : '0'..'9'+
;

COMMENT
    : ';' ~('\n'|'\r')* '\r'? '\n' -> channel(HIDDEN)
;

WS
    : ( ' '
    | '\t'
    | '\r'
    | '\n'
    ) -> channel(HIDDEN)
;

STRING
    :  '"' (~'"')* '"'
;

fragment BIT
    : '0'..'1'
;

fragment DIGIT
    : '0'..'9'
;

fragment
HEX_DIGIT
    : ('0'..'9'|'a'..'f'|'A'..'F')
;
