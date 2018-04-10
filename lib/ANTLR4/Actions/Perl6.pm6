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

	has @.child;
	has $.negated = False;
}

class Alternation { has @.child; }

class Concatenation { has @.child; }

class Block {
	also does Named;

	has @.child;
}

class Grouping {
	also does Modified;

	has @.child;
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
		if $/<ID> and $/<scalar>.ast eq 'EOF' {
			make EOF.new
		}
		elsif $/<ID> {
			make Nonterminal.new( :name( $/<scalar>.ast ) )
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
		my @child = ANTLR-to-range(
			$/<from>.ast, $/<to>.ast
		);
		make CharacterSet.new(
			:child( @child )
		)
	}

	method setElementAltList( $/ ) {
		my @child;
		for $/<setElement> {
			if $_.<LEXER_CHAR_SET> {
				for $_.<LEXER_CHAR_SET> {
					for $_ {
						@child.append(
							ANTLR-to-character(
								~$_ 
							)
						)
					}
				}
			}
			elsif $_.<terminal> {
				@child.append(
					ANTLR-to-character(
						$_.<terminal><scalar>.ast
					)
				)
			}
		}
		make CharacterSet.new(
			:negated( True ),
			:child( @child )
		)
	}

	method blockSet( $/ ) {
		make $/<setElementAltList>.ast
	}

	method setElement( $/ ) {
		my @child;
		for $/<LEXER_CHAR_SET>[0] {
			# XXX fix later
			next unless $_;
			if $_.<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT_NO_HYPHEN> {
				@child.append(
ANTLR-to-range(
~$_<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT_NO_HYPHEN>,
~$_<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT>
)
				)
			}
			else {
				@child.append(
					ANTLR-to-character( $_ )
				)
			}
		}
		make CharacterSet.new(
			:negated( True ),
			:child( @child )
		)
	}

	method notSet( $/ ) {
		if $/<complement> and
			$/<setElement><terminal><scalar> and
			!is-ANTLR-terminal( $/<setElement><terminal><scalar> ) {
			make Nonterminal.new(
				:negated( True ),
				:name( ~$/<setElement><terminal><scalar> )
			)
		}
		elsif $/<setElement> {
			make $/<setElement>.ast
		}
		elsif $/<blockSet> {
			make $/<blockSet>.ast
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
			my @child = ANTLR-to-character(
				# XXX can improve
$/<atom><notSet><blockSet><setElementAltList><setElement>[0]<terminal><STRING_LITERAL>.ast
			);
			make CharacterSet.new(
				:negated( True ),
				:modifier( $modifier ),
				:greed( $greed ),
				:child( @child )
			)
		}
		elsif $/<ebnfSuffix> and
			$/<atom><notSet><setElement><LEXER_CHAR_SET> {
			my @child;
			for $/<atom><notSet><setElement><LEXER_CHAR_SET> {
				if $_[0]<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT_NO_HYPHEN> {
					@child.append(
ANTLR-to-range(
	~$_[0]<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT_NO_HYPHEN>,
	~$_[0]<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT>
)
					)
				}
				elsif ~$_ {
					@child.append(
						ANTLR-to-character( $_ )
					)
				}
			}
			make CharacterSet.new(
				:negated( True ),
				:modifier( $modifier ),
				:greed( $greed ),
				:child( @child )
			)
		}
		elsif $/<atom><notSet><setElement><terminal> {
			my @child = ANTLR-to-character(
				# XXX can improve
$/<atom><notSet><setElement><terminal><STRING_LITERAL>.ast
			);
			make CharacterSet.new(
				:negated( True ),
				:modifier( $modifier ),
				:greed( $greed ),
				:child( @child )
			)
		}
		elsif $/<atom><range>.ast {
			my @child = ANTLR-to-range(
				~$/<atom><range><from>[0],
				~$/<atom><range><to>[0]
			);
			make CharacterSet.new(
				:modifier( $modifier ),
				:greed( $greed ),
				:child( @child )
			)
		}
		elsif $/<atom><DOT> {
			make Wildcard.new(
				:modifier( $modifier ),
				:greed( $greed )
			)
		}
		elsif $/<ACTION> {
			make $/<ACTION>.ast
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
			my @_child = $/<ebnf>.ast;
			my @child = Alternation.new(
				:child( @_child )
			);
			make Grouping.new(
				:modifier( $/<ebnf><ebnfSuffix><MODIFIER>.ast ),
				:greed( $/<ebnf><ebnfSuffix><GREED>.ast ),
				:child( @child )
			)
		}
		elsif $/<atom> {
			make $/<atom>.ast
		}
	}

	method parserElement( $/ ) {
		if $/<element>[0]<atom><range> and
			$/<element>[0]<ebnfSuffix> {
			my @child = ANTLR-to-range(
				$/<element>[0]<atom><range><from>.ast,
				$/<element>[0]<atom><range><to>.ast
			);
			make CharacterSet.new(
				:modifier(
					 $/<element>[0]<ebnfSuffix><MODIFIER>.ast
				),
				:greed( $/<element>[0]<ebnfSuffix><GREED>.ast ),
				:child( @child )
			)
		}
		elsif $/<element>[0]<atom><notSet> and
			$/<element>[1]<atom><DOT> and
			$/<element>[2]<atom><DOT> {
			my @child = ANTLR-to-range(
				$/<element>[0]<atom><notSet><setElement><terminal><scalar>.ast,
				$/<element>[3]<atom><terminal><scalar>.ast
			);
			make CharacterSet.new(
				:modifier(
					$/<element>[3]<ebnfSuffix><MODIFIER>.ast
				),
				:greed( $/<element>[3]<ebnfSuffix><GREED>.ast ),
				:negated( True ),
				:child( @child )
			)
		}
		elsif $/<element> {
			my @child = $/<element>>>.ast;
			make Concatenation.new(
				:child( @child )
			)
		}
	}

