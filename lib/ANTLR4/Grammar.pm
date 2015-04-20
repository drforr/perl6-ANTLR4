use v6;
use Grammar::Tracer;
grammar ANTLR4::Grammar;

###############################################################################
# 

# XXX JMG These are used but not defined in the grammar.
# XXX JMG probably defined in code.
#
# tokens {
# 	TOKEN_REF,
# 	RULE_REF,
# 	LEXER_CHAR_SET
# }
token TOKEN_REF { <ID> } # XXX Look into this.
token RULE_REF { <ID> } # XXX Look into this.

# @members {
#   # Track whether we are inside of a rule and whether it is lexical parser.
#   # _currentRuleType==Token.INVALID_TYPE means that we are outside of a rule.
#   # At the first sign of a rule name reference and _currentRuleType==invalid,
#   # we can assume that we are starting a parser rule. Similarly, seeing
#   # a token reference when not already in rule means starting a token
#   # rule. The terminating ';' of a rule, flips this back to invalid type.
#   #
#   # This is not perfect logic but works. For example, "grammar T;" means
#   # that we start and stop a lexical rule for the "T;". Dangerous but works.
#   #
#   # The whole point of this state information is to distinguish
#   # between [..arg actions..] and [charsets]. Char sets can only occur in
#   # lexical rules and arg actions cannot occur.
#   #
#   private int _currentRuleType = Token.INVALID_TYPE;
#
#   public int getCurrentRuleType() {
#   	return _currentRuleType;
#   }
#
#   public void setCurrentRuleType(int ruleType) {
#   	this._currentRuleType = ruleType;
#   }
#
#   protected void handleBeginArgAction() {
#   	if (inLexerRule()) {
#   		pushMode(LexerCharSet);
#   		more();
#   	}
#   	else {
#   		pushMode(ArgAction);
#   		more();
#   	}
#   }
#
#   @Override
#   public Token emit() {
#   	if (_type == ID) {
#   		String firstChar = _input.getText(Interval.of(_tokenStartCharIndex, _tokenStartCharIndex));
#   		if (Character.isUpperCase(firstChar.charAt(0))) {
#   			_type = TOKEN_REF;
#   		} else {
#   			_type = RULE_REF;
#   		}
#
#   		if (_currentRuleType == Token.INVALID_TYPE) { # if outside of rule def
#   			_currentRuleType = _type;             # set to inside lexer or parser rule
#   		}
#   	}
#   	else if (_type == SEMI) {                  # exit rule def
#   		_currentRuleType = Token.INVALID_TYPE;
#   	}
#
#   	return super.emit();
#   }
#
#   private boolean inLexerRule() {
#   	return _currentRuleType == TOKEN_REF;
#   }
#   private boolean inParserRule() { # not used, but added for clarity
#   	return _currentRuleType == RULE_REF;
#   }
# }

rule DOC_COMMENT {
  '/*' .*? ['*/' | $]
}

# XXX JMG unused...?
token BLOCK_COMMENT {
  '/*' .*? ['*/' | $]
}

token LINE_COMMENT {
  '//' .* $$ #<-[\r\n]>*
}

# XXX JMG unused...?
token BEGIN_ARG_ACTION {
  '[' # XXX {handleBeginArgAction();}
}

# OPTIONS and TOKENS must also consume the opening brace that captures
# their option block, as this is the easiest way to parse it separate
# to an ACTION block, despite it using the same {} delimiters.

token OPTIONS { 'options' [' '|<[\t\f\n\r]>]* '{' }
token TOKENS  { 'tokens'  [' '|<[\t\f\n\r]>]* '{' }

#  Allow unicode rule/token names

token ID	{	<NameStartChar> <NameChar>* }

token NameChar
{   <NameStartChar>
|   <[0..9]>
|   '_'
|   \x[00B7]
|   <[\x[0300]..\x[036F]]>
|   <[\x[203F]..\x[2040]]>
}

