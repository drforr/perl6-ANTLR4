parser grammar ScssParser;

options { tokenVocab=ScssLexer; }

stylesheet
	: statement*
	;

statement
  : importDeclaration
  | nested
  | ruleset
  | mixinDeclaration
  | functionDeclaration
  | variableDeclaration
  | includeDeclaration
  | ifDeclaration
  | forDeclaration
  | whileDeclaration
  | eachDeclaration
  ;



params
  : param (COMMA param)* Ellipsis?
  ;

param
  : variableName paramOptionalValue?
  ;

variableName
  : DOLLAR Identifier
  ;

paramOptionalValue
  : COLON expression+
  ;


mixinDeclaration
  : '@mixin' Identifier (LPAREN params? RPAREN)? block
  ;

includeDeclaration
  : INCLUDE Identifier (';' | (LPAREN values? RPAREN ';'?)? block?)
  ;

functionDeclaration
  : '@function' Identifier LPAREN params? RPAREN BlockStart functionBody? BlockEnd
  ;

functionBody
  : functionStatement* functionReturn
  ;

functionReturn
  : '@return' commandStatement ';'
  ;

functionStatement
  : commandStatement ';' | statement
  ;


commandStatement
  : (expression+ | '(' commandStatement ')') mathStatement?
  ;

mathCharacter
  : TIMES | PLUS | DIV | MINUS | PERC
  ;

mathStatement
  : mathCharacter commandStatement
  ;


expression
  : measurement
  | identifier
  | Color
  | StringLiteral
  | NULL
  | url
	| variableName
	| functionCall
	;




ifDeclaration
  : AT_IF conditions block elseIfStatement* elseStatement?
  ;

elseIfStatement
  : AT_ELSE IF conditions block
  ;

elseStatement
  : AT_ELSE block
  ;

conditions
  : condition (COMBINE_COMPARE conditions)?
  | NULL
  ;

condition
  : commandStatement (( '==' | LT | GT | '!=') conditions)?
  | LPAREN conditions ')'
  ;

variableDeclaration
  : variableName COLON values '!default'? ';'
  ;


forDeclaration
  : AT_FOR variableName 'from' fromNumber 'through' throughNumber block
  ;

fromNumber
  : Number
  ;
throughNumber
  : Number
  ;

whileDeclaration
  : AT_WHILE conditions block
  ;

eachDeclaration
  : AT_EACH variableName (COMMA variableName)* IN eachValueList block
  ;

eachValueList
  :  Identifier (COMMA Identifier)*
  |  identifierListOrMap (COMMA identifierListOrMap)*
  ;

identifierListOrMap
  : LPAREN identifierValue (COMMA identifierValue)* RPAREN
  ;

identifierValue
  : identifier (COLON values)?
  ;


importDeclaration
	: '@import' referenceUrl mediaTypes? ';'
	;

referenceUrl
    : StringLiteral
    | UrlStart Url UrlEnd
    ;


mediaTypes
  : (Identifier (COMMA Identifier)*)
  ;




nested
 	: '@' nest selectors BlockStart stylesheet BlockEnd
	;

nest
	: (Identifier | '&') Identifier* pseudo*
	;





ruleset
 	: selectors block
	;

block
  : BlockStart (property ';' | statement)* property? BlockEnd
  ;

selectors
	: selector (COMMA selector)*
	;

selector
	: element+ (selectorPrefix element)* attrib* pseudo?
	;

selectorPrefix
  : (GT | PLUS | TIL)
  ;

element
	: identifier
  | '#' identifier
  | '.' identifier
  | '&'
  | '*'
	;

pseudo
	: (COLON|COLONCOLON) Identifier
	| (COLON|COLONCOLON) functionCall
	;

attrib
	: '[' Identifier (attribRelate (StringLiteral | Identifier))? ']'
	;

attribRelate
	: '='
	| '~='
	| '|='
	;

identifier
  : Identifier identifierPart*
  | InterpolationStart identifierVariableName BlockEnd identifierPart*
  ;

identifierPart
  : InterpolationStartAfter identifierVariableName BlockEnd
  | IdentifierAfter
  ;
identifierVariableName
  : DOLLAR (Identifier | IdentifierAfter)
  ;

property
	: identifier COLON values
	;

values
	: commandStatement (COMMA commandStatement)*
	;

url
  : UrlStart Url UrlEnd
  ;

measurement
  : Number Unit?
  ;


functionCall
	: Identifier LPAREN values? RPAREN
	;
