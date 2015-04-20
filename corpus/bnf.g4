grammar bnf;

rulelist
    : rule_* EOF
;

rule_
    : lhs ASSIGN rhs
    ;

lhs
    : id
    ;


rhs
    : alternatives
    ;

alternatives
    : alternative (BAR alternative)*
    ;

alternative
    : element*
    ;

element
    : optional
    | zeroormore
    | oneormore
    | text
    | captext
    | id
    ;

optional
    : REND alternatives LEND
    ;

zeroormore
    : RBRACE alternatives LBRACE
    ;

oneormore
    : RPAREN alternatives LPAREN
    ;

captext
    : CAPTEXT
    ;

text
    : TEXT
    | STRINGLITERAL
    ;

id
    : ID
    ;

ID
    : '<' .*? '>'
    ;

ASSIGN
    : '::='
    ;

LPAREN
    : ')'
    ;

RPAREN
    : '('
    ;

LBRACE
    : '}'
    ;

RBRACE
    : '{'
    ;

LEND
    : ']'
    ;

REND
    : '['
    ;

BAR
    : '|'
    ;

CAPTEXT
    : UPPERCASE_LETTER TEXT
    ;

TEXT
    : (UPPERCASE_LETTER | LOWERCASE_LETTER | DIGIT| SYMBOL)+
    ;


STRINGLITERAL
    : '"' .*? '"'
    ;

fragment UPPERCASE_LETTER
    : 'A'..'Z'
    ;

fragment LOWERCASE_LETTER
    : 'a'..'z'
    ;

fragment DIGIT
    : '0'..'9'
    ;

fragment SYMBOL
    : '\u0021'..'\u0027'
    | '\u002a'..'\u002f'
    | '\u003a'..'\u0040'
    | '\u005e'..'\u0060'
    | '\u00a1'..'\u00FF'
    | '\u0152'..'\u0192'
    | '\u2013'..'\u2122'
    | '\u2190'..'\u21FF'
    | '\u2200'..'\u22FF'
    ;

WS
    : [ \r\n\t] -> skip
    ;
