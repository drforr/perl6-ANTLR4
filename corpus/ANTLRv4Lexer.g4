lexer grammar ANTLRv4Lexer;

tokens {
	TOKEN_REF,
	RULE_REF,
	LEXER_CHAR_SET
}

DOC_COMMENT
	:	'/**' .*? ('*/' | EOF)
	;

BLOCK_COMMENT
	:	'/*' .*? ('*/' | EOF)  -> channel(HIDDEN)
	;

LINE_COMMENT
	:	'//' ~[\r\n]*  -> channel(HIDDEN)
	;

BEGIN_ARG_ACTION
	:	'[' {handleBeginArgAction();}
	;

OPTIONS      : 'options' [ \t\f\n\r]* '{'  ;
TOKENS		 : 'tokens'  [ \t\f\n\r]* '{'  ;

IMPORT       : 'import'               ;
FRAGMENT     : 'fragment'             ;
LEXER        : 'lexer'                ;
PARSER       : 'parser'               ;
GRAMMAR      : 'grammar'              ;
PROTECTED    : 'protected'            ;
PUBLIC       : 'public'               ;
PRIVATE      : 'private'              ;
RETURNS      : 'returns'              ;
LOCALS       : 'locals'               ;
THROWS       : 'throws'               ;
CATCH        : 'catch'                ;
FINALLY      : 'finally'              ;
MODE         : 'mode'                 ;

COLON        : ':'                    ;
COLONCOLON   : '::'                   ;
COMMA        : ','                    ;
SEMI         : ';'                    ;
LPAREN       : '('                    ;
RPAREN       : ')'                    ;
RARROW       : '->'                   ;
LT           : '<'                    ;
GT           : '>'                    ;
ASSIGN       : '='                    ;
QUESTION     : '?'                    ;
STAR         : '*'                    ;
PLUS         : '+'                    ;
PLUS_ASSIGN  : '+='                   ;
OR           : '|'                    ;
DOLLAR       : '$'                    ;
DOT		     : '.'                    ;
RANGE        : '..'                   ;
AT           : '@'                    ;
POUND        : '#'                    ;
NOT          : '~'                    ;
RBRACE       : '}'                    ;

ID	:	NameStartChar NameChar*;

fragment
NameChar
	:   NameStartChar
	|   '0'..'9'
	|   '_'
	|   '\u00B7'
	|   '\u0300'..'\u036F'
	|   '\u203F'..'\u2040'
	;

fragment
NameStartChar
	:   'A'..'Z'
	|   'a'..'z'
	|   '\u00C0'..'\u00D6'
	|   '\u00D8'..'\u00F6'
	|   '\u00F8'..'\u02FF'
	|   '\u0370'..'\u037D'
	|   '\u037F'..'\u1FFF'
	|   '\u200C'..'\u200D'
	|   '\u2070'..'\u218F'
	|   '\u2C00'..'\u2FEF'
	|   '\u3001'..'\uD7FF'
	|   '\uF900'..'\uFDCF'
	|   '\uFDF0'..'\uFFFD'
	; 

INT	: [0-9]+
	;

STRING_LITERAL
	:  '\'' (ESC_SEQ | ~['\r\n\\])* '\''
	;

UNTERMINATED_STRING_LITERAL
	:  '\'' (ESC_SEQ | ~['\r\n\\])*
	;

fragment
ESC_SEQ
	:	'\\'
		(	
			[btnfr"'\\]
		|	
			UNICODE_ESC
		|	
			.
		|	
			EOF
		)
	;

fragment
UNICODE_ESC
    :   'u' (HEX_DIGIT (HEX_DIGIT (HEX_DIGIT HEX_DIGIT?)?)?)?
    ;

fragment
HEX_DIGIT : [0-9a-fA-F]	;

WS  :	[ \t\r\n\f]+ -> channel(HIDDEN)	;


ACTION
	:	'{'
		(	ACTION
		|	ACTION_ESCAPE
        |	ACTION_STRING_LITERAL
        |	ACTION_CHAR_LITERAL
        |	'/*' .*? '*/' 
        |	'//' ~[\r\n]*
        |	.
		)*?
		('}'|EOF)
	;

fragment
ACTION_ESCAPE
		:   '\\' .
		;

fragment
ACTION_STRING_LITERAL
        :	'"' (ACTION_ESCAPE | ~["\\])* '"'
        ;

fragment
ACTION_CHAR_LITERAL
        :	'\'' (ACTION_ESCAPE | ~['\\])* '\''
        ;

ERRCHAR
	:	.	-> channel(HIDDEN)
	;

mode ArgAction; 

	NESTED_ARG_ACTION
		:	'['                         -> more, pushMode(ArgAction)
		;

	ARG_ACTION_ESCAPE
		:   '\\' .                      -> more
		;

    ARG_ACTION_STRING_LITERAL
        :	('"' ('\\' . | ~["\\])* '"')-> more
        ;

    ARG_ACTION_CHAR_LITERAL
        :	('"' '\\' . | ~["\\] '"')   -> more
        ;

    ARG_ACTION
		:   ']'                         -> popMode
		;

	UNTERMINATED_ARG_ACTION 
		:	EOF							-> popMode
		;

    ARG_ACTION_CHAR 
        :   .                           -> more
        ;



mode LexerCharSet;

	LEXER_CHAR_SET_BODY
		:	(	~[\]\\]
			|	'\\' .
			)+
                                        -> more
		;

	LEXER_CHAR_SET
		:   ']'                         -> popMode
		;

	UNTERMINATED_CHAR_SET
		:	EOF							-> popMode
		;

