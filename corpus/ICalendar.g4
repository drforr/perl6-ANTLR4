grammar ICalendar;

parse
 : icalstream EOF
 ;

icalstream
 : CRLF* icalobject (CRLF+ icalobject)* CRLF*
 ;

icalobject
 : k_begin COL k_vcalendar CRLF 
   calprop*? 
   component+?
   k_end COL k_vcalendar
 ;

calprop
 : prodid
 | version
 | calscale
 | method
 | x_prop
 | iana_prop
 ;

calscale
 : k_calscale (SCOL other_param)* COL k_gregorian CRLF
 ;

method
 : k_method (SCOL other_param)* COL iana_token CRLF
 ;

prodid
 : k_prodid (SCOL other_param)* COL text CRLF
 ;

version
 : k_version (SCOL other_param)* COL vervalue CRLF
 ;

vervalue
 : float_num SCOL float_num
 | float_num
 ;

component
 : eventc 
 | todoc 
 | journalc 
 | freebusyc 
 | timezonec 
 | iana_comp 
 | x_comp
 ;

iana_comp
 : k_begin COL iana_token CRLF
   contentline+?
   k_end COL iana_token CRLF
 ;

x_comp
 : k_begin COL x_name CRLF
   contentline+?
   k_end COL x_name CRLF
 ;

contentline
 : name (SCOL icalparameter)* COL value CRLF
 ;

name 
 : iana_token
 | x_name
 ;

value
 : value_char*
 ;

eventc
 : k_begin COL k_vevent CRLF
   eventprop*?
   alarmc*?
   k_end COL k_vevent CRLF
 ;

todoc
 : k_begin COL k_vtodo CRLF
   todoprop*? 
   alarmc*?
   k_end COL k_vtodo CRLF
 ;

journalc
 : k_begin COL k_vjournal CRLF
   jourprop*?
   k_end COL k_vjournal CRLF
 ;

freebusyc
 : k_begin COL k_vfreebusy CRLF
   fbprop*?
   k_end COL k_vfreebusy CRLF
 ;

timezonec
 : k_begin COL k_vtimezone CRLF
   timezoneprop*?
   k_end COL k_vtimezone CRLF
 ;

alarmc
 : k_begin COL k_valarm CRLF
   alarmprop+?
   k_end COL k_valarm CRLF
 ;

eventprop
 : dtstamp
 | uid
 | dtstart
 | clazz
 | created
 | description
 | geo
 | last_mod
 | location
 | organizer
 | priority
 | seq
 | status
 | summary
 | transp
 | url
 | recurid
 | rrule
 | dtend
 | duration
 | attach
 | attendee
 | categories
 | comment
 | contact
 | exdate
 | rstatus
 | related
 | resources
 | rdate
 | x_prop
 | iana_prop
 ;

todoprop
 : dtstamp
 | uid
 | clazz
 | completed
 | created
 | description
 | dtstart
 | geo
 | last_mod
 | location
 | organizer
 | percent
 | priority
 | recurid
 | seq
 | status
 | summary
 | url
 | rrule
 | due
 | duration
 | attach
 | attendee
 | categories
 | comment
 | contact
 | exdate
 | rstatus
 | related
 | resources
 | rdate
 | x_prop
 | iana_prop
 ;

jourprop
 : dtstamp
 | uid
 | clazz
 | created
 | dtstart
 | last_mod
 | organizer
 | recurid
 | seq
 | status
 | summary
 | url
 | rrule
 | attach
 | attendee
 | categories
 | comment
 | contact
 | description
 | exdate
 | related
 | rdate
 | rstatus
 | x_prop
 | iana_prop
 ;

fbprop
 : dtstamp
 | uid
 | contact
 | dtstart
 | dtend
 | organizer
 | url
 | attendee
 | comment
 | freebusy
 | rstatus
 | x_prop
 | iana_prop
 ;

timezoneprop
 : tzid
 | last_mod
 | tzurl
 | standardc
 | daylightc
 | x_prop
 | iana_prop
 ;

tzprop
 : dtstart
 | tzoffsetto
 | tzoffsetfrom
 | rrule
 | comment
 | rdate
 | tzname
 | x_prop
 | iana_prop
 ;

