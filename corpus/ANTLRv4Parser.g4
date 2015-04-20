parser grammar ANTLRv4Parser;

options {
	tokenVocab=ANTLRv4Lexer;
}

grammarSpec
	:	DOC_COMMENT?
		grammarType id SEMI
		prequelConstruct*
		rules
		modeSpec*
		EOF
	;

grammarType
	:	(	LEXER GRAMMAR
		|	PARSER GRAMMAR
		|	GRAMMAR
		)
	;

prequelConstruct
	:	optionsSpec
	|	delegateGrammars
	|	tokensSpec
	|	action
	;

optionsSpec
	:	OPTIONS (option SEMI)* RBRACE
	;

option
	:	id ASSIGN optionValue
	;

optionValue
	:	id (DOT id)*
	|	STRING_LITERAL
	|	ACTION
	|	INT
	;

delegateGrammars
	:	IMPORT delegateGrammar (COMMA delegateGrammar)* SEMI
	;

delegateGrammar
	:	id ASSIGN id
	|	id
	;

tokensSpec
	:	TOKENS id (COMMA id)* COMMA? RBRACE
	;

action
	:	AT (actionScopeName COLONCOLON)? id ACTION
	;

actionScopeName
	:	id
	|	LEXER
	|	PARSER
	;

modeSpec
	:	MODE id SEMI lexerRule*
	;

rules
	:	ruleSpec*
	;

ruleSpec
	:	parserRuleSpec
	|	lexerRule
	;

parserRuleSpec
	:	DOC_COMMENT?
        ruleModifiers? RULE_REF ARG_ACTION?
        ruleReturns? throwsSpec? localsSpec?
		rulePrequel*
		COLON
            ruleBlock
		SEMI
		exceptionGroup
	;

exceptionGroup
	:	exceptionHandler* finallyClause?
	;

exceptionHandler
	:	CATCH ARG_ACTION ACTION
	;

finallyClause
	:	FINALLY ACTION
	;

rulePrequel
	:	optionsSpec
	|	ruleAction
	;

ruleReturns
	:	RETURNS ARG_ACTION
	;

throwsSpec
	:	THROWS id (COMMA id)*
	;

localsSpec
	:	LOCALS ARG_ACTION
	;

ruleAction
	:	AT id ACTION
	;

ruleModifiers
	:	ruleModifier+
	;

ruleModifier
	:	PUBLIC
	|	PRIVATE
	|	PROTECTED
	|	FRAGMENT
	;

ruleBlock
	:	ruleAltList
	;

ruleAltList
	:	labeledAlt (OR labeledAlt)*
	;

labeledAlt
	:	alternative (POUND id)?
	;

lexerRule
	:	DOC_COMMENT? FRAGMENT?
		TOKEN_REF COLON lexerRuleBlock SEMI
	;

lexerRuleBlock
	:	lexerAltList
	;

lexerAltList
	:	lexerAlt (OR lexerAlt)*
	;

lexerAlt
	:	lexerElements lexerCommands?
	|
	;

lexerElements
	:	lexerElement+
	;

lexerElement
	:	labeledLexerElement ebnfSuffix?
	|	lexerAtom ebnfSuffix?
	|	lexerBlock ebnfSuffix?
	|	ACTION QUESTION? 
                         
	;

labeledLexerElement
	:	id (ASSIGN|PLUS_ASSIGN)
		(	lexerAtom
		|	block
		)
	;

lexerBlock
	:	LPAREN lexerAltList RPAREN
	;

lexerCommands
	:	RARROW lexerCommand (COMMA lexerCommand)*
	;

lexerCommand
	:	lexerCommandName LPAREN lexerCommandExpr RPAREN
	|	lexerCommandName
	;

lexerCommandName
	:	id
	|	MODE
	;

lexerCommandExpr
	:	id
	|	INT
	;

altList
	:	alternative (OR alternative)*
	;

alternative
	:	elementOptions? element*
	;

element
	:	labeledElement
		(	ebnfSuffix
		|
		)
	|	atom
		(	ebnfSuffix
		|
		)
	|	ebnf
	|	ACTION QUESTION? 
	;

labeledElement
	:	id (ASSIGN|PLUS_ASSIGN)
		(	atom
		|	block
		)
	;

ebnf:	block blockSuffix?
	;

blockSuffix
	:	ebnfSuffix 
	;

ebnfSuffix
	:	QUESTION QUESTION?
  	|	STAR QUESTION?
   	|	PLUS QUESTION?
	;

lexerAtom
	:	range
	|	terminal
	|	RULE_REF
	|	notSet
	|	LEXER_CHAR_SET
	|	DOT elementOptions?
	;

atom
	:	range 
	|	terminal
	|	ruleref
	|	notSet
	|	DOT elementOptions?
	;

notSet
	:	NOT setElement
	|	NOT blockSet
	;

blockSet
	:	LPAREN setElement (OR setElement)* RPAREN
	;

setElement
	:	TOKEN_REF elementOptions?
	|	STRING_LITERAL elementOptions?
	|	range
	|	LEXER_CHAR_SET
	;

block
	:	LPAREN
		( optionsSpec? ruleAction* COLON )?
		altList
		RPAREN
	;

ruleref
	:	RULE_REF ARG_ACTION? elementOptions?
	;

range
	: STRING_LITERAL RANGE STRING_LITERAL
	;

terminal
	:   TOKEN_REF elementOptions?
	|   STRING_LITERAL elementOptions?
	;

elementOptions
	:	LT elementOption (COMMA elementOption)* GT
	;

elementOption
	:	
		id
	|	
		id ASSIGN (id | STRING_LITERAL)
	;

id	:	RULE_REF
	|	TOKEN_REF
	;
