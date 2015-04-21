lexer grammar CSharp4Lexer;

BYTE_ORDER_MARK: '\u00EF\u00BB\u00BF';

SINGLE_LINE_DOC_COMMENT 
  : ('///' Input_character*) -> channel(HIDDEN)
  ;
DELIMITED_DOC_COMMENT 
  : ('/**' Delimited_comment_section* Asterisks '/') -> channel(HIDDEN) 
  ;

NEW_LINE 
  : ('\u000D' 
  | '\u000A' 
  | '\u000D' '\u000A' 
  | '\u0085' 
  | '\u2028' 
  | '\u2029' 
  ) -> channel(HIDDEN)
  ;

SINGLE_LINE_COMMENT 
  : ('//' Input_character*) -> channel(HIDDEN)
  ;
fragment Input_characters
  : Input_character+
  ;
fragment Input_character 
  : ~([\u000D\u000A\u0085\u2028\u2029]) 
  ;
fragment NEW_LINE_CHARACTER 
  : '\u000D' 
  | '\u000A' 
  | '\u0085' 
  | '\u2028' 
  | '\u2029' 
  ;

DELIMITED_COMMENT 
  : ('/*' Delimited_comment_section* Asterisks '/') -> channel(HIDDEN)
  ;
fragment Delimited_comment_section 
  : '/'
  | Asterisks? Not_slash_or_asterisk
  ;
fragment Asterisks 
  : '*'+
  ;
fragment Not_slash_or_asterisk 
  : ~( '/' | '*' )
  ;

WHITESPACE 
  : (Whitespace_characters) -> channel(HIDDEN)
  ;

fragment Whitespace_characters 
  : Whitespace_character+
  ;

fragment Whitespace_character 
  : UNICODE_CLASS_ZS 
  | '\u0009' 
  | '\u000B' 
  | '\u000C' 
  ;

fragment Unicode_escape_sequence 
  : '\\u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
  | '\\U' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
  ;

ABSTRACT : 'abstract';
ADD: 'add';
ALIAS: 'alias';
ARGLIST: '__arglist';
AS : 'as';
ASCENDING: 'ascending';
BASE : 'base';
BOOL : 'bool';
BREAK : 'break';
BY: 'by';
BYTE : 'byte';
CASE : 'case';
CATCH : 'catch';
CHAR : 'char';
CHECKED : 'checked';
CLASS : 'class';
CONST : 'const';
CONTINUE : 'continue';
DECIMAL : 'decimal';
DEFAULT : 'default';
DELEGATE : 'delegate';
DESCENDING: 'descending';
DO : 'do';
DOUBLE : 'double';
DYNAMIC: 'dynamic';
ELSE : 'else';
ENUM : 'enum';
EQUALS: 'equals';
EVENT : 'event';
EXPLICIT : 'explicit';
EXTERN : 'extern';
FALSE : 'false';
FINALLY : 'finally';
FIXED : 'fixed';
FLOAT : 'float';
FOR : 'for';
FOREACH : 'foreach';
FROM: 'from';
GET: 'get';
GOTO : 'goto';
GROUP: 'group';
IF : 'if';
IMPLICIT : 'implicit';
IN : 'in';
INT : 'int';
INTERFACE : 'interface';
INTERNAL : 'internal';
INTO : 'into';
IS : 'is';
JOIN: 'join';
LET: 'let';
LOCK : 'lock';
LONG : 'long';
NAMESPACE : 'namespace';
NEW : 'new';
NULL : 'null';
OBJECT : 'object';
ON: 'on';
OPERATOR : 'operator';
ORDERBY: 'orderby';
OUT : 'out';
OVERRIDE : 'override';
PARAMS : 'params';
PARTIAL: 'partial';
PRIVATE : 'private';
PROTECTED : 'protected';
PUBLIC : 'public';
READONLY : 'readonly';
REF : 'ref';
REMOVE: 'remove';
RETURN : 'return';
SBYTE : 'sbyte';
SEALED : 'sealed';
SELECT: 'select';
SET: 'set';
SHORT : 'short';
SIZEOF : 'sizeof';
STACKALLOC : 'stackalloc';
STATIC : 'static';
STRING : 'string';
STRUCT : 'struct';
SWITCH : 'switch';
THIS : 'this';
THROW : 'throw';
TRUE : 'true';
TRY : 'try';
TYPEOF : 'typeof';
UINT : 'uint';
ULONG : 'ulong';
UNCHECKED : 'unchecked';
UNSAFE : 'unsafe';
USHORT : 'ushort';
USING : 'using';
VIRTUAL : 'virtual';
VOID : 'void';
VOLATILE : 'volatile';
WHERE : 'where';
WHILE : 'while';
YIELD: 'yield';

IDENTIFIER
  : Available_identifier
  | '@' Identifier_or_keyword
  ;
fragment Available_identifier 
  : Identifier_or_keyword
  ;
