grammar creole;
   
document
    : (line? CR)*
    ;
 
line
    : markup+ 
    ;
 
markup
    : bold
    | italics
    | href
    | title
    | hline
    | text
    | listitem
    | image
    | tablerow
    | tableheader
    | nowiki
    ;
    
text
    : (TEXT | RSLASH)+ ('\\\\' text)*
    ;
 
bold
    : '**' markup+ '**'?
    ;
 
italics
    : RSLASH RSLASH markup+ RSLASH RSLASH
    ;
 
href
    : LBRACKET text ('|' markup+)? RBRACKET
    | LBRACE text '|' markup+ RBRACE 
    ;
 
image
    : LBRACE text RBRACE
    ;
 
hline
    : '----'
    ;
 
listitem
    : ('*'+ markup)
    | ('#'+ markup)
    ;
 
tableheader
    : ('|=' markup+)+ '|' WS*
    ;
 
tablerow
    : ('|' markup+)+ '|' WS*
    ;
 
title
    : '='+ markup '='*
    ;
 
nowiki
    : NOWIKI
    ;
 
HASH
    : '#'
    ;
 
LBRACKET
    : '[['
    ;
 
RBRACKET
    : ']]'
    ;
 
LBRACE
    : '{{'
    ;
 
RBRACE
    : '}}'
    ;
 
TEXT
    : (LETTERS
    | DIGITS 
    | SYMBOL 
    | WS)+
    ;
 
WS
    : [ \t]
    ;
 
CR
    : '\n'
    | EOF
    ;
 
NOWIKI
    : '{{{' .*? '}}}'
    ;

RSLASH
    : '/'
    ;

fragment LETTERS
    : [a-zA-Z]
    ;
 
fragment DIGITS
    : [0-9]
    ;
 
fragment SYMBOL
    : '.'
    | ';'
    | ':'
    | ','
    | '('
    | ')'
    | '-'
    | '\\'
    | '\''
    | '~'
    | '"'
    | '+'
    ;
 
