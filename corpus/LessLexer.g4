lexer grammar LessLexer;

NULL: 'null';


IN: 'in';

Unit
  : ('%'|'px'|'cm'|'mm'|'in'|'pt'|'pc'|'em'|'ex'|'deg'|'rad'|'grad'|'ms'|'s'|'hz'|'khz')
  ;

Ellipsis: '...';

InterpolationStart
  : AT BlockStart -> pushMode(IDENTIFY)
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
PARENTREF       : '&';
HASH            : '#';
COLONCOLON      : '::';
PLUS            : '+';
TIMES           : '*';
DIV             : '/';
MINUS           : '-';
PERC            : '%';

EQEQ            : '==';
GTEQ            : '>=';
LTEQ            : '<=';
NOTEQ           : '!=';
EQ              : '=';
PIPE_EQ         : '|=';
TILD_EQ         : '~=';

URL : 'url';

UrlStart
  : URL LPAREN -> pushMode(URL_STARTED)
  ;

IMPORT          : '@import';
MEDIA           : '@media';
EXTEND          : ':extend';
IMPORTANT       : '!important';
ARGUMENTS       : '@arguments';
REST            : '@rest';

REFERENCE : 'reference';
INLINE : 'inline';
LESS : 'less';
CSS : 'css';
ONCE : 'once';
MULTIPLE: 'multiple';

WHEN : 'when';
NOT : 'not';
AND : 'and';

Identifier
  : (('_' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe' )
    ('_' | '-' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe' | '0'..'9')*
  |  '-' ('_' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe' )
    ('_' | '-' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe' | '0'..'9')*) -> pushMode(IDENTIFY)
  ;

fragment STRING
  :  '"' (~('"'|'\n'|'\r'))* '"'
  |  '\'' (~('\''|'\n'|'\r'))* '\''
  ;

StringLiteral
  :  STRING
  ;

Number
  :  '-' (('0'..'9')* '.')? ('0'..'9')+
  |  (('0'..'9')* '.')? ('0'..'9')+
  ;

Color
  :  '#' ('0'..'9'|'a'..'f'|'A'..'F')+
  ;


WS
  : (' '|'\t'|'\n'|'\r'|'\r\n')+ -> skip
  ;

SL_COMMENT
  :  '//'
    (~('\n'|'\r'))* ('\n'|'\r'('\n')?) -> skip
  ;


COMMENT
  :  '/*' .*? '*/' -> skip
  ;

FUNCTION_NAME
 : COLOR
 | CONVERT
 | DATA_URI
 | DEFAULT
 | UNIT
 | GET_UNIT
 | SVG_GRADIENT
 | ESCAPE
 | E
 | FORMAT
 | REPLACE
 | LENGTH
 | EXTRACT
 | CEIL
 | FLOOR
 | PERCENTAGE
 | ROUND
 | SQRT
 | ABS
 | SIN
 | ASIN
 | COS
 | ACOS
 | TAN
 | ATAN
 | PI
 | POW
 | MOD
 | MIN
 | MAX
 | ISNUMBER
 | ISSTRING
 | ISCOLOR
 | ISKEYWORD
 | ISURL
 | ISPIXEL
 | ISEM
 | ISPERCENTAGE
 | ISUNIT
 | RGB
 | RGBA
 | ARGB
 | HSL
 | HSLA
 | HSV
 | HSVA
 | HUE
 | SATURATION
 | LIGHTNESS
 | HSVHUE
 | HSVSATURATION
 | HSVVALUE
 | RED
 | GREEN
 | BLUE
 | ALPHA
 | LUMA
 | LUMINANCE
 | SATURATE
 | DESATURATE
 | LIGHTEN
 | DARKEN
 | FADEIN
 | FADEOUT
 | FADE
 | SPIN
 | MIX
 | GREYSCALE
 | CONTRAST
 | MULTIPLY
 | SCREEN
 | OVERLAY
 | SOFTLIGHT
 | HARDLIGHT
 | DIFFERENCE
 | EXCLUSION
 | AVERAGE
 | NEGATION
 ;
COLOR:'color';
CONVERT:'convert';
DATA_URI:'data-uri';
DEFAULT:'default';
UNIT:'unit';
GET_UNIT:'get-unit';
SVG_GRADIENT:'svg-gradient';

ESCAPE : 'escape';
E: 'e';
FORMAT: '%';
REPLACE : 'replace';

LENGTH: 'length';
EXTRACT: 'extract';

CEIL: 'ceil';
FLOOR: 'floor';
PERCENTAGE: 'percentage';
ROUND: 'round';
SQRT: 'sqrt';
ABS: 'abs';
SIN: 'sin';
ASIN: 'asin';
COS: 'cos';
ACOS: 'acos';
TAN: 'tan';
ATAN: 'atan';
PI: 'pi';
POW: 'pow';
MOD: 'mod';
MIN: 'min';
MAX: 'max';

ISNUMBER: 'isnumber';
ISSTRING: 'isstring';
ISCOLOR: 'iscolor';
ISKEYWORD: 'iskeyword';
ISURL: 'isurl';
ISPIXEL: 'ispixel';
ISEM: 'isem';
ISPERCENTAGE: 'ispercentage';
ISUNIT: 'isunit';

RGB: 'rgb';
RGBA: 'rgba';
ARGB: 'argb';
HSL: 'hsl';
HSLA: 'hsla';
HSV: 'hsv';
HSVA: 'hsva';

HUE: 'hue';
SATURATION: 'saturation';
LIGHTNESS: 'lightness';
HSVHUE: 'hsvhue';
HSVSATURATION: 'hsvsaturation';
HSVVALUE: 'hsvvalue';
RED: 'red';
GREEN: 'green';
BLUE: 'blue';
ALPHA: 'alpha';
LUMA: 'luma';
LUMINANCE: 'luminance';

SATURATE: 'saturate';
DESATURATE: 'desaturate';
LIGHTEN: 'lighten';
DARKEN: 'darken';
FADEIN: 'fadein';
FADEOUT: 'fadeout';
FADE: 'fade';
SPIN: 'spin';
MIX: 'mix';
GREYSCALE: 'greyscale';
CONTRAST: 'contrast';

MULTIPLY: 'multiply';
SCREEN: 'screen';
OVERLAY: 'overlay';
SOFTLIGHT: 'softlight';
HARDLIGHT: 'hardlight';
DIFFERENCE: 'difference';
EXCLUSION: 'exclusion';
AVERAGE: 'average';
NEGATION: 'negation';

mode URL_STARTED;
UrlEnd                 : RPAREN -> popMode;
Url                    :  STRING | (~(')' | '\n' | '\r' | ';'))+;

mode IDENTIFY;
BlockStart_ID             : BlockStart -> popMode, type(BlockStart);
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