alarmprop
 : action
 | description
 | trigger
 | summary
 | attendee
 | duration
 | repeat
 | attach
 | x_prop
 | iana_prop
 ;

standardc
 : k_begin COL k_standard CRLF
   tzprop*?
   k_end COL k_standard CRLF
 ;

daylightc
 : k_begin COL k_daylight CRLF
   tzprop*?
   k_end COL k_daylight CRLF
 ;

attach
 : k_attach attachparam* ( COL uri 
                         | SCOL k_encoding ASSIGN k_base D6 D4 SCOL k_value ASSIGN k_binary COL binary
                         )
   CRLF
 ;

attachparam
 : SCOL fmttypeparam
 | SCOL other_param
 ;

categories
 : k_categories catparam* COL text (COMMA text)* CRLF
 ;

catparam
 : SCOL languageparam
 | SCOL other_param
 ;

clazz
 : k_class (SCOL other_param)* COL classvalue CRLF
 ;

classvalue
 : k_public
 | k_private
 | k_confidential
 | iana_token
 | x_name
 ;

comment
 : k_comment commparam* COL text CRLF
 ;

commparam
 : SCOL altrepparam
 | SCOL languageparam
 | SCOL other_param
 ;

description
 : k_description descparam* COL text CRLF
 ;

descparam
 : SCOL altrepparam
 | SCOL languageparam
 | SCOL other_param
 ;

geo
 : k_geo (SCOL other_param)* COL geovalue CRLF
 ;

geovalue
 : float_num SCOL float_num
 ;

location
 : k_location locparam* COL text CRLF
 ;

locparam
 : SCOL altrepparam
 | SCOL languageparam
 | SCOL other_param
 ;

percent
 : k_percent_complete (SCOL other_param)* COL integer CRLF
 ;

priority
 : k_priority (SCOL other_param)* COL priovalue CRLF
 ;

priovalue
 : integer
 ;
               
resources
 : k_resources resrcparam* COL text (COMMA text)* CRLF
 ;

resrcparam
 : SCOL altrepparam
 | SCOL languageparam
 | SCOL other_param
 ;

status
 : k_status (SCOL other_param)* COL statvalue CRLF
 ;

statvalue
 : statvalue_event
 | statvalue_todo
 | statvalue_jour
 ;

statvalue_event
 : k_tentative
 | k_confirmed
 | k_cancelled
 ;

statvalue_todo
 : k_needs_action
 | k_completed
 | k_in_progress
 | k_cancelled
 ;

statvalue_jour
 : k_draft
 | k_final
 | k_cancelled
 ;

summary
 : k_summary summparam* COL text CRLF
 ;

summparam
 : SCOL altrepparam
 | SCOL languageparam
 | SCOL other_param
 ;

completed
 : k_completed (SCOL other_param)* COL date_time CRLF
 ;

dtend
 : k_dtend dtendparam* COL date_time_date CRLF
 ;

dtendparam
 : SCOL k_value ASSIGN k_date_time
 | SCOL k_value ASSIGN k_date
 | SCOL tzidparam
 | SCOL other_param
 ;

due
 : k_due dueparam* COL date_time_date CRLF
 ;

dueparam
 : SCOL k_value ASSIGN k_date_time
 | SCOL k_value ASSIGN k_date
 | SCOL tzidparam
 | SCOL other_param
 ;

dtstart
 : k_dtstart dtstparam* COL date_time_date CRLF
 ;

dtstparam
 : SCOL k_value ASSIGN k_date_time
 | SCOL k_value ASSIGN k_date
 | SCOL tzidparam
 | SCOL other_param
 ;

duration
 : k_duration (SCOL other_param)* COL dur_value CRLF
 ;

freebusy
 : k_freebusy fbparam* COL fbvalue CRLF
 ;

fbparam
 : SCOL fbtypeparam
 | SCOL other_param 
 ;

fbvalue
 : period (COMMA period)*
 ;

transp
 : k_transp (SCOL other_param)* COL transvalue CRLF
 ;

transvalue
 : k_opaque
 | k_transparent
 ;

tzid
 : k_tzid (SCOL other_param)* COL FSLASH? text CRLF
 ;

tzname
 : k_tzname tznparam* COL text CRLF
 ;

tznparam
 : SCOL languageparam
 | SCOL other_param
 ;

