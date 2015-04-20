grammar PGN;

parse
 : pgn_database EOF
 ;

pgn_database
 : pgn_game*
 ;

pgn_game
 : tag_section movetext_section
 ;

tag_section
 : tag_pair*
 ;

tag_pair
 : LEFT_BRACKET tag_name tag_value RIGHT_BRACKET
 ;

tag_name
 : SYMBOL
 ;

tag_value
 : STRING
 ;
 
movetext_section
 : element_sequence game_termination
 ;

element_sequence
 : (element | recursive_variation)*
 ;

element
 : move_number_indication
 | san_move
 | NUMERIC_ANNOTATION_GLYPH
 ;

move_number_indication
 : INTEGER PERIOD?
 ;

san_move
 : SYMBOL
 ;

recursive_variation
 : LEFT_PARENTHESIS element_sequence RIGHT_PARENTHESIS
 ;

game_termination
 : WHITE_WINS
 | BLACK_WINS
 | DRAWN_GAME
 | ASTERISK
 ;

WHITE_WINS
 : '1-0'
 ;

BLACK_WINS
 : '0-1'
 ;

DRAWN_GAME
 : '1/2-1/2'
 ;

REST_OF_LINE_COMMENT
 : ';' ~[\r\n]* -> skip
 ;

BRACE_COMMENT
 : '{' ~'}'* '}' -> skip
 ;

ESCAPE
 : {getCharPositionInLine() == 0}? '%' ~[\r\n]* -> skip
 ;

SPACES
 : [ \t\r\n]+ -> skip
 ;

STRING
 : '"' ('\\\\' | '\\"' | ~[\\"])* '"'
 ;

INTEGER
 : [0-9]+
 ;

PERIOD
 : '.'
 ;

ASTERISK
 : '*'
 ;

LEFT_BRACKET
 : '['
 ;

RIGHT_BRACKET
 : ']'
 ;

LEFT_PARENTHESIS
 : '('
 ;

RIGHT_PARENTHESIS
 : ')'
 ;

LEFT_ANGLE_BRACKET
 : '<'
 ;

RIGHT_ANGLE_BRACKET
 : '>'
 ;

NUMERIC_ANNOTATION_GLYPH
 : '$' [0-9]+
 ;

SYMBOL
 : [a-zA-Z0-9] [a-zA-Z0-9_+#=:-]*
 ;

SUFFIX_ANNOTATION
 : [?!] [?!]?
 ;

UNEXPECTED_CHAR
 : .
 ;
