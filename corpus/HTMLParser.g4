parser grammar HTMLParser;

options { tokenVocab=HTMLLexer; }

htmlDocument    
    : (scriptlet | SEA_WS)* xml? (scriptlet | SEA_WS)* dtd? (scriptlet | SEA_WS)* htmlElements*
    ;

htmlElements
    : htmlMisc* htmlElement htmlMisc*
    ;

htmlElement     
    : TAG_OPEN htmlTagName htmlAttribute* TAG_CLOSE htmlContent TAG_OPEN TAG_SLASH htmlTagName TAG_CLOSE
    | TAG_OPEN htmlTagName htmlAttribute* TAG_SLASH_CLOSE
    | TAG_OPEN htmlTagName htmlAttribute* TAG_CLOSE
    | scriptlet
    | script
    | style
    ;

htmlContent     
    : htmlChardata? ((htmlElement | xhtmlCDATA | htmlComment) htmlChardata?)*
    ;

htmlAttribute   
    : htmlAttributeName TAG_EQUALS htmlAttributeValue
    | htmlAttributeName
    ;

htmlAttributeName
    : TAG_NAME
    ;

htmlAttributeValue
    : ATTVALUE_VALUE
    ;

htmlTagName
    : TAG_NAME
    ;

htmlChardata    
    : HTML_TEXT 
    | SEA_WS
    ;

htmlMisc        
    : htmlComment 
    | SEA_WS
    ;

htmlComment
    : HTML_COMMENT
    | HTML_CONDITIONAL_COMMENT
    ;

xhtmlCDATA
    : CDATA
    ;

dtd
    : DTD
    ;

xml
    : XML_DECLARATION
    ;

scriptlet
    : SCRIPTLET
    ;

script
    : SCRIPT_OPEN ( SCRIPT_BODY | SCRIPT_SHORT_BODY)
    ;

style
    : STYLE_OPEN ( STYLE_BODY | STYLE_SHORT_BODY)
    ;
