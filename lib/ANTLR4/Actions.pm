=begin pod

=head1 ANTLR4::Actions

C<ANTLR4::Actions> encompasses the grammar actions needed to create a perl6 AST
from an ANTLR4 parser specification.

=head1 Synopsis

    use ANTLR4::Actions;
    use ANTLR4::Grammar;
    my $a = ANTLR4::Actions.new;
    my $g = ANTLR4::Grammar.new;

    say $g.parsefile('ECMAScript.g4', :actions($a) ).ast;

=head1 Documentation

The AST returns a hash reference consisting of the following keys:

  C<name> - The name of the grammar, derived from 'grammar ECMAScript;'

  C<type> - The type of the grammar, either 'lexer' or 'parser' as specified
            in the text, or '' if no type is specified.

  C<options> - An array reference of options specified in the grammar file.
               The most common option is 'tokenVocab', which would appear as
               C<options => [ tokenVocab => 'ECMAScriptLexer' ]>. I'm
               treating it as a list of pairs rather than a hash reference
               because order may be significant.

  C<import> - An array reference of grammar files the current grammar file
              imports. This module does not recursively import grammar files,
              at least not yet.

  C<tokens> - An array reference of token names predefined in other grammar
              files, such as the files in the C<import> array reference.
              Order shouldn't be important, but I've chosen an array reference
              to keep a consistent style.

  C<action> - An array reference consisting of the action performed by the
              top level of the grammar. It's just a reference to a single
              pair, even though the grammar doesn't seem to support multiple
              actions at the top level. Again, an array reference just for
              consistency's sake.

              I should point out that the value will remain completely unparsed
              even though there's a fairly complex grammar surrounding it.
              This is simply because it's Java code, and doing so would require
              a completely different embedded parser. I point out in passing
              that there's a Java and Java8 grammar in the corpus test
              directory, should anyone care to give it a whirl.

  C<rules> - This is the most complex part of the specification, of course.
             It's also where all the action happens. Order is probably not
             significant, but just for consistency's sake, it will remain an
             array reference of pairs.

Rules of course have a name and a body. In this case the key of the pair is
the rule's name, and the value is the rule's body. Naturally, the body is the
most complex part. Ignoring decorations such as channels and modes for the
moment, rules are collections of terms. These can be actual text to match,
such as C<'parser'>, or the names of other rules, such as C<grammarType>.

=end pod

use v6;
class ANTLR4::Actions;

method DIGITS($/)
	{
	make +$/.Str
	}

#method COMMENT($/)
#	{
#	make ~$/
#	}

#method COMMENTS($/)
#	{
#	make ~$/.join.ast
#	}

method ID($/)
	{
	make ~$/
	}

#method NameChar($/)
#	{
#	}

#method NameStartChar($/)
#	{
#	}

method STRING_LITERAL_GUTS($/)
	{
	make ~$/
	}
method STRING_LITERAL($/)
	{
	make $/<STRING_LITERAL_GUTS>.Str
	}

#method ESC_SEQ($/)
#	{
#	}

#method UNICODE_ESC($/)
#	{
#	}

#method ACTION($/)
#	{
#	}

#method ACTION_ESCAPE($/)
#	{
#	}

#method ACTION_STRING_LITERAL($/)
#	{
#	}

#method ACTION_CHAR_LITERAL($/)
#	{
#	}

#method ARG_ACTION($/)
#	{
#	}

method LEXER_CHAR_SET_RANGE($/)
	{
	make ~$/.Str
	}

method LEXER_CHAR_SET_ELEMENT($/)
	{
	make ~$/
	}

method LEXER_CHAR_SET($/)
	{
	make [ $/[0]>>.ast ]
	}

method grammarType($/)
	{
	make $/[0] ?? ~$/[0] !! Nil
	}

method TOP ($/)
	{
	my %content =
		(
		name    => $/<grammarName>.ast,
		type    => $/<grammarType>.ast || Nil,
		options => [ ],
		import  => [ ],
                tokens  => [ ],
                actions => [ ],
		rules   => [ $/<ruleSpec>>>.ast ],
		);

	for @( $/<prequelConstruct> ) -> $prequel
		{
		%content<options> =
			$prequel.<optionsSpec>.ast if
			$prequel.<optionsSpec>;
		%content<tokens> =
			$prequel.<tokensSpec>.ast if
			$prequel.<tokensSpec>;
		%content<import> =
			$prequel.<delegateGrammars>.ast if
			$prequel.<delegateGrammars>;
		push @( %content<actions> ),
			@( $prequel.<action>.ast ) if
			$prequel.<action>;
		}
	make %content
	}