	method parserAlt( $/ ) {
		make $/<parserElement>.ast
	}

	method LEXER_CHAR_SET( $/ ) {
		my @child;
		for $/[0] {
			if $_<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT_NO_HYPHEN> {
				@child.append(
					ANTLR-to-range(
~$_<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT_NO_HYPHEN>,
~$_<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT>
					)
				)
			}
			elsif $_.<LEXER_CHAR_SET_RANGE>.ast {
				@child.append(
					ANTLR-to-character(
						$_.<LEXER_CHAR_SET_RANGE>.ast
					)
				)
			}
		}
		make CharacterSet.new(
			:child( @child )
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
			my @child;
			for $/<lexerAltList><lexerAlt> {
				if $_.<lexerElement>[0]<lexerAtom><range> {
					@child.append(
						ANTLR-to-range(
~$_.<lexerElement>[0]<lexerAtom><range><from>[0],
~$_.<lexerElement>[0]<lexerAtom><range><to>[0]
						)
					)
				}
				elsif $_.<lexerElement>[0]<lexerAtom><LEXER_CHAR_SET> {
					for $_.<lexerElement>[0]<lexerAtom><LEXER_CHAR_SET>[0] {
						@child.append(
							ANTLR-to-character(
~$_.<LEXER_CHAR_SET_RANGE>
							)
						)
					}
				}
				else {
					@child.append(
						ANTLR-to-character(
$_.<lexerElement>[0]<lexerAtom><terminal><scalar>.ast
						)
					)
				}
			}
			make CharacterSet.new(
				:negated( True ),
				:child( @child )
			)
		}
		else {
			my @child = $/<lexerAltList>.ast;
			make Grouping.new(
				:child( @child )
			)
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
			my @child = ANTLR-to-range(
~$/<lexerAtom><LEXER_CHAR_SET>[0][0]<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT_NO_HYPHEN>,
~$/<lexerAtom><LEXER_CHAR_SET>[0][0]<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT>
			);
			make CharacterSet.new(
				:modifier( $modifier ),
				:greed( $greed ),
				:child( @child )
			)
		}
		elsif $/<lexerAtom><LEXER_CHAR_SET> {
			my @child;
			for $/<lexerAtom><LEXER_CHAR_SET> {
				@child.append(
					ANTLR-to-character( ~$_ )
				)
			}
			make CharacterSet.new(
				:modifier( $modifier ),
				:greed( $greed ),
				:child( @child )
			)
		}
# XXX add regression
		elsif $/<lexerAtom><notSet><setElement><terminal> {
			my @child = ANTLR-to-character(
$/<lexerAtom><notSet><setElement><terminal><STRING_LITERAL>.ast
			);
			make CharacterSet.new(
				:negated( True ),
				:modifier( $modifier ),
				:greed( $greed ),
				:child( @child )
			)
		}
# XXX Add test for this
		elsif $/<ebnfSuffix> and $/<lexerAtom><notSet><setElement> {
			my @child;
			for $/<lexerAtom><notSet><setElement><LEXER_CHAR_SET>[0] {
				@child.append(
					ANTLR-to-character(
						$_.<LEXER_CHAR_SET_RANGE>.ast
					)
				)
			}
			make CharacterSet.new(
				:negated( True ),
				:modifier( $modifier ),
				:greed( $greed ),
				:child( @child )
			)
		}
# XXX Add test for this
		elsif $/<ebnfSuffix> and $/<lexerAtom><notSet> {
			my @child;
			for $/<lexerAtom><notSet><blockSet><setElementAltList><setElement> {
				@child.append(
					ANTLR-to-character(
$_.<terminal><STRING_LITERAL>.ast
					)
				)
			}
			make CharacterSet.new(
				:negated( True ),
				:modifier( $modifier ),
				:greed( $greed ),
				:child( @child )
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
		my @child = $/<lexerElement>>>.ast;
		make Concatenation.new(
			:child( @child )
		)
	}

	method parserAltList( $/ ) {
		my @child = $/<parserAlt>>>.ast;
		make Alternation.new(
			:child( @child )
		)
	}

	method lexerAltList( $/ ) {
		my @child = $/<lexerAlt>>>.ast;
		make Alternation.new(
			:child( @child )
		)
	}

	method parserRuleSpec( $/ ) {
		my @child = $/<parserAltList>.ast;
		make Rule.new(
			:name( $/<ID>.ast ),
			:child( @child )
		)
	}

	method lexerRuleSpec( $/ ) {
		my @child = $/<lexerAltList>.ast;
		make Rule.new(
			:name( $/<ID>.ast ),
			:child( @child )
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
