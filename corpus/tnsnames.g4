grammar tnsnames;


tnsnames         : (tns_entry | ifile | lsnr_entry)* ;

tns_entry        : alias_list EQUAL (description_list | description) ;

ifile            : IFILE '=' DQ_STRING ;

lsnr_entry       : alias EQUAL (lsnr_description | address_list | (address)+) ;

lsnr_description : L_PAREN DESCRIPTION EQUAL (address_list | (address)+) R_PAREN ;

alias_list       : alias (COMMA alias)* ;

alias            : ID
                 | ID (DOT ID)+
                 ;

description_list : L_PAREN DESCRIPTION_LIST  EQUAL  (dl_params)? (description)+ (dl_params)? R_PAREN ;

dl_params        : dl_parameter+ ;

dl_parameter     : al_failover
                 | al_load_balance
                 | al_source_route
                 ;
                 
description      : L_PAREN DESCRIPTION EQUAL  (d_params)? (address_list | (address)+) (d_params)? connect_data (d_params)? R_PAREN ;

d_params         : d_parameter+ ;

d_parameter      : d_enable
                 | al_failover
                 | al_load_balance
                 | d_sdu
                 | d_recv_buf
                 | d_send_buf
                 | al_source_route                 
                 | d_service_type
                 | d_security
                 | d_conn_timeout
                 | d_retry_count
                 | d_tct
                 ;

d_enable         : L_PAREN ENABLE EQUAL BROKEN R_PAREN ;
                 
d_sdu            : L_PAREN SDU EQUAL INT R_PAREN ;
                 
d_recv_buf       : L_PAREN RECV_BUF EQUAL INT R_PAREN ;
                 
d_send_buf       : L_PAREN SEND_BUF EQUAL INT R_PAREN ;
                 
d_service_type   : L_PAREN SERVICE_TYPE EQUAL ID R_PAREN ;
                 
d_security       : L_PAREN SECURITY EQUAL ds_parameter R_PAREN ;

d_conn_timeout   : L_PAREN CONN_TIMEOUT EQUAL INT R_PAREN ;

d_retry_count    : L_PAREN RETRY_COUNT EQUAL INT R_PAREN ;

d_tct            : L_PAREN TCT EQUAL INT R_PAREN ;
                 
ds_parameter     : L_PAREN SSL_CERT EQUAL DQ_STRING R_PAREN ;                 
                 
address_list     : L_PAREN ADDRESS_LIST EQUAL (al_params)? (address)+ (al_params)? R_PAREN ;

al_params        : al_parameter+ ;

al_parameter     : al_failover              
                 | al_load_balance
                 | al_source_route
                 ;                  
                 
al_failover      : L_PAREN FAILOVER EQUAL (YES_NO | ON_OFF | TRUE_FALSE) R_PAREN ;

al_load_balance  : L_PAREN LOAD_BALANCE EQUAL (YES_NO | ON_OFF | TRUE_FALSE) R_PAREN ;
                 
al_source_route   : L_PAREN SOURCE_ROUTE EQUAL (YES_NO | ON_OFF) R_PAREN ;
                 
address          : L_PAREN ADDRESS EQUAL  protocol_info (a_params)? R_PAREN ;

a_params         : a_parameter+ ;

a_parameter      : d_send_buf
                 | d_recv_buf
                 ;                 
                 
protocol_info    : tcp_protocol       
                 | ipc_protocol
                 | spx_protocol
                 | nmp_protocol
                 | beq_protocol
                 ;                    


tcp_protocol     : tcp_params ;
                 
tcp_params       : tcp_parameter+ ;

tcp_parameter    : tcp_host
                 | tcp_port
                 | tcp_tcp
                 ;

tcp_host         : L_PAREN HOST EQUAL host R_PAREN ;
                 
tcp_port         : L_PAREN PORT EQUAL port R_PAREN ;
                 
tcp_tcp          : L_PAREN PROTOCOL EQUAL TCP R_PAREN ;
                 
host             : ID
                 | ID (DOT ID)+ 
                 | IP 
                 ;

port             : INT ;

ipc_protocol     : ipc_params ;
                 
ipc_params       : ipc_parameter+ ;

ipc_parameter    : ipc_ipc
                 | ipc_key
                 ;

ipc_ipc          : L_PAREN PROTOCOL EQUAL IPC R_PAREN ;

ipc_key          : L_PAREN KEY EQUAL ID R_PAREN ;





spx_protocol     : spx_params ; 

spx_params       : spx_parameter+ ; 

spx_parameter    : spx_spx
                 | spx_service ; 

spx_spx          : L_PAREN PROTOCOL EQUAL SPX R_PAREN ; 

