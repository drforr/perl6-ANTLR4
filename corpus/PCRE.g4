grammar PCRE;

parse
 : alternation EOF
 ;

alternation
 : expr ('|' expr)*
 ;

expr
 : element*
 ;

element
 : atom quantifier?
 ;

quantifier
 : '?' quantifier_type
 | '+' quantifier_type
 | '*' quantifier_type
 | '{' number '}' quantifier_type
 | '{' number ',' '}' quantifier_type
 | '{' number ',' number '}' quantifier_type
 ;

quantifier_type
 : '+'
 | '?'
 | 
 ;

character_class
 : '[' '^' CharacterClassEnd Hyphen cc_atom+ ']'
 | '[' '^' CharacterClassEnd cc_atom* ']'
 | '[' '^' cc_atom+ ']'
 | '[' CharacterClassEnd Hyphen cc_atom+ ']'
 | '[' CharacterClassEnd cc_atom* ']'
 | '[' cc_atom+ ']'
 ;

backreference
 : backreference_or_octal
 | '\\g' number
 | '\\g' '{' number '}'
 | '\\g' '{' '-' number '}'
 | '\\k' '<' name '>'
 | '\\k' '\'' name '\''
 | '\\g' '{' name '}'
 | '\\k' '{' name '}'
 | '(' '?' 'P' '=' name ')'
 ;

backreference_or_octal
 : octal_char
 | Backslash digit
 ;

capture
 : '(' '?' '<' name '>' alternation ')'
 | '(' '?''\'' name '\'' alternation ')'
 | '(' '?' 'P' '<' name '>' alternation ')'
 | '(' alternation ')'
 ;

non_capture
 : '(' '?' ':' alternation ')'
 | '(' '?' '|' alternation ')'
 | '(' '?' '>' alternation ')'
 ;

comment
 : '(' '?' '#' non_close_parens ')'
 ;

option
 : '(' '?' option_flags '-' option_flags ')'
 | '(' '?' option_flags ')'
 | '(' '?' '-' option_flags ')'
 | '(' '*' 'N' 'O' '_' 'S' 'T' 'A' 'R' 'T' '_' 'O' 'P' 'T' ')'
 | '(' '*' 'U' 'T' 'F' '8' ')'
 | '(' '*' 'U' 'T' 'F' '1' '6' ')'
 | '(' '*' 'U' 'C' 'P' ')'
 ;

option_flags
 : option_flag+
 ;

option_flag
 : 'i'
 | 'J'
 | 'm'
 | 's'
 | 'U'
 | 'x'
 ;

look_around
 : '(' '?' '=' alternation ')'
 | '(' '?' '!' alternation ')'
 | '(' '?' '<' '=' alternation ')'
 | '(' '?' '<' '!' alternation ')'
 ;

subroutine_reference
 : '(' '?' 'R' ')'
 | '(' '?' number ')'
 | '(' '?' '+' number ')'
 | '(' '?' '-' number ')'
 | '(' '?' '&' name ')'
 | '(' '?' 'P' '>' name ')'
 | '\\g' '<' name '>'
 | '\\g' '\'' name '\''
 | '\\g' '<' number '>'
 | '\\g' '\'' number '\''
 | '\\g' '<' '+' number '>'
 | '\\g' '\'' '+' number '\''
 | '\\g' '<' '-' number '>'
 | '\\g' '\'' '-' number '\''
 ;

conditional
 : '(' '?' '(' number ')' alternation ('|' alternation)? ')'
 | '(' '?' '(' '+' number ')' alternation ('|' alternation)? ')'
 | '(' '?' '(' '-' number ')' alternation ('|' alternation)? ')'
 | '(' '?' '(' '<' name '>' ')' alternation ('|' alternation)? ')'
 | '(' '?' '(' '\'' name '\'' ')' alternation ('|' alternation)? ')'
 | '(' '?' '(' 'R' number ')' alternation ('|' alternation)? ')'
 | '(' '?' '(' 'R' ')' alternation ('|' alternation)? ')'
 | '(' '?' '(' 'R' '&' name ')' alternation ('|' alternation)? ')'
 | '(' '?' '(' 'D' 'E' 'F' 'I' 'N' 'E' ')' alternation ('|' alternation)? ')'
 | '(' '?' '(' 'a' 's' 's' 'e' 'r' 't' ')' alternation ('|' alternation)? ')'
 | '(' '?' '(' name ')' alternation ('|' alternation)? ')'
 ;

