use v6;
#use Grammar::Tracer;
grammar ANTLR4::Grammar;

token COMMENT
	{	'/*' .*? '*/'
	|	'//' \N*
	}

token COMMENTS
	{	[<COMMENT> \s* ]+
	}

#  Allow unicode rule/token names

token ID
	{	<NameStartChar> <NameChar>*
	}

token NameChar
	{	<NameStartChar>
	|	<[ 0..9 ]>
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

token INT
	{	<[ 0..9 ]>+
	}

#  ANTLR makes no distinction between a single character literal and a
#  multi-character string. All literals are single quote delimited and
#  may contain unicode escape sequences of the form \uxxxx, where x
#  is a valid hexadecimal number (as per Java basically).

token STRING_LITERAL
	{	'\'' [<ESC_SEQ> | <-[ ' \r \n \\ ]>]* '\''
	}

#  Any kind of escaped character that we can embed within ANTLR
#  literal strings.

token ESC_SEQ
	{	'\\'
		[	# The standard escaped character set
			<[ b t n f r " ' \\ ]>
		|	# A Java style Unicode escape sequence
			<UNICODE_ESC>
		|	# Invalid escape
			.
		|	# Invalid escape at end of file
			$
		]
	}

token UNICODE_ESC
	{	'u'
		[ <HEX_DIGIT> [ <HEX_DIGIT> [ <HEX_DIGIT> <HEX_DIGIT> ?]? ]? ]?
	}

token HEX_DIGIT
	{	<[ 0..9 a..f A..F ]>
	}

#  Many language targets use {} as block delimiters and so we
#  must recursively match {} delimited blocks to balance the
#  braces. Additionally, we must make some assumptions about
#  literal string representation in the target language. We assume
#  that they are delimited by ' or " and so consume these
#  in their own alts so as not to inadvertantly match {}.

token ACTION
	{	'{'	[	<ACTION>
			|	<ACTION_ESCAPE>
			|	<ACTION_STRING_LITERAL>
			|	<ACTION_CHAR_LITERAL>
			|	.
			]*?
		'}'
	}

token ACTION_ESCAPE
	{	'\\' .
	}

token ACTION_STRING_LITERAL
	{	'"' [<ACTION_ESCAPE> | <-[ " \\ ]>]* '"'
	}

token ACTION_CHAR_LITERAL
	{	'\'' [<ACTION_ESCAPE> | <-[ ' \\ ]>]* '\''
	}

#
# mode ArgAction; # E.g., [int x, List<String> a[]]
# 
token ARG_ACTION
	{	'[' <-[ \\ \x[5d]]>* ']' # XXX need to be fixed
	}

token LEXER_CHAR_SET
{	'[' ['\\' . | <-[ \\ \x[5d]]>]* ']' # XXX Prettify this if need be.
}

#
#  The main entry point for parsing a v4 grammar.
# 
rule TOP 
	{	\N* # XXX Not the most elegant way of handling this.
		<grammarType> <id> ';'
		<prequelConstruct>*
		<ruleSpec>*
		<modeSpec>*
	}

rule grammarType
	{	<COMMENTS>? ['lexer' | 'parser']? 'grammar'
	}

#  This is the list of all constructs that can be declared before
#  the set of rules that compose the grammar, and is invoked 0..n
#  times by the grammarPrequel rule.

rule prequelConstruct
 	{	[	<optionsSpec>
		|	<delegateGrammars>
		|	<tokensSpec>
		|	<action>
		]
 	}
 
#  A list of options that affect analysis and/or code generation

rule optionsSpec
	{	'options' '{' [<option> ';']* '}'
	}

rule option
	{	<id> '=' <optionValue>
	}

rule optionValue
 	{	<id>+ % ','
 	|	<STRING_LITERAL>
 	|	<ACTION>
 	|	<INT>
 	}
 
rule delegateGrammars
 	{	'import' <delegateGrammar>+ % ',' ';'
 	}
 
rule delegateGrammar
 	{	<id> ['=' <id>]?
 	}
 
rule tokensSpec
 	{	<COMMENTS>? 'tokens' '{' <id>+ %% ',' '}'
 	}
 
#  Match stuff like @parser::members {int i;}
 
rule action
 	{	'@' [<actionScopeName> '::']? <id> <ACTION>
 	}
 
#  Sometimes the scope names will collide with keywords; allow them as
#  ids for action scopes.
 
rule actionScopeName
 	{	<id>
 	|	'lexer'
 	|	'parser'
 	}
 
rule modeSpec
 	{	<COMMENTS>? 'mode' <id> ';' <lexerRule>*
 	}
 
rule ruleSpec
 	{	<parserRuleSpec>
 	|	<lexerRule>
 	}

rule parserRuleSpec
 	{	<COMMENTS>? <ruleModifier>* <ID> <ARG_ACTION>?
		<ruleReturns>? <throwsSpec>? <localsSpec>?
		<optionsSpec>*
		':'
		<ruleAltList>
		';'
		<COMMENTS>?
		<exceptionGroup>
 	}
 
rule exceptionGroup
 	{	<exceptionHandler>* <finallyClause>?
 	}
 
rule exceptionHandler
 	{	'catch' <ARG_ACTION> <ACTION>
 	}
 
rule finallyClause
 	{	'finally' <ACTION>
 	}
 
rule ruleReturns
 	{	'returns' <ARG_ACTION>
 	}
 
rule throwsSpec
 	{	'throws' <id>+ % ','
 	}
 
rule localsSpec
 	{	'locals' <ARG_ACTION>
 	}
 
#  An individual access modifier for a rule. The 'fragment' modifier
#  is an internal indication for lexer rules that they do not match
#  from the input but are like subroutines for other lexer rules to
#  reuse for certain lexical patterns. The other modifiers are passed
#  to the code generation templates and may be ignored by the template
#  if they are of no use in that language.
 
rule ruleModifier
 	{	'public'
 	|	'private'
 	|	'protected'
 	|	'fragment'
 	}
 
#
# ('a' | ) # Trailing empty alternative is allowed in sample code
#
rule ruleAltList
	{	<labeledAlt>+ % '|'
	}
 
rule labeledAlt
 	{	<alternative> <COMMENTS>? ['#' <id> <COMMENTS>?]?
 	}
 
rule lexerRule
 	{	<COMMENTS>? 'fragment'?
 		<COMMENTS>? <ID> <COMMENTS>? ':' <lexerAltList> ';' <COMMENTS>?
 	}
 
#
# XXX The null alternative here is fugly.
#
rule lexerAltList
	{	[ [<COMMENTS>? <lexerAlt> <COMMENTS>?] | '' ]+ %% '|'
	}
 
rule lexerAlt
 	{	<lexerElement>+ <lexerCommands>?
 	}
 
rule lexerElement
 	{	<labeledLexerElement> <ebnfSuffix>?
 	|	<lexerAtom> <ebnfSuffix>?
 	|	<lexerBlock> <ebnfSuffix>?
		# actions only allowed at end of outer alt actually,
 	|	<ACTION> '?'?
                          # but preds can be anywhere
 	}
 
rule labeledLexerElement
 	{	<id> ['=' | '+=']
 		[	<lexerAtom>
 		|	<block>
 		]
 	}
 
rule lexerBlock
 	{	'~'? '(' <COMMENTS>? <lexerAltList>? ')'  # XXX Make lexerAltList optional
 	}
 
#  E.g., channel(HIDDEN), skip, more, mode(INSIDE), push(INSIDE), pop
 
rule lexerCommands
 	{	'->' <lexerCommand>+ % ','
 	}
 
rule lexerCommand
 	{	<lexerCommandName> '(' <lexerCommandExpr> ')'
 	|	<lexerCommandName>
 	}
 
rule lexerCommandName
 	{	<id>
 	|	'mode'
 	}
 
rule lexerCommandExpr
 	{	<id>
 	|	<INT>
 	}
 
rule altList
	{	<alternative>+ % '|'
	}
 
rule alternative
 	{	<elementOptions>? <element>*
 	}
 
rule element
 	{	<labeledElement> <ebnfSuffix>?
 	|	<atom> <ebnfSuffix>?
 	|	<ebnf>
 	|	<ACTION> '?'? # SEMPRED is ACTION followed by QUESTION
 	}
 
rule labeledElement
 	{	<id> ['=' | '+=']
 		[	<atom>
 		|	<block>
 		]
 	}
 
rule ebnf
	{	<block> <blockSuffix>?
 	}
 
rule blockSuffix
 	{	<ebnfSuffix> # Standard EBNF
 	}
 
rule ebnfSuffix
 	{	'?' '?'?
   	|	'*' '?'?
    	|	'+' '?'?
 	}
 
rule lexerAtom
 	{	<range>
 	|	<terminal>
 	|	<ID>
 	|	<notSet>
 	|	<LEXER_CHAR_SET>
 	|	'.' <elementOptions>?
 	}
 
rule atom
 	{	<range> # Range x..y - only valid in lexers
 	|	<terminal>
 	|	<ruleref>
 	|	<notSet>
 	|	'.' <elementOptions>?
 	}
 
rule notSet
 	{	'~' [<setElement> | <blockSet>]
 	}
 
rule blockSet
	{	'(' <setElement>+ % '|' ')' <COMMENTS>?
	}
 
rule setElement
 	{	<ID> <elementOptions>?
 	|	<STRING_LITERAL> <elementOptions>?
 	|	<range>
 	|	<LEXER_CHAR_SET>
 	}
 
rule block
 	{	'(' [ <optionsSpec>? ':' ]? <altList> ')'
 	}
 
rule ruleref
 	{	<ID> <ARG_ACTION>? <elementOptions>?
 	}
 
rule range
 	{	<STRING_LITERAL> '..' <STRING_LITERAL>
 	}
 
rule terminal
 	{	<ID> <elementOptions>?
 	|	<STRING_LITERAL> <elementOptions>?
 	}
 
#  Terminals may be adorned with certain options when
#  reference in the grammar: TOK<,,,>
 
rule elementOptions
 	{	'<' <elementOption>+ % ',' '>'
 	}
 
#
# XXX Switched the order of terms here
#
rule elementOption
 	{	# This format indicates option assignment
 		<id> '=' [<id> | <STRING_LITERAL>]
 	|	# This format indicates the default node option
 		<id>
 	}
 
rule id	{	<ID>
 	|	<ID>
 	}
 
# vim: ft=perl6
