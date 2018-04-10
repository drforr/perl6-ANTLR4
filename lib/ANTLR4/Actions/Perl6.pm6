=begin pod

=head1 ANTLR4::Actions::Perl6

C<ANTLR4::Actions::Perl6> generates a perl6 representation of an ANTLR4 AST.

=head1 Synopsis

    use ANTLR4::Actions::Perl6;
    use ANTLR4::Grammar;
    my $p = ANTLR4::Actions::Perl6.new;

    say $p.parse('grammar Minimal { identifier : [A-Z][A-Za-z]+ ; }', :actions($p)).ast;
    say $p.parsefile('ECMAScript.g4', :actions($p)).ast;

=head1 Documentation

The action in this file will return a string containing a rough Perl 6
translation of the ANTLR4 grammar that the module has been given to parse.

=end pod

use v6;

my role Named { has $.name; }
my role Modified {
	has $.modifier = '';
	has $.greed = False;
}

class Action {
	also does Named;
	also does Modified;
}

class Terminal {
	also does Named;
	also does Modified;
}

class Wildcard { also does Modified; }

class EOF { also does Modified; }

class Nonterminal {
	also does Named;
	also does Modified;

	has $.negated = False;
	has $.alias;
}

class CharacterRange {
	has $.from;
	has $.to;
}

class Character {
	also does Named;
}

class CharacterSet {
	also does Modified;

	has @.content;
	has $.negated = False;
}

class Alternation { has @.content; }

class Concatenation { has @.content; }

class Block {
	also does Named;

	has @.content;
}

class Grouping {
	also does Modified;

	has @.content;
}

class Token is Block { }

class Rule is Block { }

# This doesn't use the generic Block because it'll eventually be indented,
# and the grammar level is always the top level of the file.
#
class Grammar {
	also does Named;

	has $.type;
	has %.option;
	has %.import;
	has %.action;
	has @.token;
	has @.rule;
}

class ANTLR4::Actions::Perl6 {
	my %character-class-escape =
		' ' => True,
		']' => True,
		'-' => True
	;

	sub ANTLR-to-perl6( $c is copy ) {
		$c ~~ s:g/\\u(<[ 0 .. 9 a .. f A .. F ]> ** {4..6})/\\x[$0]/;
		$c ~~ s:g/<!after \\>\'/\\\'/;
		$c;
	}

	sub ANTLR-to-character( $c is copy ) {
		Character.new(
			:name( ANTLR-to-perl6( $c ) )
		)
	}

	sub ANTLR-to-range( $from, $to ) {
		CharacterRange.new(
			:from( escape-character-class( $from ) ),
			:to( escape-character-class( $to ) )
		)
	}

	sub escape-character-class( $c is copy ) {
		$c ~~ s:g/\\u(<[ 0 .. 9 a .. f A .. F ]> ** {4..6})/\\x[$0]/;
		$c ~~ s:g/<!after \\>\'/\\\'/;
		$c = %character-class-escape{$c}
			if %character-class-escape{$c};
		$c;
	}

	method ID( $/ ) { make ~$/ }
	method STRING_LITERAL( $/ ) { make ~$/[0] }
	method LEXER_CHAR_SET_RANGE( $/ ) { make ~$/ }
	method MODIFIER( $/ ) { make ~$/ }
	method GREED( $/ ) { make ?( ~$/ eq '?' ) }

	method tokenName( $/ ) {
		make Token.new( :name( $/<ID>.ast ) )
	}

	method token_list_trailing_comma( $/ ) {
		make $/<tokenName>>>.ast
	}

	method tokensSpec( $/ ) {
		make $/<token_list_trailing_comma>.ast
	}

	#method prequelConstruct - gave up temporarily on using tat.
	# I'll make that work later.

	# A lovely quirk of the ANTLR grammar is that nonterminals are actually
	# just a variant of the terminal, because ANTLR internally divides
	# lexer and parser grammars, and lexers can't have parser terms
	# so it's not notated separately.
	#
	method terminal( $/ ) {
		if $/<ID> {
			if $/<scalar>.ast eq 'EOF' {
				make EOF.new
			}
			else {
				make Nonterminal.new( :name( $/<scalar>.ast ) )
			}
		}
		else {
			make Terminal.new(
				:name( ANTLR-to-perl6( $/<scalar>.ast ) )
			)
		}
	}

