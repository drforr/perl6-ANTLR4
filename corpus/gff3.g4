grammar gff3;

document
    : '##gff-version 3\n' line+
    ;

line
    : commentline
    | dataline
    ;

dataline
    : seqid '\t' source '\t' type '\t' start '\t' end '\t' score '\t' strand '\t' phase '\t' attributes? EOL
    ;

attributes
    : attribute (';' attribute)*
    ;

attribute
    : TEXT '=' TEXT
    ;

seqid
    : TEXT
    ;
         
source
    : TEXT
    ;

type
    : TEXT
    ;

start
    : TEXT
    ;

end
    : TEXT
    ;

strand
    : TEXT
    ;

score
    : TEXT
    ;

phase
    : TEXT
    ;

commentline
    : COMMENTLINE
    ;   

COMMENTLINE
    : '#' .*? EOL
    ;

EOL
    : '\r'? '\n'
    ;

TEXT
    : (CHAR | SYMBOL | DIGIT)+
    ;

fragment CHAR
    : [a-zA-Z]
    ;

fragment DIGIT
    : [0-9]
    ;

fragment SYMBOL
    : '.'
    | ':'
    | '^'
    | '*'
    | '$'
    | '@'
    | '%'
    | '!'
    | '+'
    | '_'
    | '?'
    | '-'
    | '|'
    | ','
    | ' '
    ;