tzoffsetfrom
 : k_tzoffsetfrom (SCOL other_param)* COL utc_offset CRLF
 ;

tzoffsetto
 : k_tzoffsetto (SCOL other_param)* COL utc_offset CRLF
 ;

tzurl
 : k_tzurl (SCOL other_param)* COL uri CRLF
 ;

attendee
 : k_attendee attparam* COL cal_address CRLF
 ;

attparam
 : SCOL cutypeparam
 | SCOL memberparam
 | SCOL roleparam
 | SCOL partstatparam
 | SCOL rsvpparam
 | SCOL deltoparam
 | SCOL delfromparam
 | SCOL sentbyparam
 | SCOL cnparam
 | SCOL dirparam
 | SCOL languageparam
 | SCOL other_param
 ;

contact
 : k_contact contparam* COL text CRLF
 ;

contparam
 : SCOL altrepparam
 | SCOL languageparam
 | SCOL other_param
 ;

organizer
 : k_organizer orgparam* COL cal_address CRLF
 ;

orgparam
 : SCOL cnparam
 | SCOL dirparam
 | SCOL sentbyparam
 | SCOL languageparam
 | SCOL other_param
 ;

recurid
 : k_recurrence_id ridparam* COL date_time_date CRLF
 ;

ridparam
 : SCOL k_value ASSIGN k_date_time
 | SCOL k_value ASSIGN k_date
 | SCOL tzidparam
 | SCOL rangeparam
 | SCOL other_param
 ;

related
 : k_related_to relparam* COL text CRLF
 ;

relparam
 : SCOL reltypeparam
 | SCOL other_param
 ;

url
 : k_url (SCOL other_param)* COL uri CRLF
 ;

uid
 : k_uid (SCOL other_param)* COL text CRLF
 ;

exdate
 : k_exdate exdtparam* COL date_time_date (COMMA date_time_date)* CRLF
 ;

exdtparam
 : SCOL k_value ASSIGN k_date_time
 | SCOL k_value ASSIGN k_date
 | SCOL tzidparam
 | SCOL other_param
 ;

rdate
 : k_rdate rdtparam* COL rdtval (COMMA rdtval)* CRLF
 ;

rdtparam
 : SCOL k_value ASSIGN k_date_time
 | SCOL k_value ASSIGN k_date
 | SCOL k_value ASSIGN k_period
 | SCOL tzidparam
 | SCOL other_param
 ;

rdtval
 : date_time
 | date
 | period
 ;

date_time_date
 : date_time
 | date
 ;

rrule
 : k_rrule (SCOL other_param)* COL recur CRLF
 ;

action
 : k_action (SCOL other_param)* COL actionvalue CRLF
 ;

actionvalue
 : k_audio
 | k_display
 | k_email
 | iana_token
 | x_name
 ;

repeat
 : k_repeat (SCOL other_param)* COL integer CRLF
 ;

trigger
 : k_trigger trigrel* COL dur_value CRLF
 | k_trigger trigabs* COL date_time CRLF
 ;

trigrel
 : SCOL k_value ASSIGN  k_duration
 | SCOL trigrelparam
 | SCOL other_param
 ;

trigabs
 : SCOL k_value ASSIGN k_date_time
 | SCOL other_param  
 ;
           
created
 : k_created (SCOL other_param)* COL date_time CRLF
 ;

dtstamp
 : k_dtstamp (SCOL other_param)* COL date_time CRLF
 ;

last_mod
 : k_last_modified (SCOL other_param)* COL date_time CRLF
 ;

seq
 : k_sequence (SCOL other_param)* COL integer CRLF
 ;

iana_prop
 : iana_token (SCOL icalparameter)* COL value CRLF
 ;

x_prop
 : x_name (SCOL icalparameter)* COL value CRLF
 ;

rstatus
 : k_request_status rstatparam* COL statcode SCOL text (SCOL text)?
 ;

rstatparam
 : SCOL languageparam
 | SCOL other_param
 ;

statcode
 : digit+ DOT digit+ (DOT digit+)?
 ;

param_name
 : iana_token
 | x_name
 ;

param_value
 : paramtext
 | quoted_string
 ;

paramtext
 : safe_char*
 ;

quoted_string
 : DQUOTE qsafe_char* DQUOTE
 ;
  
