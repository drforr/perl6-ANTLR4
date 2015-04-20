grammar fasta;

sequence
    : section+
    ;

section
    : descriptionline 
    | sequencelines
    | commentline 
    ;

sequencelines
    : SEQUENCELINE+
    ;

descriptionline
    : DESCRIPTIONLINE
    ;

commentline
    : COMMENTLINE
    ;   

COMMENTLINE
    : ';' .*? EOL
    ;

DESCRIPTIONLINE
    : '>' TEXT ('|' TEXT )* EOL
    ;

TEXT
    : (DIGIT | LETTER | SYMBOL)+ 
    ;

EOL
    : '\r'? '\n'
    ;

fragment DIGIT
    : [0-9]
    ;

fragment LETTER
    : [A-Za-z]
    ;

fragment SYMBOL
    : '.'
    | '-'
    | '+'
    | '_'
    | '.'
    | ' '
    | '['
    | ']'
    | '('
    | ')'
    | ','
    | '/'
    | ':'
    | '&'
    | '\''
    ;

SEQUENCELINE
    : LETTER+ EOL
    ;
