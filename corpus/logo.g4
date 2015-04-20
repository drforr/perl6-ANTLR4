grammar logo;

prog
    : (line? EOL)+ line?
    ;

line
    : cmd+ comment?
    | comment
    | print comment?
    | procedureDeclaration
    ;
     
cmd
    : repeat
    | fd
    | bk
    | rt
    | lt
    | cs
    | pu
    | pd
    | ht
    | st
    | home
    | label
    | setxy
    | make
    | procedureInvocation
    | ife
    | stop
    | fore
    ;

procedureInvocation
    : name expression*
    ;

procedureDeclaration
    : 'to' name parameterDeclarations* EOL? (line? EOL)+ 'end'
    ;

parameterDeclarations
    : ':' name (',' parameterDeclarations)*
    ;

func
    : random
    ;

repeat
    : 'repeat' number block
    ;

block
    : '[' cmd+ ']'
    ;
    
ife
    : 'if' comparison block
    ;

comparison
    : expression comparisonOperator expression
    ;

comparisonOperator
    : '<' 
    | '>' 
    | '='
    ;

make
    : 'make' STRINGLITERAL value
    ;

print
    : 'print' (value | quotedstring)
    ;

quotedstring
    : '[' (quotedstring | ~']')* ']'
    ;

name
    : STRING
    ;

value
    : STRINGLITERAL
    | expression
    | deref 
    ;

signExpression 
    : (('+'|'-'))* (number | deref | func)
    ;

multiplyingExpression
    : signExpression (('*' | '/') signExpression)*
    ;

expression 
     : multiplyingExpression (('+'|'-') multiplyingExpression)*
     ;

deref
    : ':' name
    ;

fd
    : ('fd' | 'forward') expression
    ;

bk
    : ('bk' | 'backward') expression
    ;

rt
    : ('rt' | 'right') expression
    ;

lt
    : ('lt' | 'left') expression
    ;

cs
    : 'cs' | 'clearscreen'
    ;

pu
    : 'pu' | 'penup'
    ;

pd
    : 'pd' | 'pendown'
    ;

ht
    : 'ht' | 'hideturtle'
    ;

st
    : 'st' | 'showturtle'
    ;

home
    : 'home'
    ;

stop
    : 'stop'
    ;
        
label
    : 'label'
    ;

setxy
    : 'setxy' expression expression
    ;

random
    : 'random' expression
    ;

fore
    : 'for' '[' name expression expression expression ']' block
    ;

number
    : NUMBER
    ;

comment
    : COMMENT
    ;
     
STRINGLITERAL
    : '"' STRING
    ;

STRING
    : [a-zA-Z] [a-zA-Z0-9_]*
    ;
    
NUMBER
    : [0-9]+
    ;

COMMENT
    : ';' ~[\r\n]*
    ;

EOL
    : '\r'? '\n'
    ;

WS
    : [ \t\r\n]->skip
    ;