spx_service      : L_PAREN SERVICE EQUAL ID R_PAREN ;


nmp_protocol     : nmp_params ;

nmp_params       : nmp_parameter+ ;

nmp_parameter    : nmp_nmp
                 | nmp_server
                 | nmp_pipe
                 ;
                 
nmp_nmp          : L_PAREN PROTOCOL EQUAL NMP R_PAREN ;

nmp_server       : L_PAREN SERVER EQUAL ID R_PAREN ;

nmp_pipe         : L_PAREN PIPE EQUAL ID R_PAREN ;
                 

beq_protocol     : beq_params ;

beq_params       : beq_parameter+ ;

beq_parameter    : beq_beq
                 | beq_program
                 | beq_argv0
                 | beq_args
                 ;
                 
beq_beq          : L_PAREN PROTOCOL EQUAL BEQ R_PAREN ;

beq_program      : L_PAREN PROGRAM EQUAL ID R_PAREN ;

beq_argv0        : L_PAREN ARGV0 EQUAL ID R_PAREN ;

beq_args         : L_PAREN ARGS EQUAL ba_parameter R_PAREN ;

ba_parameter     : S_QUOTE ba_description S_QUOTE ;

ba_description   : L_PAREN DESCRIPTION EQUAL bad_params R_PAREN ;

bad_params       : bad_parameter+ ;

bad_parameter    : bad_local
                 | bad_address
                 ;

bad_local        : L_PAREN LOCAL EQUAL YES_NO R_PAREN ;

bad_address      : L_PAREN ADDRESS EQUAL beq_beq R_PAREN ;


connect_data     : L_PAREN CONNECT_DATA EQUAL cd_params+ R_PAREN ;

cd_params       : cd_parameter+
                ;
                 
cd_parameter     : cd_service_name
                 | cd_sid
                 | cd_instance_name
                 | cd_failover_mode
                 | cd_global_name
                 | cd_hs
                 | cd_rdb_database
                 | cd_server
                 | cd_ur
                 ;

cd_service_name  : L_PAREN SERVICE_NAME EQUAL ID (DOT ID)* R_PAREN ;

cd_sid           : L_PAREN SID EQUAL ID R_PAREN ;

cd_instance_name : L_PAREN INSTANCE_NAME EQUAL ID (DOT ID)* R_PAREN ;


cd_failover_mode : L_PAREN FAILOVER_MODE EQUAL fo_params R_PAREN ;

cd_global_name   : L_PAREN GLOBAL_NAME EQUAL ID (DOT ID)* R_PAREN ;

cd_hs            : L_PAREN HS EQUAL OK R_PAREN ;

cd_rdb_database  : L_PAREN RDB_DATABASE EQUAL (L_SQUARE DOT ID R_SQUARE)? ID (DOT ID)* R_PAREN ;

cd_server        : L_PAREN SERVER EQUAL (DEDICATED | SHARED | POOLED) R_PAREN ;
                 
cd_ur            : L_PAREN UR EQUAL UR_A R_PAREN ;                 
                 
fo_params        : fo_parameter+ ;

fo_parameter     : fo_type
                 | fo_backup
                 | fo_method
                 | fo_retries
                 | fo_delay
                 ;
                 
fo_type          : L_PAREN TYPE EQUAL (SESSION | SELECT | NONE) R_PAREN ;

fo_backup        : L_PAREN BACKUP EQUAL ID (DOT ID)* R_PAREN ;

fo_method        : L_PAREN METHOD EQUAL (BASIC | PRECONNECT) R_PAREN ;

fo_retries       : L_PAREN RETRIES EQUAL INT R_PAREN ;

fo_delay         : L_PAREN DELAY EQUAL INT R_PAREN ;                 
                 


                 

L_PAREN          : '(' ;
                 
R_PAREN          : ')' ;
                 
L_SQUARE         : '[' ;
                 
R_SQUARE         : ']' ;
                 
EQUAL            : '=' ;
                 
DOT              : '.' ;   
                 
COMMA            : ',' ;

D_QUOTE          : '"' ;

S_QUOTE          : '\'' ;
                 
CONNECT_DATA     : C O N N E C T '_' D A T A ;

DESCRIPTION_LIST : DESCRIPTION '_' LIST ;
                 
DESCRIPTION      : D E S C R I P T I O N ;
                 
ADDRESS_LIST     : ADDRESS '_' LIST ;
                 
ADDRESS          : A D D R E S S ;
                 
PROTOCOL         : P R O T O C O L ;
                 
TCP              : T C P ;
                 
HOST             : H O S T ;
                 
PORT             : P O R T ;

LOCAL            : L O C A L ;