method optionsSpec($/)
	{
	make [ $/<option>>>.ast ]
	}

method option($/)
	{
	make $/<ID>.ast => $/<optionValue>.ast
	}

method ID_list($/)
	{
	make [ $/<ID>>>.ast ]
	}

method ID_list_trailing_comma($/)
	{
	make [ $/<ID>>>.ast ]
	}

method optionValue($/)
	{
	#
	# XXX I'm fully aware this can be written better, but for now...
	#
	make
		$/<ID_list>
			?? $/<ID_list>.ast.list
			!! $/<STRING_LITERAL>
			?? $/<STRING_LITERAL>.ast
			!! $/<DIGITS>
			?? $/<DIGITS>.ast
			!! ''
	}
 
method delegateGrammars($/)
	{
	make [ $/<delegateGrammar>>>.ast ]
	}

method delegateGrammar($/)
	{
	make $/<key>.ast => $/<value> ?? $/<value>.ast !! Nil
	}

method tokensSpec($/)
	{
	make $/<ID_list_trailing_comma>.ast
	}

method action_name($/)
	{
	make ~$/
	}

method action($/)
	{
	make [ $/<action_name>.Str => $/<ACTION>.Str ]
	}

#method actionScopeName($/)
#	{
#	}

#method modeSpec($/)
#	{
#	}

method ruleSpec($/)
	{
	make $/<parserRuleSpec>.ast
	}

method parserRuleSpec($/)
	{
	make $/<ID>.ast => $/<ruleAltList>.ast
	}

#method exceptionGroup($/)
#	{
#	}

#method exceptionHandler($/)
#	{
#	}

#method finallyClause($/) {
#	}
# 
#method ruleReturns($/) {
#	}
# 
#method throwsSpec($/) {
#	}
# 
#method localsSpec($/) {
#	}
# 
#method ruleModifier($/) {
#	}

method ruleAltList($/)
	{
	make [ $/<labeledAlt>>>.ast ]
	}

method labeledAlt($/)
	{
        my $first_element = $/<alternative><element>[0];
#say $first_element;
#say $first_element.<atom><notSet><setElement><LEXER_CHAR_SET>[0];

	my $content =
		$first_element.<atom><notSet><setElement><LEXER_CHAR_SET>
		?? [ $first_element.<atom><notSet><setElement><LEXER_CHAR_SET>[0]>>.Str ]
		!! $first_element.<atom><terminal><STRING_LITERAL>
		?? $first_element.<atom><terminal><STRING_LITERAL>.ast
		!! $first_element.<atom><notSet><setElement><STRING_LITERAL><STRING_LITERAL_GUTS>.ast;
	my $type =
		$first_element.<atom><notSet><setElement><LEXER_CHAR_SET>
                ?? 'character class'
                !! 'terminal';
	my $modifier = $first_element.<ebnfSuffix>[0]
		?? $first_element.<ebnfSuffix>[0].Str
		!! Nil;
	my $greedy = $first_element.<ebnfSuffix>[1]
		?? True
		!! False;
	my $complemented = $first_element.<atom><notSet>
		?? True
		!! False;
	make
		[
		type         => $type,
		label        => $/<ID> ?? $/<ID>.ast !! Nil,
		content      => $content,
		modifier     => $modifier,
		greedy       => $greedy,
		complemented => $complemented
		]
	}
 
#method lexerRule($/)
#	{
#	}

#method lexerAltList($/)
#	{
#	}

#method lexerAlt($/)
#	{
#	}

#method lexerElement($/)
#	{
#	}

#method labeledLexerElement($/)
#	{
#	}

#method lexerBlock($/)
#	{
#	}

#method lexerCommands($/)
#	{
#	}

#method lexerCommand($/)
#	{
#	}

#method lexerCommandName($/)
#	{
#	}

#method lexerCommandExpr($/)
#	{
#	}

#method altList($/)
#	{
#	}

#method alternative($/)
#	{
#	}

method element($/)
	{
	}
 
#method labeledElement($/)
#	{
#	}

#method ebnf($/)
#	{
#	}

#method ebnfSuffix($/)
#	{
#	}

#method lexerAtom($/)
#	{
#	}

method atom($/)
	{
	}

#method notSet($/)
#	{
#	}

#method blockSet($/)
#	{
#	}

#method setElement($/)
#	{
#	}

#method block($/)
#	{
#	}

#method ruleref($/)
#	{
#	}

#method range($/)
#	{
#	}

#method terminal($/)
#	{
#	}

#method elementOptions($/)
#	{
#	}

#method elementOption($/)
#	{
#	}
 
# vim: ft=perl6
