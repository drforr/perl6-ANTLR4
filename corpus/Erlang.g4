grammar Erlang;

forms : form+ EOF ;

form : (attribute | function | ruleClauses) '.' ;


tokAtom : TokAtom ;
TokAtom : [a-z@][0-9a-zA-Z_@]*
        | '\'' ( '\\' (~'\\'|'\\') | ~[\\''] )* '\'' ;

tokVar : TokVar ;
TokVar : [A-Z_][0-9a-zA-Z_]* ;

tokFloat : TokFloat ;
TokFloat : '-'? [0-9]+ '.' [0-9]+  ([Ee] [+-]? [0-9]+)? ;

tokInteger : TokInteger ;
TokInteger : '-'? [0-9]+ ('#' [0-9a-zA-Z]+)? ;

tokChar : TokChar ;
TokChar : '$' ('\\'? ~[\r\n] | '\\' [0-9] [0-9] [0-9]) ;

tokString : TokString ;
TokString : '"' ( '\\' (~'\\'|'\\') | ~[\\"] )* '"' ;

AttrName : '-' ('spec' | 'callback') ;

Comment : '%' ~[\r\n]* '\r'? '\n' -> skip ;

WS : [ \t\r\n]+ -> skip ;



attribute : '-' tokAtom                           attrVal
          | '-' tokAtom                      typedAttrVal
          | '-' tokAtom                  '(' typedAttrVal ')'
          | AttrName                           typeSpec
          ;



typeSpec :     specFun typeSigs
         | '(' specFun typeSigs ')'
         ;

specFun :             tokAtom
        | tokAtom ':' tokAtom
        |             tokAtom '/' tokInteger '::'
        | tokAtom ':' tokAtom '/' tokInteger '::'
        ;

typedAttrVal : expr ','  typedRecordFields
             | expr '::' topType
             ;

typedRecordFields : '{' typedExprs '}' ;

typedExprs : typedExpr
           | typedExpr  ',' typedExprs
           | expr       ',' typedExprs
           | typedExpr  ','      exprs ;

typedExpr : expr '::' topType ;

typeSigs : typeSig (';' typeSig)* ;

typeSig : funType ('when' typeGuards)? ;

typeGuards : typeGuard (',' typeGuard)* ;

typeGuard : tokAtom '(' topTypes ')'
          | tokVar '::' topType ;

topTypes : topType (',' topType)* ;

topType : (tokVar '::')? topType100 ;

topType100 : type200 ('|' topType100)? ;

type200 : type300 ('..' type300)? ;

type300 : type300 addOp type400
        |               type400 ;

type400 : type400 multOp type500
        |                type500 ;

type500 : prefixOp? type ;

type : '(' topType ')'
     | tokVar
     | tokAtom
     | tokAtom             '('          ')'
     | tokAtom             '(' topTypes ')'
     | tokAtom ':' tokAtom '('          ')'
     | tokAtom ':' tokAtom '(' topTypes ')'
     | '['                   ']'
     | '[' topType           ']'
     | '[' topType ',' '...' ']'
     | '{'          '}'
     | '{' topTypes '}'
     | '#' tokAtom '{'            '}'
     | '#' tokAtom '{' fieldTypes '}'
     | binaryType
     | tokInteger
     | 'fun' '('            ')'
     | 'fun' '(' funType100 ')' ;

funType100 : '(' '...' ')' '->' topType
           | funType ;

funType : '(' (topTypes)? ')' '->' topType ;

fieldTypes : fieldType (',' fieldType)* ;

fieldType : tokAtom '::' topType ;

binaryType : '<<'                             '>>'
           | '<<' binBaseType                 '>>'
           | '<<'                 binUnitType '>>'
           | '<<' binBaseType ',' binUnitType '>>'
           ;

binBaseType : tokVar ':'            type ;

binUnitType : tokVar ':' tokVar '*' type ;




attrVal :     expr
        | '(' expr           ')'
        |     expr ',' exprs
        | '(' expr ',' exprs ')' ;

function : functionClause (';' functionClause)* ;

functionClause : tokAtom clauseArgs clauseGuard clauseBody ;


clauseArgs : argumentList ;

clauseGuard : ('when' guard)? ;

clauseBody : '->' exprs ;


expr : 'catch' expr
     | expr100 ;

expr100 : expr150 (('=' | '!') expr150)* ;

expr150 : expr160 ('orelse' expr160)* ;

expr160 : expr200 ('andalso' expr200)* ;

expr200 : expr300 (compOp expr300)? ;

expr300 : expr400 (listOp expr400)* ;

expr400 : expr500 (addOp expr500)* ;

expr500 : expr600 (multOp expr600)* ;

expr600 : prefixOp? expr700 ;

expr700 : functionCall
        | recordExpr
        | expr800 ;

expr800 : exprMax (':' exprMax)? ;

exprMax : tokVar
        | atomic
        | list
        | binary
        | listComprehension
        | binaryComprehension
        | tuple
        | '(' expr ')'
        | 'begin' exprs 'end'
        | ifExpr
        | caseExpr
        | receiveExpr
        | funExpr
        | tryExpr
        ;

list : '['      ']'
     | '[' expr tail
     ;
tail :          ']'
     | '|' expr ']'
     | ',' expr tail
     ;

binary : '<<'             '>>'
       | '<<' binElements '>>' ;

binElements : binElement (',' binElement)* ;

binElement : bitExpr optBitSizeExpr optBitTypeList ;

bitExpr : prefixOp? exprMax ;

optBitSizeExpr : (':' bitSizeExpr)? ;

optBitTypeList : ('/' bitTypeList)? ;

bitTypeList : bitType ('-' bitType)* ;

bitType : tokAtom (':' tokInteger)? ;

bitSizeExpr : exprMax ;


listComprehension :   '['  expr   '||' lcExprs ']' ;

binaryComprehension : '<<' binary '||' lcExprs '>>' ;

lcExprs : lcExpr (',' lcExpr)* ;

lcExpr : expr
       | expr   '<-' expr
       | binary '<=' expr
       ;

tuple : '{' exprs? '}' ;




recordExpr : exprMax?   '#' tokAtom ('.' tokAtom | recordTuple)
           | recordExpr '#' tokAtom ('.' tokAtom | recordTuple)
           ;

recordTuple : '{' recordFields? '}' ;

recordFields : recordField (',' recordField)* ;

recordField : (tokVar | tokAtom) '=' expr ;



functionCall : expr800 argumentList ;


ifExpr : 'if' ifClauses 'end' ;

ifClauses : ifClause (';' ifClause)* ;

ifClause : guard clauseBody ;


caseExpr : 'case' expr 'of' crClauses 'end' ;

crClauses : crClause (';' crClause)* ;

crClause : expr clauseGuard clauseBody ;


receiveExpr : 'receive' crClauses                         'end'
            | 'receive'           'after' expr clauseBody 'end'
            | 'receive' crClauses 'after' expr clauseBody 'end'
            ;


funExpr : 'fun' tokAtom '/' tokInteger
        | 'fun' atomOrVar ':' atomOrVar '/' integerOrVar
        | 'fun' funClauses 'end'
        ;

atomOrVar : tokAtom | tokVar ;

integerOrVar : tokInteger | tokVar ;


funClauses : funClause (';' funClause)* ;

funClause : argumentList clauseGuard clauseBody ;


tryExpr : 'try' exprs ('of' crClauses)? tryCatch ;

tryCatch : 'catch' tryClauses               'end'
         | 'catch' tryClauses 'after' exprs 'end'
         |                    'after' exprs 'end' ;

tryClauses : tryClause (';' tryClause)* ;

tryClause : (atomOrVar ':')? expr clauseGuard clauseBody ;



argumentList : '(' exprs? ')' ;

exprs : expr (',' expr)* ;

guard : exprs (';' exprs)* ;

atomic : tokChar
       | tokInteger
       | tokFloat
       | tokAtom
       | (tokString)+
       ;

prefixOp : '+'
         | '-'
         | 'bnot'
         | 'not'
         ;

multOp : '/'
       | '*'
       | 'div'
       | 'rem'
       | 'band'
       | 'and'
       ;

addOp : '+'
      | '-'
      | 'bor'
      | 'bxor'
      | 'bsl'
      | 'bsr'
      | 'or'
      | 'xor'
      ;

listOp : '++'
       | '--'
       ;

compOp : '=='
       | '/='
       | '=<'
       | '<'
       | '>='
       | '>'
       | '=:='
       | '=/='
       ;


ruleClauses : ruleClause (';' ruleClause)* ;

ruleClause : tokAtom clauseArgs clauseGuard ruleBody ;

ruleBody : ':-' lcExprs ;

