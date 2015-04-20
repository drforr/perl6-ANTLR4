grammar asm6502;

prog
    : (line? EOL)+
    ;

line
    : comment 
    | instruction
    | assemblerinstruction
    | lbl
    ;
   
instruction
    : label? opcode argumentlist? comment?
    ;

assemblerinstruction
    : argument? assembleropcode argumentlist? comment?
    ;

assembleropcode
    : ASSEMBLER_INSTRUCTION
    ;

lbl
    : label ':'
    ;

argumentlist
    : argument (',' argumentlist)?
    ;

label
    : name
    ;

argument
    : prefix? (number | name | string | '*') (('+' | '-') number)?
    | '(' argument ')'
    ;

prefix
    : '#'
    ;

string
    : STRING
    ;

name
    : NAME
    ;

number
    : NUMBER
    ;

comment
    : COMMENT
    ;
      
opcode
    : OPCODE
    ;

ASSEMBLER_INSTRUCTION
    : 'ORG'
    | 'EQU'
    | 'ASC'
    | 'DS'
    | 'DFC'
    | '='
    ;

OPCODE  
    : 'ADC'	
    | 'AND'	
    | 'ASL'	
    | 'BCC'	
    | 'BCS'	
    | 'BEQ'	
    | 'BIT'	
    | 'BMI'	
    | 'BNE'	
    | 'BPL'
    | 'BRA'
    | 'BRK'	
    | 'BVC'	
    | 'BVS'	
    | 'CLC'	
    | 'CLD'	
    | 'CLI'	
    | 'CLV'	
    | 'CMP'	
    | 'CPX'	
    | 'CPY'	
    | 'DEC'	
    | 'DEX'	
    | 'DEY'	
    | 'EOR'	
    | 'INC'	
    | 'INX'	
    | 'INY'	
    | 'JMP'	
    | 'JSR'	
    | 'LDA'	
    | 'LDY'	
    | 'LDX'	
    | 'LSR'	
    | 'NOP'	
    | 'ORA'	
    | 'PHA'
    | 'PHX'
    | 'PHY'
    | 'PHP'	
    | 'PLA'	
    | 'PLP'
    | 'PLY'
    | 'ROL'	
    | 'ROR'	
    | 'RTI'	
    | 'RTS'	
    | 'SBC'	
    | 'SEC'	
    | 'SED'	
    | 'SEI'	
    | 'STA'	
    | 'STX'	
    | 'STY'
    | 'STZ'
    | 'TAX'	
    | 'TAY'	
    | 'TSX'	
    | 'TXA'	
    | 'TXS'	
    | 'TYA'
    | 'adc'	
    | 'and'	
    | 'asl'	
    | 'bcc'	
    | 'bcs'	
    | 'beq'	
    | 'bit'	
    | 'bmi'	
    | 'bne'	
    | 'bpl'
    | 'bra'
    | 'brk'	
    | 'bvc'	
    | 'bvs'	
    | 'clc'	
    | 'cld'	
    | 'cli'	
    | 'clv'	
    | 'cmp'	
    | 'cpx'	
    | 'cpy'	
    | 'dec'	
    | 'dex'	
    | 'dey'	
    | 'eor'	
    | 'inc'	
    | 'inx'	
    | 'iny'	
    | 'jmp'	
    | 'jsr'	
    | 'lda'	
    | 'ldy'	
    | 'ldx'	
    | 'lsr'	
    | 'nop'	
    | 'ora'	
    | 'pha'
    | 'phx'
    | 'phy'
    | 'php'	
    | 'pla'	
    | 'plp'
    | 'ply'
    | 'rol'	
    | 'ror'	
    | 'rti'	
    | 'rts'	
    | 'sbc'	
    | 'sec'	
    | 'sed'	
    | 'sei'	
    | 'sta'	
    | 'stx'	
    | 'sty'
    | 'stz'
    | 'tax'	
    | 'tay'	
    | 'tsx'	
    | 'txa'	
    | 'txs'	
    | 'tya'
    ;
      
NAME
    : [a-zA-Z] [a-zA-Z0-9."]*
    ;

NUMBER
    : '$'? [0-9a-fA-F]+
    ;

COMMENT
    : ';' ~[\r\n]*
    ;

STRING
    : '"' ~["]* '"'
    ;

EOL
    : '\r'? '\n'
    ;

WS
    : [ \t]->skip
    ;