iana_token
 : (alpha | MINUS)+
 ;

icalparameter
 : altrepparam
 | cnparam
 | cutypeparam
 | delfromparam
 | deltoparam
 | dirparam
 | encodingparam
 | fmttypeparam
 | fbtypeparam
 | languageparam
 | memberparam
 | partstatparam
 | rangeparam
 | trigrelparam
 | reltypeparam
 | roleparam
 | rsvpparam
 | sentbyparam
 | tzidparam
 | valuetypeparam
 | other_param
 ;

altrepparam
 : k_altrep ASSIGN DQUOTE uri DQUOTE
 ;

cnparam
 : k_cn ASSIGN param_value
 ;

cutypeparam
 : k_cutype ASSIGN ( k_individual
                   | k_group
                   | k_resource
                   | k_room
                   | k_unknown
                   | x_name
                   | iana_token
                   )
 ;

delfromparam
 : k_delegated_from ASSIGN DQUOTE cal_address DQUOTE (COMMA DQUOTE cal_address DQUOTE)*
 ;

deltoparam
 : k_delegated_to ASSIGN DQUOTE cal_address DQUOTE (COMMA DQUOTE cal_address DQUOTE)*
 ;

dirparam
 : k_dir ASSIGN DQUOTE uri DQUOTE
 ;

encodingparam
 : k_encoding ASSIGN ( D8 k_bit
                     | k_base D6 D4
                     )
 ;

fmttypeparam
 : k_fmttype ASSIGN type_name FSLASH subtype_name
 ;

fbtypeparam
 : k_fbtype ASSIGN ( k_free
                   | k_busy
                   | k_busy_unavailable
                   | k_busy_tentative
                   | x_name
                   | iana_token
                   )
 ;

languageparam
 : k_language ASSIGN language
 ;

memberparam
 : k_member ASSIGN DQUOTE cal_address DQUOTE (COMMA DQUOTE cal_address DQUOTE)*
 ;

partstatparam
 : k_partstat ASSIGN ( partstat_event
                     | partstat_todo
                     | partstat_jour
                     )
 ;

rangeparam
 : k_range ASSIGN k_thisandfuture
 ;

trigrelparam
 : k_related ASSIGN ( k_start
                    | k_end
                    )
 ;

reltypeparam
 : k_reltype ASSIGN ( k_parent
                    | k_child
                    | k_sibling
                    | x_name
                    | iana_token
                    )
 ;

roleparam
 : k_role ASSIGN ( k_chair
                 | k_req_participant
                 | k_opt_participant 
                 | k_non_participant
                 | iana_token
                 | x_name
                 )
 ;

rsvpparam
 : k_rsvp ASSIGN ( k_true
                 | k_false
                 )
 ;

sentbyparam
 : k_sent_by ASSIGN DQUOTE cal_address DQUOTE
 ;

tzidparam
 : k_tzid ASSIGN FSLASH? paramtext
 ;

valuetypeparam
 : k_value ASSIGN valuetype
 ;

valuetype
 : k_binary
 | k_boolean
 | k_cal_address
 | k_date
 | k_date_time
 | k_duration
 | k_float
 | k_integer
 | k_period
 | k_recur
 | k_text
 | k_time
 | k_uri
 | k_utc_offset
 | x_name
 | iana_token
 ;

binary
 : b_chars b_end?
 ;

b_chars
 : b_char*
 ;

b_end
 : ASSIGN ASSIGN?
 ;

bool
 : k_true
 | k_false
 ;

cal_address
 : uri
 ;

date
 : date_value
 ;

date_time
 : date T time
 ;

dur_value
 : MINUS P (dur_date | dur_time | dur_week)
 | PLUS? P (dur_date | dur_time | dur_week)
 ;

float_num
 : MINUS digits (DOT digits)?
 | PLUS? digits (DOT digits)?
 ;

digits
 : digit+
 ;

integer
 : MINUS digits
 | PLUS? digits
 ;

period
 : period_explicit
 | period_start
 ;

recur
 : recur_rule_part (SCOL recur_rule_part)*
 ;

text
 : (tsafe_char | COL | DQUOTE | ESCAPED_CHAR)*
 ;

time
 : time_hour time_minute time_second Z?
 ;

uri
 : qsafe_char+
 ;

