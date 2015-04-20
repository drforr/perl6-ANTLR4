grammar IRI;

parse
 : iri EOF
 ;

iri
 : scheme ':' ihier_part ('?' iquery)? ('#' ifragment)?
 ;

ihier_part
 : '//' iauthority ipath_abempty
 | ipath_absolute
 | ipath_rootless
 | ipath_empty
 ;
       
iri_reference
 : iri
 | irelative_ref
 ;

absolute_iri
 : scheme ':' ihier_part ('?' iquery)?
 ;

irelative_ref
 : irelative_part ('?' iquery)? ('#' ifragment)?
 ;

irelative_part
 : '//' iauthority ipath_abempty
 | ipath_absolute
 | ipath_noscheme
 | ipath_empty
 ;

iauthority
 : (iuserinfo '@')? ihost (':' port)?
 ;

iuserinfo
 : (iunreserved | pct_encoded | sub_delims | ':')*
 ;

ihost
 : ip_literal 
 | ip_v4_address
 | ireg_name
 ;

ireg_name
 : (iunreserved | pct_encoded | sub_delims)*
 ;

ipath
 : ipath_abempty
 | ipath_absolute
 | ipath_noscheme
 | ipath_rootless
 | ipath_empty
 ;

ipath_abempty
 : ('/' isegment)*
 ;

ipath_absolute
 : '/' (isegment_nz ('/' isegment)*)?
 ;

ipath_noscheme
 : isegment_nz_nc ('/' isegment)*
 ;

ipath_rootless
 : isegment_nz ('/' isegment)*
 ;

ipath_empty
 : 
 ;
 
isegment
 : ipchar*
 ;

isegment_nz
 : ipchar+
 ;

///                ; non-zero-length segment without any colon ":"
isegment_nz_nc
 : (iunreserved | pct_encoded | sub_delims | '@')+
 ;

ipchar
 : iunreserved 
 | pct_encoded 
 | sub_delims 
 | (':' | '@')
 ;

iquery
 : (ipchar | (IPRIVATE | '/' | '?'))*
 ;

ifragment
 : (ipchar | ('/' | '?'))*
 ;
 
iunreserved
 : alpha
 | digit
 | ('-' | '.' | '_' | '~' | UCSCHAR)
 ;
 
scheme
 : alpha (alpha | digit | ('+' | '-' | '.'))*
 ;
 
port
 : digit*
 ;
 
ip_literal
 : '[' (ip_v6_address | ip_v_future) ']'
 ;

ip_v_future
 : V hexdig+ '.' (unreserved | sub_delims | ':')+
 ;

ip_v6_address
 : h16 ':' h16 ':' h16 ':' h16 ':' h16 ':' h16 ':' ls32
 | '::' h16 ':' h16 ':' h16 ':' h16 ':' h16 ':' ls32
 | h16? '::' h16 ':' h16 ':' h16 ':' h16 ':' ls32
 | ((h16 ':')? h16)? '::' h16 ':' h16 ':' h16 ':' ls32   
 | (((h16 ':')? h16 ':')? h16)? '::' h16 ':' h16 ':' ls32
 | ((((h16 ':')? h16 ':')? h16 ':')? h16)? '::' h16 ':' ls32
 | (((((h16 ':')? h16 ':')? h16 ':')? h16 ':')? h16)? '::' ls32
 | ((((((h16 ':')? h16 ':')? h16 ':')? h16 ':')? h16 ':')? h16)? '::' h16
 | (((((((h16 ':')? h16 ':')? h16 ':')? h16 ':')? h16 ':')? h16 ':')? h16)? '::'
 ;

h16
 : hexdig hexdig hexdig hexdig
 | hexdig hexdig hexdig
 | hexdig hexdig
 | hexdig
 ;

ls32
 : h16 ':' h16
 | ip_v4_address
 ;

ip_v4_address
 : dec_octet '.' dec_octet '.' dec_octet '.' dec_octet
 ;

dec_octet
 : digit
 | non_zero_digit digit
 | D1 digit digit
 | D2 (D0 | D1 | D2 | D3 | D4) digit
 | D2 D5 (D0 | D1 | D2 | D3 | D4 | D5)
 ;
 
pct_encoded
 : '%' hexdig hexdig
 ;

unreserved
 : alpha
 | digit
 | ('-' | '.' | '_' | '~')
 ;

reserved
 : gen_delims
 | sub_delims
 ;

gen_delims
 : ':'
 | '/' 
 | '?' 
 | '#' 
 | '[' 
 | ']' 
 | '@'
 ;

sub_delims
 : '!'
 | '$'
 | '&'
 | '\''
 | '('
 | ')'
 | '*' 
 | '+'
 | ',' 
 | ';'
 | '='
 ;

alpha
 : A
 | B
 | C
 | D
 | E
 | F
 | G
 | H
 | I
 | J
 | K
 | L
 | M
 | N
 | O
 | P
 | Q
 | R
 | S
 | T
 | U
 | V
 | W
 | X
 | Y
 | Z
 ;

hexdig
 : digit
 | (A | B | C | D | E | F)
 ;

digit
 : D0 
 | non_zero_digit
 ;

non_zero_digit
 : D1 
 | D2 
 | D3 
 | D4 
 | D5 
 | D6 
 | D7 
 | D8 
 | D9
 ;

UCSCHAR
 : '\u00A0'..'\uD7FF'
 | '\uF900'..'\uFDCF'
 | '\uFDF0'..'\uFFEF'  
 | '\u10000'..'\u1FFFD' 
 | '\u20000'..'\u2FFFD' 
 | '\u30000'..'\u3FFFD'
 | '\u40000'..'\u4FFFD'
 | '\u50000'..'\u5FFFD'
 | '\u60000'..'\u6FFFD'
 | '\u70000'..'\u7FFFD'
 | '\u80000'..'\u8FFFD'
 | '\u90000'..'\u9FFFD'    
 | '\uA0000'..'\uAFFFD'
 | '\uB0000'..'\uBFFFD'
 | '\uC0000'..'\uCFFFD'
 | '\uD0000'..'\uDFFFD'
 | '\uE1000'..'\uEFFFD'
 ;

IPRIVATE
 : '\uE000'..'\uF8FF' 
 | '\uF0000'..'\uFFFFD' 
 | '\u100000'..'\u10FFFD'
 ;

D0 : '0';
D1 : '1';
D2 : '2';
D3 : '3';
D4 : '4';
D5 : '5';
D6 : '6';
D7 : '7';
D8 : '8';
D9 : '9';

A : [aA];
B : [bB];
C : [cC];
D : [dD];
E : [eE];
F : [fF];
G : [gG];
H : [hH];
I : [iI];
J : [jJ];
K : [kK];
L : [lL];
M : [mM];
N : [nN];
O : [oO];
P : [pP];
Q : [qQ];
R : [rR];
S : [sS];
T : [tT];
U : [uU];
V : [vV];
W : [wW];
X : [xX];
Y : [yY];
Z : [zZ];

COL2    : '::';
COL     : ':';
DOT     : '.';
PERCENT : '%';
HYPHEN  : '-';
TILDE   : '~';
USCORE  : '_';
EXCL    : '!';
DOLLAR  : '$';
AMP     : '&';
SQUOTE  : '\'';
OPAREN  : '(';
CPAREN  : ')';
STAR    : '*';
PLUS    : '+';
COMMA   : ',';
SCOL    : ';';
EQUALS  : '=';
FSLASH2 : '//';
FSLASH  : '/';
QMARK   : '?';
HASH    : '#';
OBRACK  : '[';
CBRACK  : ']';
AT      : '@';