	# Keep in mind that there is no 'from' rule, so even though here we
	# reference 'STRING_LITERAL' by its alias, the actual method that
	# gets called is STRING_LITERAL.
	#
	method range( $/ ) {
		my @content = ANTLR-to-range(
			$/<from>.ast, $/<to>.ast
		);
		make CharacterSet.new(
			:content( @content )
		)
	}

	method setElementAltList( $/ ) {
		my @content;
		for $/<setElement> {
			if $_.<LEXER_CHAR_SET> {
				for $_.<LEXER_CHAR_SET> {
					for $_ {
						@content.append(
							ANTLR-to-character(
								~$_ 
							)
						)
					}
				}
			}
			else {
				@content.append(
					ANTLR-to-character(
						$_.<terminal><scalar>.ast
					)
				)
			}
		}
		make CharacterSet.new(
			:negated( True ),
			:content( @content )
		)
	}

	method blockSet( $/ ) {
		make $/<setElementAltList>.ast
	}

	method setElement( $/ ) {
		my @content;
		for $/<LEXER_CHAR_SET>[0] {
			# XXX fix later
			if $_ {
				if is-ANTLR-range( ~$_ ) {
					@content.append(
ANTLR-to-range(
	~$_<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT_NO_HYPHEN>,
	~$_<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT>
)
					)
				}
				elsif ~$_ {
					@content.append(
						ANTLR-to-character( $_ )
					)
				}
			}
		}
		make CharacterSet.new(
			:negated( True ),
			:content( @content )
		)
	}

	method notSet( $/ ) {
		if $/<complement> and $/<setElement><terminal><scalar> and
			!is-ANTLR-terminal( $/<setElement><terminal><scalar> ) {
			make Nonterminal.new(
				:negated( True ),
				:name( ~$/<setElement><terminal><scalar> )
			)
		}
		elsif $/<setElement><LEXER_CHAR_SET> {
			make $/<setElement>.ast
		}
		elsif $/<blockSet> {
			make $/<blockSet>.ast
		}
		else {
			my @content = ANTLR-to-character(
				$/<setElement><terminal><scalar>.ast
			);
			make CharacterSet.new(
				:negated( True ),
				:content( @content )
			)
		}
	}

	method DOT( $/ ) {
		make Wildcard.new;
	}

	method atom( $/ ) {
		make $/<notSet>.ast //
			$/<DOT>.ast //
			$/<range>.ast //
			$/<terminal>.ast
	}

	method blockAltList( $/ ) {
		make $/<parserElement>>>.ast
	}

	method block( $/ ) {
		make $/<blockAltList>.ast
	}

	method ebnf( $/ ) {
		make $/<block>.ast
	}

	sub is-ANTLR-terminal( $str ) {
		$str ~~ / ^ \' /;
	}

	method ACTION( $/ ) {
		make Action.new( :name( ~$/ ) )
	}