utc_offset
 : time_numzone
 ;

other_param
 : iana_param
 | x_param
 ;

iana_param
 : iana_token ASSIGN param_value (COMMA param_value)*
 ;

x_param
 : x_name ASSIGN param_value (COMMA param_value)*
 ;

type_name
 : reg_name
 ;

subtype_name
 : reg_name
 ;

reg_name
 : reg_name_char+
 ;

language
 : language_char+
 ;

partstat_event
 : k_needs_action
 | k_accepted
 | k_declined
 | k_tentative
 | k_delegated
 | x_name
 | iana_token
 ;

partstat_todo
 : k_needs_action
 | k_accepted
 | k_declined
 | k_tentative
 | k_delegated
 | k_completed
 | k_in_progress
 | x_name
 | iana_token
 ;

partstat_jour
 : k_needs_action
 | k_accepted
 | k_declined
 | x_name
 | iana_token
 ;

b_char
 : alpha
 | digit
 | PLUS
 | FSLASH
 ;

date_value
 : date_fullyear date_month date_mday
 ;

date_fullyear
 : digits_2 digits_2
 ;

date_month
 : digits_2
 ;

date_mday
 : digits_2
 ;

time_hour
 : digits_2
 ;

time_minute
 : digits_2
 ;

time_second
 : digits_2
 ;

dur_date
 : dur_day dur_time?
 ;

dur_day
 : digit+ D
 ;

dur_time
 : T? (dur_hour | dur_minute | dur_second)
 ;

dur_week
 : digit+ W
 ;

dur_hour
 : digit+ H dur_minute?
 ;

dur_minute
 : digit+ M dur_second?
 ;

dur_second
 : digit+ S
 ;

period_explicit
 : date_time FSLASH date_time
 ;

period_start
 : date_time FSLASH dur_value
 ;

recur_rule_part
 : k_freq ASSIGN freq
 | k_until ASSIGN enddate
 | k_count ASSIGN count
 | k_interval ASSIGN interval
 | k_bysecond ASSIGN byseclist
 | k_byminute ASSIGN byminlist
 | k_byhour ASSIGN byhrlist
 | k_byday ASSIGN bywdaylist
 | k_bymonthday ASSIGN bymodaylist
 | k_byyearday ASSIGN byyrdaylist
 | k_byweekno ASSIGN bywknolist
 | k_bymonth ASSIGN bymolist
 | k_bysetpos ASSIGN bysplist
 | k_wkst ASSIGN weekday
 ;

freq
 : k_secondly
 | k_minutely
 | k_hourly
 | k_daily
 | k_weekly
 | k_monthly
 | k_yearly
 ;

enddate
 : date 
 | date_time
 ;

count
 : digits
 ;

interval
 : digits
 ;

byseclist
 : digits_1_2 (COMMA digits_1_2)*
 ;

byminlist
 : digits_1_2 (COMMA digits_1_2)*
 ;

byhrlist
 : digits_1_2 (COMMA digits_1_2)*
 ;

bywdaylist
 : weekdaynum (COMMA weekdaynum)*
 ;

weekdaynum
 : ((PLUS | MINUS)? digits_1_2)? weekday
 ;

weekday
 : S U
 | M O
 | T U
 | W E
 | T H
 | F R
 | S A
 ;

bymodaylist
 : monthdaynum (COMMA monthdaynum)*
 ;

monthdaynum
 : (PLUS | MINUS)? digits_1_2
 ;

byyrdaylist
 : yeardaynum (COMMA yeardaynum)*
 ;

yeardaynum
 : (PLUS | MINUS)? ordyrday
 ;

ordyrday
 : digit (digit digit?)?
 ;

bywknolist
 : weeknum (COMMA weeknum)*
 ;

weeknum
 : (PLUS | MINUS)? digits_1_2
 ;

bymolist
 : digits_1_2 (COMMA digits_1_2)*
 ;

bysplist
 : yeardaynum (COMMA yeardaynum)*
 ;

digits_2
 : digit digit
 ;

digits_1_2
 : digit digit?
 ;

safe_char
 : ~(CRLF | CONTROL | DQUOTE | SCOL | COL | COMMA)
 ;

value_char
 : ~(CRLF | CONTROL | ESCAPED_CHAR)
 ;