token  NameStartChar
{   <[A..Z]>
|   <[a..z]>
|   <[\x[00C0]..\x[00D6]]>
|   <[\x[00D8]..\x[00F6]]>
|   <[\x[00F8]..\x[02FF]]>
|   <[\x[0370]..\x[037D]]>
|   <[\x[037F]..\x[1FFF]]>
|   <[\x[200C]..\x[200D]]>
|   <[\x[2070]..\x[218F]]>
|   <[\x[2C00]..\x[2FEF]]>
|   <[\x[3001]..\x[D7FF]]>
|   <[\x[F900]..\x[FDCF]]>
|   <[\x[FDF0]..\x[FFFD]]>
} # ignores | ['\u10000-'\uEFFFF] ;

token INT	{ <[0..9]>+ }

#  ANTLR makes no distinction between a single character literal and a
#  multi-character string. All literals are single quote delimited and
#  may contain unicode escape sequences of the form \uxxxx, where x
#  is a valid hexadecimal number (as per Java basically).

token STRING_LITERAL
{  '\'' [<ESC_SEQ> | <-['\r\n\\]>]* '\''
}

# XXX JMG Unused?
token UNTERMINATED_STRING_LITERAL
{  '\'' [<ESC_SEQ> | <-['\r\n\\]>]*
}

#  Any kind of escaped character that we can embed within ANTLR
#  literal strings.

token ESC_SEQ
{	'\\'
	[	# The standard escaped character set such as tab, newline, etc.
		<[btnfr"'\\]>
	|	# A Java style Unicode escape sequence
		<UNICODE_ESC>
	|	# Invalid escape
		.
	|	# Invalid escape at end of file
		$
	]
}

token UNICODE_ESC
{   'u' [<HEX_DIGIT> [<HEX_DIGIT> [<HEX_DIGIT> <HEX_DIGIT>?]?]?]?
}

token HEX_DIGIT { <[0..9a..fA..F]>	}

token WS  {	[' '|<[\t\r\n\f]>]+ }

#  Many language targets use {} as block delimiters and so we
#  must recursively match {} delimited blocks to balance the
#  braces. Additionally, we must make some assumptions about
#  literal string representation in the target language. We assume
#  that they are delimited by ' or " and so consume these
#  in their own alts so as not to inadvertantly match {}.

token ACTION
{	'{'
	[	<ACTION>
	|	<ACTION_ESCAPE>
	|	<ACTION_STRING_LITERAL>
	|	<ACTION_CHAR_LITERAL>
	|	'/*' .*? '*/' # ('*/' | $)
	|	<LINE_COMMENT> # was literal
	|	.
	]*?
#	['}'|$]
	'}'
}

token ACTION_ESCAPE
{   '\\' .
}

token ACTION_STRING_LITERAL
{	'"' [<ACTION_ESCAPE> | <-["\\]>]* '"'
}

token ACTION_CHAR_LITERAL
{	'\'' [<ACTION_ESCAPE> | <-['\\]>]* '\''
}

#  -----------------
#  Illegal Character
# 
#  This is an illegal character trap which is always the last rule in the
#  lexer specification. It matches a single character of any value and being
#  the last rule in the file will match when no other rule knows what to do
#  about the character. It is reported as an error but is not passed on to the
#  parser. This means that the parser to deal with the gramamr file anyway
#  but we will not try to analyse or code generate from a file with lexical
#  errors.

token ERRCHAR
{	.
}
#
# mode ArgAction; # E.g., [int x, List<String> a[]]
# 
token NESTED_ARG_ACTION
{	'['     #                    -> more, pushMode(ArgAction)
}

token ARG_ACTION_ESCAPE
{   '\\' .      #                -> more
}
 
token ARG_ACTION_STRING_LITERAL
{	['"' ['\\' . | <-["\\]>]* '"']#-> more
}
 
token ARG_ACTION_CHAR_LITERAL
{	['"' '\\' . | <-["\\]> '"'] # -> more
}
 
token ARG_ACTION
{   ']'  #                      -> popMode
}

token UNTERMINATED_ARG_ACTION # added this to return non-EOF token type here. EOF did something weird
{	$		#				-> popMode
}

token ARG_ACTION_CHAR # must be last
{   .                   #       -> more
}

# mode LexerCharSet;

token LEXER_CHAR_SET_BODY
{	[	<-[\]\\]>
	|	'\\' .
	]+
        #                 -> more
}

token LEXER_CHAR_SET
#{    ']' #                       -> popMode # XXX The original
{  '[' [ '\\' . | <-[ \\ \x[5d]]> ]* ']' } # XXX Prettify this if need be.

token UNTERMINATED_CHAR_SET
{	$	#					-> popMode
}

# options {
# 	tokenVocab=ANTLRv4Lexer;
# }

#  The main entry point for parsing a v4 grammar.
# 
rule TOP # grammarSpec
	{	<DOC_COMMENT>*
		<grammarType> <id> ';'
		<prequelConstruct>*
		<rules>
		<modeSpec>*
#		$
	}

rule grammarType
	{	'lexer' 'grammar'
	|	'parser' 'grammar'
	|	'grammar'
	}

#  This is the list of all constructs that can be declared before
#  the set of rules that compose the grammar, and is invoked 0..n
#  times by the grammarPrequel rule.

rule prequelConstruct
 	{	<optionsSpec>
 	|	<delegateGrammars>
 	|	<tokensSpec>
 	|	<action>
 	}
 
#  A list of options that affect analysis and/or code generation

rule optionsSpec
	{	<OPTIONS> [<option> ';']* '}'
	}

rule option
	{	<id> '=' <optionValue>
	}

rule optionValue
 	{	#<id> ['.' <id>]*
		<id>+ % ','
 	|	<STRING_LITERAL>
 	|	<ACTION>
 	|	<INT>
 	}
 
rule delegateGrammars
# 	{	'import' <delegateGrammar> [',' <delegateGrammar>]* ';'
# 	}
 	{	'import' <delegateGrammar>+ % ',' ';'
 	}
 
rule delegateGrammar
 	{	<id> '=' <id>
 	|	<id>
 	}
 
rule tokensSpec
# 	{	<TOKENS> <id> [',' <id>]* ','? '}'
# 	}
 	{	<TOKENS> <id>+ %% ',' '}'
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
 	{	'mode' <id> ';' <lexerRule>*
 	}
 
rule rules
 	{	<ruleSpec>*
 	}
 
rule ruleSpec
 	{	<parserRuleSpec>
 	|	<lexerRule>
 	}

rule parserRuleSpec
 	{	<DOC_COMMENT>?
		<LINE_COMMENT>* # XXX JMG addition
		<ruleModifiers>? <RULE_REF> <ARG_ACTION>?
		<ruleReturns>? <throwsSpec>? <localsSpec>?
		<rulePrequel>*
		':'
		<ruleBlock>
# 		';'
		';' <LINE_COMMENT>* # XXX This needs to be looked into.
		<exceptionGroup>
		<LINE_COMMENT>* # XXX Eating up more comments...
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
 
rule rulePrequel
 	{	<optionsSpec>
 	|	<ruleAction>
 	}
 
rule ruleReturns
 	{	'returns' <ARG_ACTION>
 	}
 
rule throwsSpec
# 	{	'throws' <id> [',' <id>]*
# 	}
 	{	'throws' <id>+ % ','
 	}
 
rule localsSpec
 	{	'locals' <ARG_ACTION>
 	}
 
#  Match stuff like @init {int i;}
 
rule ruleAction
 	{	'@' <id> <ACTION>
 	}
 
rule ruleModifiers
 	{	<ruleModifier>+
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
 
rule ruleBlock
 	{	<ruleAltList>
 	}
 
rule ruleAltList
# 	{	<labeledAlt> ['|' <labeledAlt>]*
# 	}
	{	<labeledAlt>+ % '|'
	}
 
rule labeledAlt
 	{	<alternative> ['#' <id>]?
 	}
 
rule lexerRule
 	{	<DOC_COMMENT>? 'fragment'?
		<LINE_COMMENT>*
 		<TOKEN_REF> ':' <lexerRuleBlock> ';'
 	}
 
rule lexerRuleBlock
 	{	<lexerAltList>
 	}
 
rule lexerAltList
# 	{	<lexerAlt> ['|' <lexerAlt>]*
# 	}
	{	<lexerAlt>+ % '|'
	}
 
rule lexerAlt
 	{	<lexerElements> <lexerCommands>?
# 	| 'XXX' # Suppress null regex warning
 	}
 
rule lexerElements
 	{	<lexerElement>+
 	}
 
rule lexerElement
 	{	<labeledLexerElement> <ebnfSuffix>?
 	|	<lexerAtom> <ebnfSuffix>?
 	|	<lexerBlock> <ebnfSuffix>?
 	|	<ACTION> '?'? # actions only allowed at end of outer alt actually,
                          # but preds can be anywhere
 	}
 
rule labeledLexerElement
 	{	<id> ['='|'+=']
 		[	<lexerAtom>
 		|	<block>
 		]
 	}
 
rule lexerBlock
 	{	'(' <lexerAltList> ')'
 	}
 
#  E.g., channel(HIDDEN), skip, more, mode(INSIDE), push(INSIDE), pop
 
rule lexerCommands
# 	{	'->' <lexerCommand> [',' <lexerCommand>]*
# 	}
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
# 	{	<alternative> ['|' <alternative>]*
# 	}
	{	<alternative>+ % '|'
	}
 
rule alternative
 	{	<elementOptions>? <element>*
 	}
 
rule element
 	{	<labeledElement>
		<ebnfSuffix>?
 		#[	<ebnfSuffix>
 		#| 'XXX' # XXX Suppress null warning
 		#]
 	|	<atom>
		<ebnfSuffix>?
 		#[	<ebnfSuffix>
 		#| 'XXX' # XXX Suppress null warning
 		#]
 	|	<ebnf>
 	|	<ACTION> '?'? # SEMPRED is ACTION followed by QUESTION
 	}
 
rule labeledElement
 	{	<id> ['='|'+=']
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
 	|	<RULE_REF>
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
 	{	'~' <setElement>
 	|	'~' <blockSet>
 	}
 
rule blockSet
# 	{	'(' <setElement> ['|' <setElement>]* ')'
# 	}
	{	'(' <setElement>+ % '|' ')'
	}
 
rule setElement
 	{	<TOKEN_REF> <elementOptions>?
 	|	<STRING_LITERAL> <elementOptions>?
 	|	<range>
 	|	<LEXER_CHAR_SET>
 	}
 
rule block
 	{	'('
 		[ <optionsSpec>? <ruleAction>* ':' ]?
 		<altList>
 		')'
 	}
 
rule ruleref
 	{	<RULE_REF> <ARG_ACTION>? <elementOptions>?
 	}
 
rule range
 	{ <STRING_LITERAL> '..' <STRING_LITERAL>
 	}
 
rule terminal
 	{   <TOKEN_REF> <elementOptions>?
 	|   <STRING_LITERAL> <elementOptions>?
 	}
 
#  Terminals may be adorned with certain options when
#  reference in the grammar: TOK<,,,>
 
rule elementOptions
# 	{	'<' <elementOption> [',' <elementOption>]* '>'
# 	}
 	{	'<' <elementOption>+ % ',' '>'
 	}
 
rule elementOption
 	{	# This format indicates the default node option
 		<id>
 	|	# This format indicates option assignment
 		<id> '=' [<id> | <STRING_LITERAL>]
 	}
 
rule id	{	<RULE_REF>
 	|	<TOKEN_REF>
 	}
 
# vim: ft=perl6
