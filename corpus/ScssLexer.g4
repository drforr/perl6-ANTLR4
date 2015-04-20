lexer grammar ScssLexer;

NULL              : 'null';


IN              : 'in';

Unit
  : ('%'|'px'|'cm'|'mm'|'in'|'pt'|'pc'|'em'|'ex'|'deg'|'rad'|'grad'|'ms'|'s'|'hz'|'khz')
  ;

COMBINE_COMPARE : '&&' | '||';

Ellipsis          : '...';

InterpolationStart
  : HASH BlockStart -> pushMode(IDENTIFY)
  ;

LPAREN          : '(';
RPAREN          : ')';
BlockStart      : '{';
BlockEnd        : '}';
LBRACK          : '[';
RBRACK          : ']';
GT              : '>';
TIL             : '~';

LT              : '<';
COLON           : ':';
SEMI            : ';';
COMMA           : ',';
DOT             : '.';
DOLLAR          : '$';
AT              : '@';
AND             : '&';
HASH            : '#';
COLONCOLON      : '::';
PLUS            : '+';
TIMES           : '*';
DIV             : '/';
MINUS           : '-';
PERC            : '%';


UrlStart
  : 'url' LPAREN -> pushMode(URL_STARTED)
  ;



EQEQ            : '==';
NOTEQ           : '!=';



EQ              : '=';
PIPE_EQ         : '|=';
TILD_EQ         : '~=';



MIXIN           : '@mixin';
FUNCTION        : '@function';
AT_ELSE         : '@else';
IF              : 'if';
AT_IF           : '@if';
AT_FOR          : '@for';
AT_WHILE        : '@while';
AT_EACH         : '@each';
INCLUDE         : '@include';
IMPORT          : '@import';
RETURN          : '@return';

FROM            : 'from';
THROUGH         : 'through';
POUND_DEFAULT   : '!default';


Identifier
	:	(('_' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe' )
		('_' | '-' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe' | '0'..'9')*
	|	'-' ('_' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe' )
		('_' | '-' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe' | '0'..'9')*) -> pushMode(IDENTIFY)
	;



fragment STRING
  	:	'"' (~('"'|'\n'|'\r'))* '"'
  	|	'\'' (~('\''|'\n'|'\r'))* '\''
  	;

StringLiteral
	:	STRING
	;


Number
	:	'-' (('0'..'9')* '.')? ('0'..'9')+
	|	(('0'..'9')* '.')? ('0'..'9')+
	;

Color
	:	'#' ('0'..'9'|'a'..'f'|'A'..'F')+
	;


WS
  : (' '|'\t'|'\n'|'\r'|'\r\n')+ -> skip
  ;

SL_COMMENT
	:	'//'
		(~('\n'|'\r'))* ('\n'|'\r'('\n')?) -> skip
	;


COMMENT
	:	'/*' .*? '*/' -> skip
	;

mode URL_STARTED;
UrlEnd                 : RPAREN -> popMode;
Url                    :	STRING | (~(')' | '\n' | '\r' | ';'))+;

mode IDENTIFY;
BlockStart_ID          : BlockStart -> popMode, type(BlockStart);
SPACE                  : WS -> popMode, skip;
DOLLAR_ID              : DOLLAR -> type(DOLLAR);


InterpolationStartAfter  : InterpolationStart;
InterpolationEnd_ID    : BlockEnd -> type(BlockEnd);

IdentifierAfter        : Identifier;
Ellipsis_ID            : Ellipsis -> popMode, type(Ellipsis);
DOT_ID                 : DOT -> popMode, type(DOT);

LPAREN_ID                 : LPAREN -> popMode, type(LPAREN);
RPAREN_ID                 : RPAREN -> popMode, type(RPAREN);

COLON_ID                  : COLON -> popMode, type(COLON);
COMMA_ID                  : COMMA -> popMode, type(COMMA);
SEMI_ID                  : SEMI -> popMode, type(SEMI);