	method element( $/ ) {
		my $modifier = $/<ebnfSuffix><MODIFIER>.ast;
		my $greed = $/<ebnfSuffix><GREED>.ast;
		if $/<labeledElement> {
			make Nonterminal.new(
				:modifier( $modifier ),
				:greed( $greed ),
				:name( $/<labeledElement><atom><terminal><scalar>.ast ),
				:alias( $/<labeledElement><ID>.ast )
			)
		}
		elsif $/<ebnfSuffix> and
			$/<atom><terminal><scalar> and
			!is-ANTLR-terminal( ~$/<atom><terminal><scalar> ) { 
			make Nonterminal.new(
				:modifier( $modifier ),
				:greed( $greed ),
				:name( $/<atom><terminal><scalar>.ast )
			)
		}
		elsif $/<atom><notSet><setElement><terminal><scalar> and
			!is-ANTLR-terminal( $/<atom><notSet><setElement><terminal><scalar> ) {
			make Nonterminal.new(
				:negated( True ),
				:modifier( $modifier ),
				:greed( $greed ),
				# XXX can improve
				:name(
$/<atom><notSet><setElement><terminal><scalar>.ast
				)
			)
		}
		elsif $/<ebnfSuffix> and
			$/<atom><notSet><blockSet> {
			my @content = ANTLR-to-character(
				# XXX can improve
$/<atom><notSet><blockSet><setElementAltList><setElement>[0]<terminal><STRING_LITERAL>.ast
			);
			make CharacterSet.new(
				:negated( True ),
				:modifier( $modifier ),
				:greed( $greed ),
				:content( @content )
			)
		}
		elsif $/<ebnfSuffix> and
			$/<atom><notSet><setElement><LEXER_CHAR_SET> {
			my @content;
			for $/<atom><notSet><setElement><LEXER_CHAR_SET> {
				if $_[0]<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT_NO_HYPHEN> {
					@content.append(
ANTLR-to-range(
	~$_[0]<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT_NO_HYPHEN>,
	~$_[0]<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT>
)
					)
				}
				elsif ~$_ {
					@content.append(
						ANTLR-to-character( $_ )
					)
				}
			}
			make CharacterSet.new(
				:negated( True ),
				:modifier( $modifier ),
				:greed( $greed ),
				:content( @content )
			)
		}
		elsif $/<atom><notSet><setElement><terminal> {
			my @content;
			@content = ANTLR-to-character(
				# XXX can improve
$/<atom><notSet><setElement><terminal><STRING_LITERAL>.ast
			);
			make CharacterSet.new(
				:negated( True ),
				:modifier( $modifier ),
				:greed( $greed ),
				:content( @content )
			)
		}
		elsif $/<atom><range>.ast {
			my @content = ANTLR-to-range(
				~$/<atom><range><from>[0],
				~$/<atom><range><to>[0]
			);
			make CharacterSet.new(
				:modifier( $modifier ),
				:greed( $greed ),
				:content( @content )
			)
		}
		elsif $/<ACTION> {
			make $/<ACTION>.ast
		}
		elsif $/<atom><DOT> {
			make Wildcard.new(
				:modifier( $modifier ),
				:greed( $greed )
			)
		}
		elsif $/<ebnfSuffix> and
			$/<atom>.ast {
			make Terminal.new(
				:modifier( $modifier ),
				:greed( $greed ),
				:name(
					ANTLR-to-perl6(
						$/<atom><terminal><scalar>.ast
					)
				)
			)
		}
		elsif $/<ebnf> {
			my @content =
				Alternation.new(
					:content( $/<ebnf>.ast )
				);
			make Grouping.new(
				:modifier( $/<ebnf><ebnfSuffix><MODIFIER>.ast ),
				:greed( $/<ebnf><ebnfSuffix><GREED>.ast ),
				:content( @content )
			)
		}
		elsif $/<atom> {
			make $/<atom>.ast
		}
	}

	method parserElement( $/ ) {
		if $/<element>[0]<atom><range> and
			$/<element>[0]<ebnfSuffix> {
			my @content =
				ANTLR-to-range(
					$/<element>[0]<atom><range><from>.ast,
					$/<element>[0]<atom><range><to>.ast
				);
			make CharacterSet.new(
				:modifier(
					 $/<element>[0]<ebnfSuffix><MODIFIER>.ast
				),
				:greed( $/<element>[0]<ebnfSuffix><GREED>.ast ),
				:content( @content )
			)
		}
		elsif $/<element>[0]<atom><notSet> and
			$/<element>[1]<atom><DOT> and
			$/<element>[2]<atom><DOT> {
			my @content =
				ANTLR-to-range(
					$/<element>[0]<atom><notSet><setElement><terminal><scalar>.ast,
					$/<element>[3]<atom><terminal><scalar>.ast
				);
			make CharacterSet.new(
				:modifier(
					$/<element>[3]<ebnfSuffix><MODIFIER>.ast
				),
				:greed( $/<element>[3]<ebnfSuffix><GREED>.ast ),
				:negated( True ),
				:content( @content )
			)
		}
		elsif $/<element> {
			make Concatenation.new( :content( $/<element>>>.ast ) )
		}
	}

	method parserAlt( $/ ) {
		make $/<parserElement>.ast
	}

	sub is-ANTLR-range( $str ) {
		if $str {
			return $str ~~ / . \- /
		}
		return False
	}