backtrack_control
 : '(' '*' 'A' 'C' 'C' 'E' 'P' 'T' ')'
 | '(' '*' 'F' ('A' 'I' 'L')? ')'
 | '(' '*' ('M' 'A' 'R' 'K')? ':' 'N' 'A' 'M' 'E' ')'
 | '(' '*' 'C' 'O' 'M' 'M' 'I' 'T' ')'
 | '(' '*' 'P' 'R' 'U' 'N' 'E' ')'
 | '(' '*' 'P' 'R' 'U' 'N' 'E' ':' 'N' 'A' 'M' 'E' ')'
 | '(' '*' 'S' 'K' 'I' 'P' ')'
 | '(' '*' 'S' 'K' 'I' 'P' ':' 'N' 'A' 'M' 'E' ')'
 | '(' '*' 'T' 'H' 'E' 'N' ')'
 | '(' '*' 'T' 'H' 'E' 'N' ':' 'N' 'A' 'M' 'E' ')'
 ;

newline_convention
 : '(' '*' 'C' 'R' ')'
 | '(' '*' 'L' 'F' ')'
 | '(' '*' 'C' 'R' 'L' 'F' ')'
 | '(' '*' 'A' 'N' 'Y' 'C' 'R' 'L' 'F' ')'
 | '(' '*' 'A' 'N' 'Y' ')'
 | '(' '*' 'B' 'S' 'R' '_' 'A' 'N' 'Y' 'C' 'R' 'L' 'F' ')'
 | '(' '*' 'B' 'S' 'R' '_' 'U' 'N' 'I' 'C' 'O' 'D' 'E' ')'
 ;

callout
 : '(' '?' 'C' ')'
 | '(' '?' 'C' number ')'
 ;

atom
 : subroutine_reference
 | shared_atom
 | literal
 | character_class
 | capture
 | non_capture
 | comment
 | option
 | look_around
 | backreference
 | conditional
 | backtrack_control
 | newline_convention
 | callout
 | Dot
 | Caret
 | StartOfSubject
 | WordBoundary
 | NonWordBoundary
 | EndOfSubjectOrLine
 | EndOfSubjectOrLineEndOfSubject
 | EndOfSubject
 | PreviousMatchInSubject
 | ResetStartMatch
 | OneDataUnit
 | ExtendedUnicodeChar
 ;

cc_atom
 : cc_literal Hyphen cc_literal
 | shared_atom
 | cc_literal
 | backreference_or_octal 
 ;

shared_atom
 : POSIXNamedSet
 | POSIXNegatedNamedSet
 | ControlChar
 | DecimalDigit
 | NotDecimalDigit
 | HorizontalWhiteSpace
 | NotHorizontalWhiteSpace
 | NotNewLine
 | CharWithProperty
 | CharWithoutProperty
 | NewLineSequence
 | WhiteSpace
 | NotWhiteSpace
 | VerticalWhiteSpace
 | NotVerticalWhiteSpace
 | WordChar
 | NotWordChar 
 ;

literal
 : shared_literal
 | CharacterClassEnd
 ;

cc_literal
 : shared_literal
 | Dot
 | CharacterClassStart
 | Caret
 | QuestionMark
 | Plus
 | Star
 | WordBoundary
 | EndOfSubjectOrLine
 | Pipe
 | OpenParen
 | CloseParen
 ;

shared_literal
 : octal_char
 | letter
 | digit
 | BellChar
 | EscapeChar
 | FormFeed
 | NewLine
 | CarriageReturn
 | Tab
 | HexChar
 | Quoted
 | BlockQuoted
 | OpenBrace
 | CloseBrace
 | Comma
 | Hyphen
 | LessThan
 | GreaterThan
 | SingleQuote
 | Underscore
 | Colon
 | Hash
 | Equals
 | Exclamation
 | Ampersand
 | OtherChar
 ;

number
 : digits
 ;

octal_char
 : ( Backslash (D0 | D1 | D2 | D3) octal_digit octal_digit
   | Backslash octal_digit octal_digit                     
   )

 ;

octal_digit
 : D0 | D1 | D2 | D3 | D4 | D5 | D6 | D7
 ;
 
digits
 : digit+
 ;

digit
 : D0 | D1 | D2 | D3 | D4 | D5 | D6 | D7 | D8 | D9
 ;

name
 : alpha_nums
 ;

alpha_nums
 : (letter | Underscore) (letter | Underscore | digit)*
 ;
 
non_close_parens
 : non_close_paren+
 ;

non_close_paren
 : ~CloseParen
 ;

