parser grammar RFilter;

options { tokenVocab=R; }

stream : (elem|NL|';')* EOF ;

eat :   (NL {((WritableToken)$NL).setChannel(Token.HIDDEN_CHANNEL);})+ ;

elem:   op eat?
    |   atom
    |   '{' eat? {curlies++;} (elem|NL|';')* {curlies--;} '}'
    |   '(' (elem|eat)* ')'
    |   '[' (elem|eat)* ']'
    |   '[[' (elem|eat)* ']' ']'
    |   'function' eat? '(' (elem|eat)* ')' eat?
    |   'for' eat? '(' (elem|eat)* ')' eat?
    |   'while' eat? '(' (elem|eat)* ')' eat?
    |   'if' eat? '(' (elem|eat)* ')' eat?
    |   'else'
        {
        
        WritableToken tok = (WritableToken)_input.LT(-2);
        if (curlies>0&&tok.getType()==NL) tok.setChannel(Token.HIDDEN_CHANNEL);
        }
    ;

atom:   'next' | 'break' | ID | STRING | HEX | INT | FLOAT | COMPLEX | 'NULL'
    |   'NA' | 'Inf' | 'NaN' | 'TRUE' | 'FALSE'
    ;

op  :   '+'|'-'|'*'|'/'|'^'|'<'|'<='|'>='|'>'|'=='|'!='|'&'|'&&'|USER_OP|
        'repeat'|'in'|'?'|'!'|'='|':'|'~'|'$'|'@'|'<-'|'->'|'='|'::'|':::'|
        ','|'...'|'||'| '|'
    ;