	method LEXER_CHAR_SET( $/ ) {
		my @content;
		for $/[0] {
			if $_<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT_NO_HYPHEN> {
				@content.append(
					ANTLR-to-range(
~$_<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT_NO_HYPHEN>,
~$_<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT>
					)
				)
			}
			elsif $_.<LEXER_CHAR_SET_RANGE>.ast {
				@content.append(
					ANTLR-to-character(
						$_.<LEXER_CHAR_SET_RANGE>.ast
					)
				)
			}
		}
		make CharacterSet.new(
			:content( @content )
		)
	}

	method lexerAtom( $/ ) {
		make $/<LEXER_CHAR_SET>.ast //
			$/<terminal>.ast //
			$/<notSet>.ast //
			$/<range>.ast
	}

	method lexerBlock( $/ ) {
		if $/<complement> {
			my @content;
			for $/<lexerAltList><lexerAlt> {
				if $_.<lexerElement>[0]<lexerAtom><range> {
					@content.append(
						ANTLR-to-range(
~$_.<lexerElement>[0]<lexerAtom><range><from>[0],
~$_.<lexerElement>[0]<lexerAtom><range><to>[0]
						)
					)
				}
				elsif $_.<lexerElement>[0]<lexerAtom><LEXER_CHAR_SET> {
					for $_.<lexerElement>[0]<lexerAtom><LEXER_CHAR_SET>[0] {
						@content.append(
							ANTLR-to-character(
~$_.<LEXER_CHAR_SET_RANGE>
							)
						)
					}
				}
				else {
					@content.append(
						ANTLR-to-character(
$_.<lexerElement>[0]<lexerAtom><terminal><scalar>.ast
						)
					)
				}
			}
			make CharacterSet.new(
				:negated( True ),
				:content( @content )
			)
		}
		else {
			make Grouping.new( :content( $/<lexerAltList>.ast ) )
		}
	}

	method lexerElement( $/ ) {
		my $modifier = $/<ebnfSuffix><MODIFIER>.ast;
		my $greed = $/<ebnfSuffix><GREED>;

		if $/<lexerAtom><terminal><scalar> and
			is-ANTLR-terminal( $/<lexerAtom><terminal><scalar> ) and
( !$/<lexerAtom><LEXER_CHAR_SET>[0][0]<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT_NO_HYPHEN> ) {
			make Terminal.new(
				:modifier( $modifier ),
				:greed( $greed ),
				:name(
					ANTLR-to-perl6(
						$/<lexerAtom><terminal><scalar>.ast
					)
				)
			)
		}
		elsif $/<lexerAtom><LEXER_CHAR_SET> and
$/<lexerAtom><LEXER_CHAR_SET>[0][0]<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT_NO_HYPHEN> {
			my @content =
				ANTLR-to-range(
~$/<lexerAtom><LEXER_CHAR_SET>[0][0]<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT_NO_HYPHEN>,
~$/<lexerAtom><LEXER_CHAR_SET>[0][0]<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT>
				);
			make CharacterSet.new(
				:modifier( $modifier ),
				:greed( $greed ),
				:content( @content )
			)
		}
		elsif $/<lexerAtom><LEXER_CHAR_SET> {
			my @content;
			for $/<lexerAtom><LEXER_CHAR_SET> {
				@content.append(
					ANTLR-to-character( ~$_ )
				)
			}
			make CharacterSet.new(
				:modifier( $modifier ),
				:greed( $greed ),
				:content( @content )
			)
		}
# XXX add regression
		elsif $/<lexerAtom><notSet><setElement><terminal> {
			my @content = ANTLR-to-character(
$/<lexerAtom><notSet><setElement><terminal><STRING_LITERAL>.ast
			);
			make CharacterSet.new(
				:negated( True ),
				:modifier( $modifier ),
				:greed( $greed ),
				:content( @content )
			)
		}
# XXX Add test for this
		elsif $/<ebnfSuffix> and $/<lexerAtom><notSet><setElement> {
			my @content;
			for $/<lexerAtom><notSet><setElement><LEXER_CHAR_SET>[0] {
				@content.append(
					ANTLR-to-character(
						$_.<LEXER_CHAR_SET_RANGE>.ast
					)
				)
			}
			make CharacterSet.new(
				:negated( True ),
				:modifier( $modifier ),
				:greed( $greed ),
				:content( @content )
			)
		}
# XXX Add test for this
		elsif $/<ebnfSuffix> and $/<lexerAtom><notSet> {
			my @content;
			for $/<lexerAtom><notSet><blockSet><setElementAltList><setElement> {
				@content.append(
					ANTLR-to-character(
$_.<terminal><STRING_LITERAL>.ast
					)
				)
			}
			make CharacterSet.new(
				:negated( True ),
				:modifier( $modifier ),
				:greed( $greed ),
				:content( @content )
			)
		}
		elsif $/<ebnfSuffix> and
			$/<lexerAtom><terminal><scalar> and
			!is-ANTLR-terminal( $/<lexerAtom><terminal><scalar> ) {
			make Nonterminal.new(
				:modifier( $modifier ),
				:greed( $greed ),
				:name(
					ANTLR-to-perl6(
						$/<lexerAtom><terminal><scalar>.ast
					)
				)
			)
		}
		elsif $/<lexerBlock> {
			make $/<lexerBlock>.ast
		}
		elsif $/<lexerAtom>[0] {
			make Wildcard.new(
				:modifier( $modifier ),
				:greed( $greed )
			)
		}
		# XXX Making a tradeoff here.
		# XXX One way to fix this is to create a new term for
		# XXX <ACTION> <GREED>?
		# XXX which lets us create a separate method that does
		# XXX <GreedyAction> or something.
		# XXX
		# XXX But that would mean I'd end up doing that for
		# XXX other combinations, exponents explode, oh the humanity.
		# XXX
		# XXX Can't add <GREED>? to the <ACTION> token because it's
		# XXX recursive.
		# XXX
		elsif $/<ACTION> {
			# XXX I'd love to make this simply collect
			# XXX $/<ACTION>.ast, but the <GREED> match is
			# XXX at the same damn level.
			# XXX
			make Action.new(
				:name( ~$/<ACTION> ),
				:greed( ?$/<GREED> )
			)
		}
		else {
			make $/<lexerAtom>.ast
		}
	}