fragment Identifier_or_keyword 
  : Identifier_start_character Identifier_part_character*
  ;
fragment Identifier_start_character 
  : Letter_character
  | '_'
  ;
fragment Identifier_part_character 
  : Letter_character
  | Decimal_digit_character
  | Connecting_character
  | Combining_character
  | Formatting_character
  ;
fragment Letter_character 
  : UNICODE_CLASS_LU
  | UNICODE_CLASS_LL
  | UNICODE_CLASS_LT
  | UNICODE_CLASS_LM
  | UNICODE_CLASS_LO
  | UNICODE_CLASS_NL
  ;
fragment Combining_character 
  : UNICODE_CLASS_MN
  | UNICODE_CLASS_MC
  ;
fragment Decimal_digit_character 
  : UNICODE_CLASS_ND
  ;
fragment Connecting_character 
  : UNICODE_CLASS_PC
  ;
fragment Formatting_character 
  : UNICODE_CLASS_CF
  ;


INTEGER_LITERAL 
  : Decimal_integer_literal
  | Hexadecimal_integer_literal
  ;
fragment Decimal_integer_literal 
  : Decimal_digits Integer_type_suffix?
  ;
fragment Decimal_digits 
  : DECIMAL_DIGIT+
  ;
fragment DECIMAL_DIGIT 
  : '0'..'9'
  ;
fragment Integer_type_suffix 
  : 'U'
  | 'u'
  | 'L'
  | 'l'
  | 'UL'
  | 'Ul'
  | 'uL'
  | 'ul'
  | 'LU'
  | 'Lu'
  | 'lU'
  | 'lu'
  ;
fragment Hexadecimal_integer_literal 
  : ('0x' | '0X') Hex_digits Integer_type_suffix?
  ;
fragment Hex_digits 
  : HEX_DIGIT+
  ;
fragment HEX_DIGIT 
  : '0'..'9'
  | 'A'..'F'
  | 'a'..'f'
  ;
LiteralAccess
  : INTEGER_LITERAL   
    DOT               
    IDENTIFIER       
  ;

REAL_LITERAL 
  : Decimal_digits DOT Decimal_digits Exponent_part? Real_type_suffix?
  | DOT Decimal_digits Exponent_part? Real_type_suffix?
  | Decimal_digits Exponent_part Real_type_suffix?
  | Decimal_digits Real_type_suffix
  ;
fragment Exponent_part 
  : ('e' | 'E') Sign? Decimal_digits
  ;
fragment Sign 
  : '+'
  | '-'
  ;
fragment Real_type_suffix 
  : 'F'
  | 'f'
  | 'D'
  | 'd'
  | 'M'
  | 'm'
  ;
CHARACTER_LITERAL 
  : QUOTE Character QUOTE
  ;
fragment Character 
  : Single_character
  | Simple_escape_sequence
  | Hexadecimal_escape_sequence
  | Unicode_escape_sequence
  ;
