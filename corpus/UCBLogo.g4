/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 by Bart Kiers
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * Project      : logo-parser; an ANTLR4 grammar for UCB Logo
 *                https://github.com/bkiers/logo-parser
 * Developed by : Bart Kiers, bart@big-o.nl
 */
grammar UCBLogo;

parse
 : instruction* EOF
 ;

instruction
 : procedure_def               #procedureDefInstruction
 | macro_def                   #macroDefInstruction
 | procedure_call_extra_input  #procedureCallExtraInputInstruction
 | procedure_call              #procedureCallInstruction
 ;

procedure_def
 : TO NAME variables body_def
   {
     procedures.put($NAME.getText(), $variables.amount);
   }
 ;

macro_def
 : MACRO NAME variables body_def
   {
     procedures.put($NAME.getText(), $variables.amount);
   }
 ;

variables returns [int amount]
 : {$amount = 0;} ( VARIABLE {$amount++;} )*
 ;

body_def
 : {discoveredAllProcedures}? body_instruction* END
 |                            ~END* END
 ;

body_instruction
 : procedure_call_extra_input
 | procedure_call
 ;

procedure_call_extra_input
 : '(' {procedureNameAhead()}? NAME expression* ')'
 ;

procedure_call
 : {procedureNameAhead()}? NAME expressions[$NAME.getText(), amountParams($NAME.getText())]
 ;

expressions[String name, int total]
locals[int n = 0]      // a counter to keep track of how many expressions we've parsed
 : (
     {$n < $total}?    // check if we've parsed enough expressions
     expression
     {$n++;}           // increments the amount of  expressions we've parsed
   )*

   {
     // Make sure there are enough inputs parsed for 'name'.
     if ($total > $n) {
       throw new RuntimeException("not enough inputs to " + name);
     }
   }
 ;

expression
 : '-' expression                #unaryMinusExpression
 | procedure_call_extra_input    #procedureCallExtraInput
 | procedure_call                #procedureCallExpression
 | '(' expression ')'            #parensExpression
 | array                         #arrayExpression
 | list                          #listExpression
 | WORD                          #wordExpression
 | QUOTED_WORD                   #quotedWordExpression
 | NUMBER                        #numberExpression
 | VARIABLE                      #variableExpression
 | NAME                          #nameExpression
 | expression '*' expression     #multiplyExpression
 | expression '/' expression     #divideExpression
 | expression '+' expression     #additionExpression
 | expression '-' expression     #subtractionExpression
 | expression '<' expression     #lessThanExpression
 | expression '>' expression     #greaterThanExpression
 | expression '<=' expression    #lessThanEqualsExpression
 | expression '>=' expression    #greaterThanEqualsExpression
 | expression '=' expression     #equalsExpression
 | expression '<>' expression    #notEqualsExpressionExpression
 ;

array
 : '{' ( ~( '{' | '}' ) | array )* '}'
 ;

list
 : '[' ( ~( '[' | ']' ) | list )* ']'
 ;

TO    : T O;
END   : E N D;
MACRO : '.' M A C R O;

WORD
 : {listDepth > 0}?  ~[ \t\r\n\[\];] ( ~[ \t\r\n\];~] | LINE_CONTINUATION | '\\' ( [ \t\[\]();~] | LINE_BREAK ) )*
 | {arrayDepth > 0}? ~[ \t\r\n{};]   ( ~[ \t\r\n};~]  | LINE_CONTINUATION | '\\' ( [ \t{}();~]   | LINE_BREAK ) )*
 ;

SKIP
 : ( COMMENT | LINE_BREAK | SPACES | LINE_CONTINUATION ) -> skip
 ;

OPEN_ARRAY
 : '{' {arrayDepth++;}
 ;

CLOSE_ARRAY
 : '}' {arrayDepth--;}
 ;

OPEN_LIST
 : '[' {listDepth++;}
 ;

CLOSE_LIST
 : ']' {listDepth--;}
 ;


MINUS  : '-';
PLUS   : '+';
MULT   : '*';
DIV    : '/';
LT     : '<';
GT     : '>';
EQ     : '=';
LT_EQ  : '<=';
GT_EQ  : '>=';
NOT_EQ : '<>';

QUOTED_WORD
 : '"' ( ~[ \t\r\n\[\]();~] | LINE_CONTINUATION | '\\' ( [ \t\[\]();~] | LINE_BREAK ) )*
 ;

NUMBER
 : [0-9]+ ( '.' [0-9]+ )?
 ;

VARIABLE
 : ':' NAME
 ;

NAME
 : ~[-+*/=<> \t\r\n\[\]()":{}] ( ~[-+*/=<> \t\r\n\[\](){}] | LINE_CONTINUATION | '\\' [-+*/=<> \t\r\n\[\]();~{}] )*
 ;

ANY
 : . {System.err.println("unexpected char: " + getText());}
 ;

fragment COMMENT
 : ';' ~[\r\n~]*
 ;

fragment LINE_CONTINUATION
 : COMMENT? '~' SPACES? LINE_BREAK
 ;

fragment LINE_BREAK
 : '\r'? '\n'
 | '\r'
 ;

fragment SPACES
 : [ \t]+
 ;

fragment SPACE_CHARS
 : [ \t\r\n]+
 ;

fragment A : [Aa];
fragment B : [Bb];
fragment C : [Cc];
fragment D : [Dd];
fragment E : [Ee];
fragment F : [Ff];
fragment G : [Gg];
fragment H : [Hh];
fragment I : [Ii];
fragment J : [Jj];
fragment K : [Kk];
fragment L : [Ll];
fragment M : [Mm];
fragment N : [Nn];
fragment O : [Oo];
fragment P : [Pp];
fragment Q : [Qq];
fragment R : [Rr];
fragment S : [Ss];
fragment T : [Tt];
fragment U : [Uu];
fragment V : [Vv];
fragment W : [Ww];
fragment X : [Xx];
fragment Y : [Yy];
fragment Z : [Zz];