	method lexerAlt( $/ ) {
		make Concatenation.new( :content( $/<lexerElement>>>.ast ) )
	}

	method parserAltList( $/ ) {
		make Alternation.new( :content( $/<parserAlt>>>.ast ) )
	}

	method lexerAltList( $/ ) {
		make Alternation.new( :content( $/<lexerAlt>>>.ast ) )
	}

	method parserRuleSpec( $/ ) {
		make Rule.new(
			:name( $/<ID>.ast ),
			:content( $/<parserAltList>.ast )
		)
	}

	method lexerRuleSpec( $/ ) {
		make Rule.new(
			:name( $/<ID>.ast ),
			:content( $/<lexerAltList>.ast )
		)
	}

	method ruleSpec( $/ ) {
		make $/<parserRuleSpec>.ast //
			$/<lexerRuleSpec>.ast
	}

	method TOP( $/ ) {
		my @token;
		my %option;
		my %action;
		my %import;
		for $/<prequelConstruct> {
			when $_.<optionsSpec> {
				for $_.<optionsSpec><option> {
					%option{ $_.<ID>.ast } =
						~$_.<optionValue>;
				}
			}
			when $_.<delegateGrammars> {
				for $_.<delegateGrammars><delegateGrammar> {
					%import{ ~$_.<key> } = 
						( $_.<value> ?? ~$_.<value> !! Any );
				}
			}
			when $_.<tokensSpec> {
				@token.append( $_.<tokensSpec>.ast );
			}
			when $_.<action> {
				%action{ ~$_.<action><action_name> } =
					~$_.<action><ACTION>;
			}
		}
		my $type;
		if $/<grammarType>[0] {
			$type = ~$/<grammarType>[0];
		}
		my $grammar = Grammar.new(
			:type( $type ),
			:name( $/<ID>.ast ),
			:option( %option ),
			:import( %import ),
			:action( %action ),
			:token( @token ),
			:rule( $/<ruleSpec>>>.ast )
		);
		make $grammar
	}
}

# vim: ft=perl6