IP               : (DIGIT)+ DOT (DIGIT)+ DOT (DIGIT)+ DOT (DIGIT)+ ;
                 
YES_NO           : Y E S | N O ;
                 
ON_OFF           : O N | O F F ;
                 
TRUE_FALSE       : T R U E | F A L S E ;  
                 
COMMENT          : '#' (.)*? '\n' -> skip ;
                 
INT              : DIGIT+ ;
                 
OK               : O K ;
                 
DEDICATED        : D E D I C A T E D ;
                 
SHARED           : S H A R E D ;
                 
POOLED           : P O O L E D ;    
                 
LOAD_BALANCE     : L O A D '_' B A L A N C E ;   
                 
FAILOVER         : F A I L O V E R ;     
                 
UR               : U R ;
                 
UR_A             : A ;      
                 
ENABLE           : E N A B L E ;
                 
BROKEN           : B R O K E N ;
                 
SDU              : S D U ;
                 
RECV_BUF         : R E C V '_' BUF_SIZE ;
                 
SEND_BUF         : S E N D '_' BUF_SIZE ;
                 
SOURCE_ROUTE     : S O U R C E '_' R O U T E ;
                 
SERVICE          : S E R V I C E ;
                 
SERVICE_TYPE     : T Y P E '_' O F '_' SERVICE ;
                 
KEY              : K E Y ;
                 
IPC              : I P C ;

SPX              : S P X ;

NMP              : N M P ;

BEQ              : B E Q ;

PIPE             : P I P E ;

PROGRAM          : P R O G R A M ;

ARGV0            : A R G V '0' ;

ARGS             : A R G S ;
                 
SECURITY         : S E C U R I T Y ;
                 
SSL_CERT         : S S L '_' SERVER '_' C E R T '_' D N ;
                 
CONN_TIMEOUT     : C O N N E C T '_' T I M E O U T ;
                 
RETRY_COUNT      : R E T R Y '_' C O U N T ;
                 
TCT              : T R A N S P O R T '_' CONN_TIMEOUT ; 

IFILE            : I F I L E ; 

                 
DQ_STRING        : D_QUOTE (~'"')* D_QUOTE ;
                 
                 
SERVICE_NAME     : SERVICE '_' NAME ;
                 
SID              : S I D ;
                 
INSTANCE_NAME    : I N S T A N C E '_' NAME ;       
                 
FAILOVER_MODE    : FAILOVER '_' M O D E ;
                 
GLOBAL_NAME      : G L O B A L '_' NAME ;
                 
HS               : H S ;
                 
RDB_DATABASE     : R D B '_' D A T A B A S E ;
                 
SERVER           : S E R V E R ;
                 
BACKUP           : B A C K U P ;
                 
TYPE             : T Y P E ;
                 
SESSION          : S E S S I O N ;
                 
SELECT           : S E L E C T ;
                 
NONE             : N O N E ;
                 
METHOD           : M E T H O D ;
                 
BASIC            : B A S I C ;
                 
PRECONNECT       : P R E C O N N E C T ;
                 
RETRIES          : R E T R I E S ;
                 
DELAY            : D E L A Y ;                 



ID               : [A-Za-z0-9][A-Za-z0-9_-]* ;
WS               : [ \t\r\n]+ -> skip ;



fragment
A                : [Aa] ;
                 
fragment
B                : [Bb] ;
                 
fragment
C                : [Cc] ;
                 
fragment
D                : [Dd] ;
                 
fragment
E                : [Ee] ;
                 
fragment
F                : [Ff] ;
                 
fragment
G                : [Gg] ;
                 
fragment
H                : [Hh] ;
                 
fragment
I                : [Ii] ;
                 
fragment
J                : [Jj] ;
                 
fragment
K                : [Kk] ;
                 
fragment
L                : [Ll] ;
                 
fragment
M                : [Mm] ;
                 
fragment
N                : [Nn] ;
                 
fragment
O                : [Oo] ;
                 
fragment
P                : [Pp] ;
                 
fragment
Q                : [Qq] ;
                 
fragment
R                : [Rr] ;
                 
fragment
S                : [Ss] ;
                 
fragment
T                : [Tt] ;
                 
fragment
U                : [Uu] ;
                 
fragment
V                : [Vv] ;
                 
fragment
W                : [Ww] ;
                 
fragment
X                : [Xx] ;
                 
fragment
Y                : [Yy] ;
                 
fragment
Z                : [Zz] ;

fragment
DIGIT            : [0-9] ;
                 
fragment
LIST             : L I S T ;
                 
fragment
NAME             : N A M E ;
                 
fragment
BUF_SIZE         :B U F '_' S I Z E ;                 