letter
 : ALC | BLC | CLC | DLC | ELC | FLC | GLC | HLC | ILC | JLC | KLC | LLC | MLC | NLC | OLC | PLC | QLC | RLC | SLC | TLC | ULC | VLC | WLC | XLC | YLC | ZLC |
   AUC | BUC | CUC | DUC | EUC | FUC | GUC | HUC | IUC | JUC | KUC | LUC | MUC | NUC | OUC | PUC | QUC | RUC | SUC | TUC | UUC | VUC | WUC | XUC | YUC | ZUC
 ;

Quoted      : '\\' NonAlphaNumeric;
BlockQuoted : '\\Q' .*? '\\E';

BellChar       : '\\a';
ControlChar    : '\\c';
EscapeChar     : '\\e';
FormFeed       : '\\f';
NewLine        : '\\n';
CarriageReturn : '\\r';
Tab            : '\\t';
Backslash      : '\\';
HexChar        : '\\x' ( HexDigit HexDigit
                       | '{' HexDigit HexDigit HexDigit+ '}'
                       )
               ;

Dot                     : '.';
OneDataUnit             : '\\C';
DecimalDigit            : '\\d';
NotDecimalDigit         : '\\D';
HorizontalWhiteSpace    : '\\h';
NotHorizontalWhiteSpace : '\\H';
NotNewLine              : '\\N';
CharWithProperty        : '\\p{' UnderscoreAlphaNumerics '}';
CharWithoutProperty     : '\\P{' UnderscoreAlphaNumerics '}';
NewLineSequence         : '\\R';
WhiteSpace              : '\\s';
NotWhiteSpace           : '\\S';
VerticalWhiteSpace      : '\\v';
NotVerticalWhiteSpace   : '\\V';
WordChar                : '\\w';
NotWordChar             : '\\W';
ExtendedUnicodeChar     : '\\X';

CharacterClassStart  : '[';
CharacterClassEnd    : ']';
Caret                : '^';
Hyphen               : '-';
POSIXNamedSet        : '[[:' AlphaNumerics ':]]';
POSIXNegatedNamedSet : '[[:^' AlphaNumerics ':]]';

QuestionMark : '?';
Plus         : '+';
Star         : '*';
OpenBrace    : '{';
CloseBrace   : '}';
Comma        : ',';

WordBoundary                   : '\\b';
NonWordBoundary                : '\\B';
StartOfSubject                 : '\\A'; 
EndOfSubjectOrLine             : '$';
EndOfSubjectOrLineEndOfSubject : '\\Z'; 
EndOfSubject                   : '\\z'; 
PreviousMatchInSubject         : '\\G';

ResetStartMatch : '\\K';

SubroutineOrNamedReferenceStartG : '\\g';
NamedReferenceStartK             : '\\k';

Pipe        : '|';
OpenParen   : '(';
CloseParen  : ')';
LessThan    : '<';
GreaterThan : '>';
SingleQuote : '\'';
Underscore  : '_';
Colon       : ':';
Hash        : '#';
Equals      : '=';
Exclamation : '!';
Ampersand   : '&';

ALC : 'a';
BLC : 'b';
CLC : 'c';
DLC : 'd';
ELC : 'e';
FLC : 'f';
GLC : 'g';
HLC : 'h';
ILC : 'i';
JLC : 'j';
KLC : 'k';
LLC : 'l';
MLC : 'm';
NLC : 'n';
OLC : 'o';
PLC : 'p';
QLC : 'q';
RLC : 'r';
SLC : 's';
TLC : 't';
ULC : 'u';
VLC : 'v';
WLC : 'w';
XLC : 'x';
YLC : 'y';
ZLC : 'z';

AUC : 'A';
BUC : 'B';
CUC : 'C';
DUC : 'D';
EUC : 'E';
FUC : 'F';
GUC : 'G';
HUC : 'H';
IUC : 'I';
JUC : 'J';
KUC : 'K';
LUC : 'L';
MUC : 'M';
NUC : 'N';
OUC : 'O';
PUC : 'P';
QUC : 'Q';
RUC : 'R';
SUC : 'S';
TUC : 'T';
UUC : 'U';
VUC : 'V';
WUC : 'W';
XUC : 'X';
YUC : 'Y';
ZUC : 'Z';

D1 : '1';
D2 : '2';
D3 : '3';
D4 : '4';
D5 : '5';
D6 : '6';
D7 : '7';
D8 : '8';
D9 : '9';
D0 : '0';

OtherChar : . ;

fragment UnderscoreAlphaNumerics : ('_' | AlphaNumeric)+;
fragment AlphaNumerics           : AlphaNumeric+;
fragment AlphaNumeric            : [a-zA-Z0-9];
fragment NonAlphaNumeric         : ~[a-zA-Z0-9];
fragment HexDigit                : [0-9a-fA-F];
fragment ASCII                   : [\u0000-\u007F];