qsafe_char
 : ~(CRLF | CONTROL | DQUOTE)
 ;

tsafe_char
 : ~(CRLF | CONTROL | DQUOTE | SCOL | COL | BSLASH | COMMA)
 ;

time_numzone
 : (PLUS | MINUS) time_hour time_minute time_second?
 ;

reg_name_char
 : alpha
 | digit
 | EXCLAMATION
 | HASH
 | DOLLAR
 | AMP
 | DOT
 | PLUS
 | MINUS
 | CARET
 | USCORE
 ;

language_char
 : alpha
 | digit
 | MINUS
 | COL
 | WSP
 ;

x_name
 : X (alpha_num alpha_num alpha_num+ MINUS)? (alpha_num | MINUS)+
 ;

alpha_num
 : alpha
 | digit
 ;

digit
 : D0 
 | D1 
 | D2 
 | D3 
 | D4 
 | D5 
 | D6 
 | D7 
 | D8 
 | D9
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

k_accepted : A C C E P T E D;
k_action : A C T I O N;
k_address : A D D R E S S;
k_altrep : A L T R E P;
k_attach : A T T A C H;
k_attendee : A T T E N D E E;
k_audio : A U D I O;
k_base : B A S E;
k_begin : B E G I N;
k_binary : B I N A R Y;
k_bit : B I T;
k_boolean : B O O L E A N;
k_busy : B U S Y;
k_busy_unavailable : B U S Y MINUS U N A V A I L A B L E;
k_busy_tentative : B U S Y MINUS T E N T A T I V E;
k_byday : B Y D A Y;
k_byhour : B Y H O U R;
k_byminute : B Y M I N U T E;
k_bymonth : B Y M O N T H;
k_bymonthday : B Y M O N T H D A Y;
k_bysecond : B Y S E C O N D;
k_bysetpos : B Y S E T P O S;
k_byweekno : B Y W E E K N O;
k_byyearday : B Y Y E A R D A Y;
k_cal_address : C A L MINUS A D D R E S S;
k_calscale : C A L S C A L E;
k_cancelled : C A N C E L L E D;
k_categories : C A T E G O R I E S;
k_chair : C H A I R;
k_child : C H I L D;
k_class : C L A S S;
k_cn : C N;
k_comment : C O M M E N T;
k_completed : C O M P L E T E D;
k_confidential : C O N F I D E N T I A L;
k_confirmed : C O N F I R M E D;
k_contact : C O N T A C T;
k_count : C O U N T;
k_created : C R E A T E D;
k_cutype : C U T Y P E;
k_daily : D A I L Y;
k_date : D A T E;
k_date_time : D A T E MINUS T I M E;
k_daylight : D A Y L I G H T;
k_declined : D E C L I N E D;
k_delegated : D E L E G A T E D;
k_delegated_from : D E L E G A T E D MINUS F R O M;
k_delegated_to : D E L E G A T E D MINUS T O;
k_description : D E S C R I P T I O N;
k_dir : D I R;
k_display : D I S P L A Y;
k_draft : D R A F T;
k_dtend : D T E N D;
k_dtstamp : D T S T A M P;
k_dtstart : D T S T A R T;
k_due : D U E;
k_duration : D U R A T I O N;
k_email : E M A I L;
k_encoding : E N C O D I N G;
k_end : E N D;
k_exdate : E X D A T E;
k_false : F A L S E;
k_fbtype : F B T Y P E;
k_final : F I N A L;
k_float : F L O A T;
k_fmttype : F M T T Y P E;
k_fr : F R;
k_free : F R E E;
k_freebusy : F R E E B U S Y;
k_freq : F R E Q;
k_geo : G E O;
k_gregorian : G R E G O R I A N;
k_group : G R O U P;
k_hourly : H O U R L Y;
k_in_progress : I N MINUS P R O G R E S S;
k_individual : I N D I V I D U A L;
k_integer : I N T E G E R;
k_interval : I N T E R V A L;
k_language : L A N G U A G E;
k_last_modified : L A S T MINUS M O D I F I E D;
k_location : L O C A T I O N;
k_member : M E M B E R;
k_method : M E T H O D;
k_minutely : M I N U T E L Y;
k_mo : M O;
k_monthly : M O N T H L Y;
k_needs_action : N E E D S MINUS A C T I O N;
k_non_participant : N O N MINUS P A R T I C I P A N T;
k_opaque : O P A Q U E;
k_opt_participant : O P T MINUS P A R T I C I P A N T;
k_organizer : O R G A N I Z E R;
k_parent : P A R E N T;
k_participant : P A R T I C I P A N T;
k_partstat : P A R T S T A T;
k_percent_complete : P E R C E N T MINUS C O M P L E T E;
k_period : P E R I O D;
k_priority : P R I O R I T Y;
k_private : P R I V A T E;
k_process : P R O C E S S;
k_prodid : P R O D I D;
k_public : P U B L I C;
k_range : R A N G E;
k_rdate : R D A T E;
k_recur : R E C U R;
k_recurrence_id : R E C U R R E N C E MINUS I D;
k_relat : R E L A T;
k_related : R E L A T E D;
k_related_to : R E L A T E D MINUS T O;
k_reltype : R E L T Y P E;
k_repeat : R E P E A T;
k_req_participant : R E Q MINUS P A R T I C I P A N T;
k_request_status : R E Q U E S T MINUS S T A T U S;
k_resource : R E S O U R C E;
k_resources : R E S O U R C E S;
k_role : R O L E;
k_room : R O O M;
k_rrule : R R U L E;
k_rsvp : R S V P;
k_sa : S A;
k_secondly : S E C O N D L Y;
k_sent_by : S E N T MINUS B Y;
k_sequence : S E Q U E N C E;
k_sibling : S I B L I N G;
k_standard : S T A N D A R D;
k_start : S T A R T;
k_status : S T A T U S;
k_su : S U;
k_summary : S U M M A R Y;
k_tentative : T E N T A T I V E;
k_text : T E X T;
k_th : T H;
k_thisandfuture : T H I S A N D F U T U R E;
k_time : T I M E;
k_transp : T R A N S P;
k_transparent : T R A N S P A R E N T;
k_trigger : T R I G G E R;
k_true : T R U E;
k_tu : T U;
k_tzid : T Z I D;
k_tzname : T Z N A M E;
k_tzoffsetfrom : T Z O F F S E T F R O M;
k_tzoffsetto : T Z O F F S E T T O;
k_tzurl : T Z U R L;
k_uid : U I D;
k_unknown : U N K N O W N;
k_until : U N T I L;
k_uri : U R I;
k_url : U R L;
k_utc_offset : U T C MINUS O F F S E T;
k_valarm : V A L A R M;
k_value : V A L U E;
k_vcalendar : V C A L E N D A R;
k_version : V E R S I O N;
k_vevent : V E V E N T;
k_vfreebusy : V F R E E B U S Y;
k_vjournal : V J O U R N A L;
k_vtimezone : V T I M E Z O N E;
k_vtodo : V T O D O;
k_we : W E;
k_weekly : W E E K L Y;
k_wkst : W K S T;
k_yearly : Y E A R L Y;

