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

	sub ANTLR-to-range( $from, $to ) {
		CharacterRange.new(
			:from( escape-character-class( $from ) ),
			:to( escape-character-class( $to ) )
		)
	}

	sub escape-character-class( *@chars ) {
		map {
			my $copy = $_;
			$copy ~~ s:g/\\u(....)/\\x[$0]/;
			if %character-class-escape{$copy} {
				$copy = %character-class-escape{$copy};
			}
			$copy;
		}, @chars
	}

	sub ANTLR-to-perl6( *@str ) {
		map {
			my $copy = $_;
			$copy ~~ s:g/\\u(....)/\\x[$0]/;
			$copy ~~ s:g/<!after \\>\'/\\\'/;
			$copy;
		}, @str
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
		make CharacterSet.new(
			:content( ANTLR-to-range( $/<from>.ast, $/<to>.ast ) )
		)
	}

	method setElementAltList( $/ ) {
		my @content;
		for $/<setElement> {
			if $_.<LEXER_CHAR_SET> {
				for $_.<LEXER_CHAR_SET> {
					for $_ {
						@content.append(
							Character.new(
								:name( ~$_ )
							)
						)
					}
				}
			}
			else {
				@content.append(
					Character.new(
						:name(
							$_.<terminal><scalar>.ast
						)
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
						ANTLR-to-char-range( ~$_ )
					)
				}
				elsif ~$_ {
					@content.append( Character.new( :name( $_ ) ) )
				}
			}
		}
		make CharacterSet.new(
			:negated( True ),
			:content( @content )
		)
	}

	method notSet( $/ ) {
		if $/<setElement><LEXER_CHAR_SET> {
			make $/<setElement>.ast
		}
		elsif $/<blockSet> {
			make $/<blockSet>.ast
		}
		else {
			my @content = Character.new(
				:name( $/<setElement><terminal><scalar>.ast )
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
		my $greed = $/<ebnfSuffix><GREED>.ast // False;
		if $/<labeledElement> {
			make Nonterminal.new(
				:modifier( $modifier ),
				:greed( $greed ),
				:name( $/<labeledElement><atom><terminal><scalar>.ast ),
				:alias( $/<labeledElement><ID>.ast )
			)
		}
		elsif $/<ACTION> {
			make $/<ACTION>.ast
		}
		elsif $/<ebnfSuffix> and
			$/<atom><terminal><scalar> and
			!is-ANTLR-terminal( ~$/<atom><terminal><scalar> ) and
			$/<atom><terminal><scalar>.ast eq 'EOF' {
			make EOF.new(
				:modifier( $modifier ),
				:greed( $greed ),
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
		elsif $/<ebnfSuffix> and
			$/<atom><DOT> {
			make Wildcard.new(
				:modifier( $modifier ),
				:greed( $greed )
			)
		}
		elsif $/<ebnfSuffix> and
			$/<atom><notSet><blockSet> {
			my @content =
				Character.new(
					:name(
				# XXX can improve
$/<atom><notSet><blockSet><setElementAltList><setElement>[0]<terminal><STRING_LITERAL>.ast
					)
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
				if $_ {
					if is-ANTLR-range( ~$_ ) {
# XXX fix later
						@content.append(
							ANTLR-to-char-range( ~$_ )
						)
					}
					elsif ~$_ {
						@content.append( Character.new( :name( $_ ) ) )
					}
				}
			}
			make CharacterSet.new(
				:negated( True ),
				:modifier( $modifier ),
				:greed( $greed ),
				:content( @content )
			)
		}
		elsif $/<ebnfSuffix> and
			$/<atom><notSet><setElement><terminal><scalar> and
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
			$/<atom><notSet><setElement><terminal> {
			my @content =
				Character.new(
					:name(
				# XXX can improve
$/<atom><notSet><setElement><terminal><STRING_LITERAL>.ast
					)
				);
			make CharacterSet.new(
				:negated( True ),
				:modifier( $modifier ),
				:greed( $greed ),
				:content( @content )
			)
		}
		elsif $/<ebnfSuffix> and
			$/<atom><range>.ast {
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
			# XXX The // '' should probably go away...
			make Grouping.new(
				:modifier(
					$/<ebnf><ebnfSuffix><MODIFIER>.ast // ''
				),
				:greed(
					$/<ebnf><ebnfSuffix><GREED>.ast // False
				),
				:content(
					Alternation.new(
						:content( $/<ebnf>.ast )
					)
				)
			)
		}
		elsif $/<atom> {
			make $/<atom>.ast
		}
	}

	method parserElement( $/ ) {
		if $/<element>[0]<atom><range> and
			$/<element>[0]<ebnfSuffix> {
			make CharacterSet.new(
				:modifier(
					 $/<element>[0]<ebnfSuffix><MODIFIER>.ast
				),
				:greed(
					$/<element>[0]<ebnfSuffix><GREED>.ast // False
				),
				:content(
					ANTLR-to-range(
						$/<element>[0]<atom><range><from>.ast,
						$/<element>[0]<atom><range><to>.ast
					);
				)
			)
		}
		elsif $/<element>[0]<atom><notSet> and
			$/<element>[1]<atom><DOT> and
			$/<element>[2]<atom><DOT> {
			make CharacterSet.new(
				:modifier(
					$/<element>[3]<ebnfSuffix><MODIFIER>.ast // ''
				),
				:greed(
					$/<element>[3]<ebnfSuffix><GREED>.ast // False
				),
				:negated( True ),
				:content(
					ANTLR-to-range(
						$/<element>[0]<atom><notSet><setElement><terminal><scalar>.ast,
						$/<element>[3]<atom><terminal><scalar>.ast
					)
				)
			)
		}
		elsif $/<element> {
			make Concatenation.new( :content( $/<element>>>.ast ) )
		}
	}

	method parserAlt( $/ ) {
		make $/<parserElement>.ast
	}

	# XXX Turn these into ANTLR-to-range() calls.
	sub ANTLR-to-char-range( $str ) {
		my ( $from, $to ) = $str.split( '-' );
		return CharacterRange.new(
			:from(
				escape-character-class(
					$from
				)
			),
			:to(
				escape-character-class(
					$to
				)
			)
		)
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
			if is-ANTLR-range( ~$_ ) {
				@content.append(
					ANTLR-to-char-range( ~$_ )
				)
			}
			else {
				@content.append(
					Character.new(
						:name(
$_.<LEXER_CHAR_SET_RANGE>.ast
						)
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
							Character.new(
								:name(
~$_.<LEXER_CHAR_SET_RANGE>
								)
							)
						)
					}
				}
				else {
					@content.append(
						Character.new(
							:name(
$_.<lexerElement>[0]<lexerAtom><terminal><scalar>.ast
							)
						)
					);
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
		my $greed = $/<ebnfSuffix><GREED> // False;

		if $/<ebnfSuffix> and $/<lexerAtom><terminal><scalar> and
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
		elsif $/<ebnfSuffix> and
			$/<lexerAtom><LEXER_CHAR_SET> and
$/<lexerAtom><LEXER_CHAR_SET>[0][0]<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT_NO_HYPHEN> {
			make CharacterSet.new(
				:modifier( $modifier ),
				:greed( $greed ),
				:content(
					ANTLR-to-range(
~$/<lexerAtom><LEXER_CHAR_SET>[0][0]<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT_NO_HYPHEN>,
~$/<lexerAtom><LEXER_CHAR_SET>[0][0]<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT>
					)
				)
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
		elsif $/<ebnfSuffix> and $/<lexerAtom><terminal><STRING_LITERAL> {
			make Terminal.new(
				:modifier( $modifier ),
				:greed( $greed ),
				:name(
					ANTLR-to-perl6(
						$/<lexerAtom><terminal><STRING_LITERAL>.ast
					)
				)
			)
		}
		elsif $/<ebnfSuffix> and $/<lexerAtom>[0] {
			make Wildcard.new(
				:modifier( $modifier ),
				:greed( $greed )
			)
		}
		elsif $/<ebnfSuffix> and $/<lexerAtom><LEXER_CHAR_SET> {
			my @content =
				Character.new(
					:name(
						escape-character-class(
							$/<lexerAtom><LEXER_CHAR_SET>>>.Str
						)
					)
				);
			make CharacterSet.new(
				:modifier( $modifier ),
				:greed( $greed ),
				:content( @content )
			)
		}
# XXX Add test for this
		elsif $/<ebnfSuffix> and $/<lexerAtom><notSet><setElement><terminal> {
			my @content =
				escape-character-class(
					ANTLR-to-perl6( 
$/<lexerAtom><notSet><setElement><terminal><STRING_LITERAL>.ast
					)
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
					ANTLR-to-perl6(
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
					ANTLR-to-perl6(
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
		elsif $/<lexerBlock> {
			make $/<lexerBlock>.ast
		}
		elsif $/<lexerAtom>[0] {
			make Wildcard.new
		}
		elsif $/<ACTION> {
			if $/<GREED> {
				make Action.new(
					:name( ~$/<ACTION> ),
					:greed( True )
				)
			}
			else {
				make $/<ACTION>.ast
			}
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