fragment Single_character 
  : ~(['\\\u000D\u000A\u000D\u0085\u2028\u2029]) 
  ;
fragment Simple_escape_sequence 
  : '\\\''
  | '\\"'
  | DOUBLE_BACK_SLASH
  | '\\0'
  | '\\a'
  | '\\b'
  | '\\f'
  | '\\n'
  | '\\r'
  | '\\t'
  | '\\v'
  ;
fragment Hexadecimal_escape_sequence 
  : '\\x' HEX_DIGIT
  | '\\x' HEX_DIGIT HEX_DIGIT
  | '\\x' HEX_DIGIT HEX_DIGIT HEX_DIGIT
  | '\\x' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
  ;
STRING_LITERAL 
  : Regular_string_literal
  | Verbatim_string_literal
  ;
fragment Regular_string_literal 
  : DOUBLE_QUOTE Regular_string_literal_character* DOUBLE_QUOTE
  ;
fragment Regular_string_literal_character 
  : Single_regular_string_literal_character
  | Simple_escape_sequence
  | Hexadecimal_escape_sequence
  | Unicode_escape_sequence
  ;
fragment Single_regular_string_literal_character 
  : ~(["\\\u000D\u000A\u000D\u0085\u2028\u2029])
  ;
fragment Verbatim_string_literal 
  : '@' DOUBLE_QUOTE Verbatim_string_literal_character* DOUBLE_QUOTE
  ;
fragment Verbatim_string_literal_character 
  : Single_verbatim_string_literal_character
  | Quote_escape_sequence
  ;
fragment Single_verbatim_string_literal_character 
  : ~(["]) 
  ;
fragment Quote_escape_sequence 
  : DOUBLE_QUOTE DOUBLE_QUOTE
  ;

OPEN_BRACE : '{';
CLOSE_BRACE : '}';
OPEN_BRACKET : '[';
CLOSE_BRACKET : ']';
OPEN_PARENS : '(';
CLOSE_PARENS : ')';
DOT : '.';
COMMA : ',';
COLON : ':';
SEMICOLON : ';';
PLUS : '+';
MINUS : '-';
STAR : '*';
DIV : '/';
PERCENT : '%';
AMP : '&';
BITWISE_OR : '|';
CARET : '^';
BANG : '!';
TILDE : '~';
ASSIGNMENT : '=';
LT : '<';
GT : '>';
INTERR : '?';
DOUBLE_COLON : '::';
OP_COALESCING : '??';
OP_INC : '++';
OP_DEC : '--';
OP_AND : '&&';
OP_OR : '||';
OP_PTR : '->';
OP_EQ : '==';
OP_NE : '!=';
OP_LE : '<=';
OP_GE : '>=';
OP_ADD_ASSIGNMENT : '+=';
OP_SUB_ASSIGNMENT : '-=';
OP_MULT_ASSIGNMENT : '*=';
OP_DIV_ASSIGNMENT : '/=';
OP_MOD_ASSIGNMENT : '%=';
OP_AND_ASSIGNMENT : '&=';
OP_OR_ASSIGNMENT : '|=';
OP_XOR_ASSIGNMENT : '^=';
OP_LEFT_SHIFT : '<<';
OP_LEFT_SHIFT_ASSIGNMENT : '<<=';


QUOTE :             '\'';
DOUBLE_QUOTE :      '"';
BACK_SLASH :        '\\';
DOUBLE_BACK_SLASH : '\\\\';
SHARP :             '#';


fragment UNICODE_CLASS_ZS
  : '\u0020' 
  | '\u00A0' 
  | '\u1680' 
  | '\u180E' 
  | '\u2000' 
  | '\u2001' 
  | '\u2002' 
  | '\u2003' 
  | '\u2004' 
  | '\u2005' 
  | '\u2006' 
  | '\u2008' 
  | '\u2009' 
  | '\u200A' 
  | '\u202F' 
  | '\u3000' 
  | '\u205F' 
  ;

fragment UNICODE_CLASS_LU
  : '\u0041'..'\u005A' 
  | '\u00C0'..'\u00DE' 
  ;

fragment UNICODE_CLASS_LL
  : '\u0061'..'\u007A' 
  ;

fragment UNICODE_CLASS_LT
  : '\u01C5' 
  | '\u01C8' 
  | '\u01CB' 
  | '\u01F2' 
  ;

fragment UNICODE_CLASS_LM
  : '\u02B0'..'\u02EE' 
  ;

fragment UNICODE_CLASS_LO
  : '\u01BB' 
  | '\u01C0' 
  | '\u01C1' 
  | '\u01C2' 
  | '\u01C3' 
  | '\u0294' 
  ;

fragment UNICODE_CLASS_NL
  : '\u16EE' 
  | '\u16EF' 
  | '\u16F0' 
  | '\u2160' 
  | '\u2161' 
  | '\u2162' 
  | '\u2163' 
  | '\u2164' 
  | '\u2165' 
  | '\u2166' 
  | '\u2167' 
  | '\u2168' 
  | '\u2169' 
  | '\u216A' 
  | '\u216B' 
  | '\u216C' 
  | '\u216D' 
  | '\u216E' 
  | '\u216F' 
  ;

fragment UNICODE_CLASS_MN
  : '\u0300' 
  | '\u0301' 
  | '\u0302' 
  | '\u0303' 
  | '\u0304' 
  | '\u0305' 
  | '\u0306' 
  | '\u0307' 
  | '\u0308' 
  | '\u0309' 
  | '\u030A' 
  | '\u030B' 
  | '\u030C' 
  | '\u030D' 
  | '\u030E' 
  | '\u030F' 
  | '\u0310' 
  ;

fragment UNICODE_CLASS_MC
  : '\u0903' 
  | '\u093E' 
  | '\u093F' 
  | '\u0940' 
  | '\u0949' 
  | '\u094A' 
  | '\u094B' 
  | '\u094C' 
  ;

fragment UNICODE_CLASS_CF
  : '\u00AD' 
  | '\u0600' 
  | '\u0601' 
  | '\u0602' 
  | '\u0603' 
  | '\u06DD' 
  ;

fragment UNICODE_CLASS_PC
  : '\u005F' 
  | '\u203F' 
  | '\u2040' 
  | '\u2054' 
  | '\uFE33' 
  | '\uFE34' 
  | '\uFE4D' 
  | '\uFE4E' 
  | '\uFE4F' 
  | '\uFF3F' 
  ;

fragment UNICODE_CLASS_ND
  : '\u0030' 
  | '\u0031' 
  | '\u0032' 
  | '\u0033' 
  | '\u0034' 
  | '\u0035' 
  | '\u0036' 
  | '\u0037' 
  | '\u0038' 
  | '\u0039' 
  ;