LINE_FOLD
 : CRLF WSP -> skip
 ;

WSP
 : ' '
 | '\t'
 ;

ESCAPED_CHAR
 : '\\' (CRLF WSP)? '\\'
 | '\\' (CRLF WSP)? ';'
 | '\\' (CRLF WSP)? ','
 | '\\' (CRLF WSP)? N
 ;

CRLF
 : '\r'? '\n' 
 | '\r'
 ;

CONTROL
 : [\u0000-\u0008]
 | [\u000B-\u000C]
 | [\u000E-\u001F]
 | [\u007F]
 ;

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

EXCLAMATION : '!';
DQUOTE : '"';
HASH : '#';
DOLLAR : '$';
X25 : '%';
AMP : '&';
X27 : '\'';
X28 : '(';
X29 : ')';
X2A : '*';
PLUS : '+';
COMMA : ',';
MINUS : '-';
DOT : '.';
FSLASH : '/';
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
COL : ':';
SCOL : ';';
X3C : '<';
ASSIGN : '=';
X3E : '>';
X3F : '?';
X40 : '@';
X5B : '[';
BSLASH : '\\';
X5D : ']';
CARET : '^';
USCORE : '_';
X60 : '`';
X7B : '{';
X7C : '|';
X7D : '}';
X7E : '~';

NON_US_ASCII
 : .
 ;
