use v6;
#use Grammar::Tracer;
grammar ANTLR4::Grammar {

#
# Not currently acted upon
#
token BLANK_LINE
	{
	\s* \n
	}

#
# Not currently acted upon
#
token COMMENT
	{	'/*' .*? '*/'
	|	'//' \N*
	}

#
# Not currently acted upon
#
token COMMENTS
	{
	[<COMMENT> \s*]+
	}

#
# Not currently acted upon
#
token DIGIT
	{
	<[ 0..9 ]>
	}

token DIGITS
	{
	<DIGIT>+
	}

#  Allow unicode rule/token names

token ID
	{
	<NameStartChar> <NameChar>*
	}

token NameChar
	{	<NameStartChar>
	|	<DIGIT>
	|	'_'
	|	\x[00B7]
	|	<[ \x[0300]..\x[036F] ]>
	|	<[ \x[203F]..\x[2040] ]>
	}

token NameStartChar
	{	<[ A..Z ]>
	|	<[ a..z ]>
	|	<[ \x[00C0]..\x[00D6] ]>
	|	<[ \x[00D8]..\x[00F6] ]>
	|	<[ \x[00F8]..\x[02FF] ]>
	|	<[ \x[0370]..\x[037D] ]>
	|	<[ \x[037F]..\x[1FFF] ]>
	|	<[ \x[200C]..\x[200D] ]>
	|	<[ \x[2070]..\x[218F] ]>
	|	<[ \x[2C00]..\x[2FEF] ]>
	|	<[ \x[3001]..\x[D7FF] ]>
	|	<[ \x[F900]..\x[FDCF] ]>
	|	<[ \x[FDF0]..\x[FFFD] ]>
	} # ignores | ['\u10000-'\uEFFFF] ;

token STRING_LITERAL
	{
	'\''
	( :!sigspace [ '\\' <ESC_SEQ> | <-[ ' \r \n \\ ]> ]* )
	'\''
	}

token ESC_SEQ
	{	<[ b t n f r " ' \\ ]> 	# The standard escaped character set
	|	<UNICODE_ESC>		# A Java style Unicode escape sequence
	|	.			# Invalid escape
	|	$			# Invalid escape at end of file
	}

token UNICODE_ESC
	{
	'u' <HEX_DIGIT> ** {4}
	}

token HEX_DIGIT
	{
	<[ 0..9 a..f A..F ]>
	}

#  Many language targets use {} as block delimiters and so we
#  must recursively match {} delimited blocks to balance the
#  braces. Additionally, we must make some assumptions about
#  literal string representation in the target language. We assume
#  that they are delimited by ' or " and so consume these
#  in their own alts so as not to inadvertantly match {}.

token ACTION
	{
	'{'	[	<COMMENT>
		|	<ACTION>
		|	<ACTION_ESCAPE>
		|	<ACTION_STRING_LITERAL>
		|	<ACTION_CHAR_LITERAL>
		|	.
		]*?
	'}'
	}

token ACTION_ESCAPE
	{
	'\\' .
	}

token ACTION_STRING_LITERAL
	{
	'"' [<ACTION_ESCAPE> | <-[ " \\ ]>]* '"'
	}

token ACTION_CHAR_LITERAL
	{
	'\'' [<ACTION_ESCAPE> | <-[ ' \\ ]>]* '\''
	}

#
# mode ArgAction; # E.g., [int x, List<String> a[]]
# 
token ARG_ACTION
	{
	'[' <-[ \\ \x[5d]]>* ']'
	}

token LEXER_CHAR_SET_ELEMENT
	{	'\\' <-[ u ]>
	|	'\\' <UNICODE_ESC>
	|	<-[ \\ \x[5d] ]>
	}

token LEXER_CHAR_SET_ELEMENT_NO_HYPHEN
	{	'\\' <-[ u ]>
	|	'\\' <UNICODE_ESC>
	|	<-[ - \\ \x[5d] ]>
	}

token LEXER_CHAR_SET_RANGE
	{
	[<LEXER_CHAR_SET_ELEMENT_NO_HYPHEN> '-']? <LEXER_CHAR_SET_ELEMENT>
	}

token LEXER_CHAR_SET
	{
	'[' (<LEXER_CHAR_SET_RANGE> | <LEXER_CHAR_SET_ELEMENT>)* ']'
	}

#
#  The main entry point for parsing a v4 grammar.
# 
rule TOP 
	{
	<BLANK_LINE>*
	<type=grammarType> <name=ID> ';'
	<prequelConstruct>*
	<rules=ruleSpec>*
	<modeSpec>*
	}

rule grammarType
	{
	<COMMENTS>? ( :!sigspace 'lexer' | 'parser' )? <COMMENTS>? 'grammar'
	}

#  This is the list of all constructs that can be declared before
#  the set of rules that compose the grammar, and is invoked 0..n
#  times by the grammarPrequel rule.

rule prequelConstruct
 	{	<options=optionsSpec>
	|	<import=delegateGrammars>
	|	<tokens=tokensSpec>
	|	<actions=action>
 	}
 
#  A list of options that affect analysis and/or code generation

rule optionsSpec
	{
	'options' '{' <option>* '}'
	} 

rule option
	{
	<key=ID> '=' <optionValue> ';'
	}

rule ID_list
	{
	<ID>+ % ','
	}

#
# Strings, actions and digit strings are all just scalar types, so
# rename the term, and take advantage of homogeneity.
#
rule optionValue
 	{	<list=ID_list>
 	|	<scalar=STRING_LITERAL>
 	|	<scalar=ACTION>
 	|	<scalar=DIGITS>
 	}
 
rule delegateGrammars
 	{
	'import' <delegateGrammar>+ % ',' ';'
 	}
 
rule delegateGrammar
 	{
	<key=ID> ['=' <value=ID>]?
 	}
 
rule ID_list_trailing_comma
	{
	<ID>+ %% ','
	}

rule tokensSpec
 	{
	<COMMENTS>? 'tokens' '{' <ID_list_trailing_comma> '}'
 	}
 
#  Match stuff like @parser::members {int i;}

token action_name
 	{
	'@' ( :!sigspace <actionScopeName> '::')? <ID>
	}
 
rule action
 	{
	<action_name> <ACTION>
 	}
 
#  Sometimes the scope names will collide with keywords; allow them as
#  ids for action scopes.
 
token actionScopeName
 	{	<ID>
 	|	'lexer'
 	|	'parser'
 	}
 
rule modeSpec
 	{
	<COMMENTS>? 'mode' <ID> ';' <lexerRuleSpec>*
 	}
 
rule ruleSpec
 	{	<parserRuleSpec>
 	|	<lexerRuleSpec>
 	}

rule parserRuleSpec
 	{
	<COMMENTS>? <attribute=ruleAttribute>*
	<COMMENTS>? <name=ID>
	<COMMENTS>? <action=ARG_ACTION>?
	<COMMENTS>? <returns=ruleReturns>?
	<COMMENTS>? <throws=throwsSpec>?
	<COMMENTS>? <locals=localsSpec>?
	<COMMENTS>? <options=optionsSpec>? # XXX This was <optionsSpec>*
	':'
	<COMMENTS>? <parserAltList>
	';'
	<COMMENTS>? <exceptionGroup>
 	}
 
rule exceptionGroup
 	{
	<exceptionHandler>* <finallyClause>?
 	}
 
rule exceptionHandler
 	{
	'catch' <ARG_ACTION> <ACTION>
 	}
 
rule finallyClause
 	{
	'finally' <ACTION>
 	}
 
rule ruleReturns
 	{
	'returns' <ARG_ACTION>
 	}
 
rule throwsSpec
 	{
	'throws' <ID>+ % ','
 	}
 
rule localsSpec
 	{
	'locals' <ARG_ACTION>
 	}
 
#  An individual access modifier for a rule. The 'fragment' modifier
#  is an internal indication for lexer rules that they do not match
#  from the input but are like subroutines for other lexer rules to
#  reuse for certain lexical patterns. The other modifiers are passed
#  to the code generation templates and may be ignored by the template
#  if they are of no use in that language.
 
token ruleAttribute
 	{	'public'
 	|	'private'
 	|	'protected'
 	|	'fragment'
 	}
 
#
# ('a' | ) # Trailing empty alternative is allowed in sample code
#
rule parserAltList
	{
	<parserAlt>+ % '|'
	}
 
rule parserAlt
 	{
	<parserElement> <COMMENTS>? ['#' <label=ID> <COMMENTS>?]?
 	}
 
token FRAGMENT
	{
	'fragment'
	}
rule lexerRuleSpec
 	{
	<COMMENTS>? <FRAGMENT>?
 	<COMMENTS>? <name=ID>
	<COMMENTS>? ':'
	<COMMENTS>? <lexerAltList>
	<COMMENTS>? ';'
	<COMMENTS>?
 	}
 
rule lexerAltList
	{
	<lexerAlt>+ %% '|'
	}
 
rule lexerAlt
 	{
	<COMMENTS>? <lexerElement>+ <lexerCommands>? <COMMENTS>? | ''
 	}
 
rule lexerElement
 	{	<labeledLexerElement> <ebnfSuffix>?
 	|	<lexerAtom> <ebnfSuffix>?
 	|	<lexerBlock> <ebnfSuffix>?
 	|	<ACTION> '?'?
 	}
 
rule labeledLexerElement
 	{
	<ID> ['=' | '+=']
 		[	<lexerAtom>
 		|	<block>
 		]
 	}
 
rule lexerBlock
 	{
	'~'? '(' <COMMENTS>? <lexerAltList>? ')'
 	}
 
#  E.g., channel(HIDDEN), skip, more, mode(INSIDE), push(INSIDE), pop
 
rule lexerCommands
 	{
	'->' <lexerCommand>+ % ','
 	}

rule lexerCommand
	{
	<lexerCommandName=ID> <lexerCommandExpr>?
	}

rule lexerCommandExpr
	{
	'(' (<ID> | <DIGITS>) ')'
	}
 
rule blockAltList
	{
	<parserElement>+ % '|'
	}
 
rule parserElement
 	{
	<elementOptions>? <element>*
 	}
 
rule element
 	{	<labeledElement> <ebnfSuffix>?
 	|	<atom> <ebnfSuffix>?
 	|	<ebnf>
 	|	<ACTION> '?'? <COMMENTS>?
 	}
 
rule labeledElement
 	{
	<ID> ['=' | '+=']
 		[	<atom>
 		|	<block>
 		]
 	}
 
rule ebnf
	{
	<block> <ebnfSuffix>?
 	}

token MODIFIER
	{	'+'
	|	'*'
	|	'?'
	}

token GREED
	{
	'?'
	}
 
token ebnfSuffix
 	{
	<MODIFIER> <GREED>?
 	}
 
rule lexerAtom
 	{	<range>
 	|	<terminal>
 	|	<ID>
 	|	<notSet>
 	|	<LEXER_CHAR_SET>
 	|	'.' <elementOptions>?
 	}

token DOT
	{
	'.'
	}
 
rule atom
 	{	<range>
 	|	<terminal>
 	|	<ruleref>
 	|	<notSet>
 	|	<DOT> <elementOptions>?
 	}
 
rule notSet
 	{
	'~' [<setElement> | <blockSet>]
 	}
 
rule setElementAltList
	{
	<setElement>+ % '|'
	}

rule blockSet
	{
	'(' <setElementAltList> ')' <COMMENTS>?
	}
 
rule setElement
	{	<terminal>
 	|	<range>
 	|	<LEXER_CHAR_SET>
 	}
 
rule block
 	{
	'(' [ <optionsSpec>? ':' ]? <blockAltList> <COMMENTS>? ')'
	}
 
rule ruleref
 	{
	<ID> <ARG_ACTION>? <elementOptions>?
 	} 
rule range
	{
	<from=STRING_LITERAL> '..' <to=STRING_LITERAL>
 	}
 
rule terminal
	{
	[<scalar=ID> | <scalar=STRING_LITERAL>] <elementOptions>?
	}
 
rule elementOptions
 	{
	'<' <elementOption>+ % ',' '>'
 	}
 
rule elementOption
	{
	<key=ID> ['=' [<value=ID> | <value=STRING_LITERAL>] ]?
	}
}
 
# vim: ft=perl6
