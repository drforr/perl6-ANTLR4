grammar redcode;

file
    : line+
    ;

line
    : (comment | instruction) EOL
    ;

instruction
    : opcode ('.' modifier)? mmode? number (',' mmode? number)? comment?
    ;

opcode
    : DAT 
    | MOV 
    | ADD 
    | SUB 
    | MUL 
    | DIV 
    | MOD 
    | JMP 
    | JMZ 
    | JMN 
    | DJN 
    | CMP 
    | SLT 
    | SPL 
    | ORG
    | DJZ
    ;
    
modifier
    : A 
    | B 
    | AB 
    | BA 
    | F 
    | X 
    | I
    ;

 mmode
    : '#'
    | '$'
    | '@'
    | '<'
    | '>'
    ;
 
 number
    : ('+' | '-')? NUMBER
    ;
 
 comment
     : COMMENT
     ;

A
    : 'A'
    ;

B
    : 'B'
    ;

AB
    : 'AB'
    ;

BA
    : 'BA'
    ;

F
    : 'F'
    ;
 
X
    : 'X'
    ;

I
    : 'I'
    ;

DAT
    : 'DAT'
    ;

MOV
    : 'MOV'
    ;

ADD
    : 'ADD'
    ;

SUB
    : 'SUB'
    ;

MUL
    : 'MUL'
    ;

DIV
    : 'DIV'
    ;

MOD
    : 'MOD';

JMP
    : 'JMP'
    ;

JMZ
    : 'JMZ'
    ;

JMN
    : 'JMN'
    ;

DJN
    : 'DJN'
    ;

CMP
    : 'CMP'
    ;

SLT
    : 'SLT'
    ;

DJZ
    : 'DJZ'
    ;

SPL
    : 'SPL'
    ;

ORG
    : 'ORG'
    ;

NUMBER
    : [0-9]+
    ;

COMMENT
    : ';' ~[\r\n]*
    ;

EOL
    : [\r\n]+
    ;

WS
    : [ \t]->skip
    ;

