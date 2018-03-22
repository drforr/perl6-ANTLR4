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
use JSON::Tiny;
use ANTLR4::Grammar;

my role Indenting {
	method indent-line( $line ) {
		if $line {
			return "\t" ~ $line
		}
		return ''
	}
	method indent( *@lines ) {
		map { self.indent-line( $_ ) }, grep { /\S/ }, @lines
	}
}

my role Named { has $.name; }
my role Modified {
	has $.modifier = '';
	has $.greed = '';
}

class Terminal {
	also does Named;
	also does Modified;

	method to-lines {
		my $name = $.name ~~ / <-[ a ..z A .. Z ]> / ??
			qq{'$.name'} !!
			$.name;	
		return $name ~ $.modifier ~ $.greed
	}
}

class Wildcard {
	also does Modified;

	method to-lines { return "." ~ $.modifier ~ $.greed }
}

class Nonterminal {
	also does Named;
	also does Modified;

	method to-lines { return "<$.name>" ~ $.modifier ~ $.greed }
}

class Range {
	also does Modified;

	has $.from;
	has $.to;
	has $.negated;

	method to-lines {
		my $negated = $.negated ?? '-' !! '';
		"<{$negated}[ $.from .. $.to ]>" ~ $.modifier ~ $.greed
	}
}

class CharacterSet {
	also does Modified;

	has @.content;
	has $.negated;

	method to-lines {
		my @content;
		for @.content {
			if /(.)\-(.)/ {
				@content.append( qq{$0 .. $1} );
			}
			else {
				@content.append( $_ );
			}
		}
		my $negated = $.negated ?? '-' !! '';
		"<{$negated}[ {@.content} ]>" ~ $.modifier ~ $.greed
	}
}

class Alternation {
	also does Indenting;

	has @.content;

	method to-lines {
		my @content;
		for @.content {
			my @lines = self.indent( $_.to-lines );
			if @lines {
				@lines[0] = '||' ~ @lines[0];
				@content.append( @lines );
			}
		}
		@content.flat
	}
}

class Concatenation {
	has @.content;

	method to-lines {
		my @content;
		for @.content {
			@content.append( $_.to-lines );
		}
		@content
	}
}

class Block {
	also does Named;
	also does Indenting;

	has $.type = '';
	has @.content;

	method to-lines {
		my @content;
		for @.content {
			@content.append( $_.to-lines );
		}
		return (
			"$.type $.name \{",
			self.indent( @content ),
			"\}"
		).flat
	}
}

class Grouping is Block {
	also does Modified;

	method to-lines {
		my @content;
		for @.content {
			@content.append( $_.to-lines );
		}
		return (
			"\(" ~ self.indent-line( @content.shift ),
			self.indent( @content ),
			"\)" ~ $.modifier ~ $.greed
		).flat
	}
}

# Though it's true that Tokens don't use any of the Block mechanisms, I'll
# leave it as a subclass because of its X { Y } nature.
#
# Actually @.content should be set as a submethod, I suppose.
# That would make hte relationship clearer. Something for later...
#
class Token is Block {
	method to-lines {
		my $lc-name = lc( $.name );
		return (
			"token $.name \{",
			self.indent-line(
				'||' ~ self.indent-line( "'$lc-name'" )
			),
			"\}"
		).flat
	}
}

class Rule is Block { has $.type = 'rule'; }

class Notes {
	has %.content;

	sub to-json-comment( $ast, @key ) {
		my $json;
		for @key -> $key {
			$json.{$key} = $ast.{$key} if $ast.{$key};
		}
		if $json {
			my $json-str = to-json( $json );
			return qq<#|$json-str>;
		}
		return '';
	}
}

# This doesn't use the generic Block because it'll eventually be indented,
# and the grammar level is always the top level of the file.
#
class Grammar {
	also does Named;
	also does Indenting;

	has @.content;

	method to-lines {
		my @content;
		for @.content {
			@content.append( $_.to-lines );
		}
		return (
			"grammar $.name \{",
			self.indent( @content ),
			"\}"
		).flat
	}

	method to-string {
		self.to-lines.join( "\n" ) ~ "\n"
	}
}

class ANTLR4::Actions::Perl6 {
	method ID( $/ ) { make ~$/ }
	method STRING_LITERAL( $/ ) { make ~$/[0] }
	method LEXER_CHAR_SET( $/ ) { make ~$/[0] }
	method MODIFIER( $/ ) { make ~$/ }
	method GREED( $/ ) { make ~$/ }

	method tokenName( $/ ) {
		make Token.new( :name( $/<ID>.ast ) )
	}

	method token_list_trailing_comma( $/ ) {
		make $/<tokenName>>>.ast
	}

	method tokensSpec( $/ ) {
		make $/<token_list_trailing_comma>.ast
	}

	method prequelConstruct( $/ ) {
		my @tokens;
		for $/ {
			when $_.<tokensSpec> {
				@tokens.append( $_.<tokensSpec>.ast );
			}
		}
		make @tokens
	}

	# XXX The 'if $copy' shouldn't be needed because Terminals with empty
	# XXX names shouldn't ever be created.
	sub ANTLR-to-perl( $str ) {
		if $str {
			my $copy = $str;
			$copy ~~ s:g/\\u(....)/\\x[$0]/;
			$copy ~~ s:g/<!after \\>\'/\\\'/;
			$copy;
		}
		else {
			$str;
		}
	}

	# A lovely quirk of the ANTLR grammar is that nonterminals are actually
	# just a variant of the terminal, because ANTLR internally divides
	# lexer and parser grammars, and lexers can't have parser terms
	# so it's not notated separately.
	#
	method terminal( $/ ) {
		if $/<ID> {
			make Nonterminal.new( :name( $/<scalar>.ast ) )
		}
		else {
			make Terminal.new(
				:name(
					ANTLR-to-perl( $/<scalar>.ast )
				)
			)
		}
	}

	# Keep in mind that there is no 'from' rule, so even though here we
	# reference 'STRING_LITERAL' by its alias, the actual method that
	# gets called is STRING_LITERAL.
	#
	method range( $/ ) {
		make Range.new(
			:from( ANTLR-to-perl( $/<from>.ast ) ),
			:to( ANTLR-to-perl( $/<to>.ast ) )
		)
	}

	method blockSet( $/ ) {
		my @content;
		for $/<setElementAltList><setElement> {
			@content.append( $_.<terminal><scalar>.ast )
		}
		make CharacterSet.new(
			:negated( True ),
			:content( @content )
		)
	}

	method setElement( $/ ) {
		my @content;
		for $/<LEXER_CHAR_SET> {
			@content.append( $_ )
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
			make CharacterSet.new(
				:negated( True ),
				:content(
					$/<setElement><terminal><scalar>.ast
				)
			)
		}
	}

	method atom( $/ ) {
		if $/<notSet> {
			make $/<notSet>.ast
		}
		elsif $/<DOT> {
			make Wildcard.new;
		}
		elsif $/<range> {
			make $/<range>.ast
		}
		else {
			make $/<terminal>.ast
		}
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

	method element( $/ ) {
		if $/<ebnfSuffix> {
			if $/<atom><terminal><scalar> and
				!is-ANTLR-terminal( ~$/<atom><terminal><scalar> ) {
				make Nonterminal.new(
					:modifier(
						$/<ebnfSuffix><MODIFIER>.ast
					),
					:greed(
						$/<ebnfSuffix><GREED> ??
							$/<ebnfSuffix><GREED>.ast !!
							''
					),
					:name( ~$/<atom><terminal><scalar> )
				)
			}
			elsif $/<atom><DOT> {
				make Wildcard.new(
					:modifier(
						$/<ebnfSuffix><MODIFIER>.ast
					),
					:greed(
						$/<ebnfSuffix><GREED> ??
							$/<ebnfSuffix><GREED>.ast !!
							''
					),
				)
			}
			elsif $/<atom><notSet><blockSet> {
				make CharacterSet.new(
					:negated( True ),
					:modifier(
						$/<ebnfSuffix><MODIFIER>.ast
					),
					:greed(
						$/<ebnfSuffix><GREED> ??
							$/<ebnfSuffix><GREED>.ast !!
							''
					),
					# XXX can improve
					:content(
	~$/<atom><notSet><blockSet><setElementAltList><setElement>[0]<terminal><STRING_LITERAL>[0]
					)
				)
			}
			elsif $/<atom><notSet><setElement><LEXER_CHAR_SET> {
				make CharacterSet.new(
					:negated( True ),
					:modifier(
						$/<ebnfSuffix><MODIFIER>.ast
					),
					:greed(
						$/<ebnfSuffix><GREED> ??
							$/<ebnfSuffix><GREED>.ast !!
							''
					),
					# XXX can improve
					:content(
						$/<atom><notSet><setElement><LEXER_CHAR_SET>>>.Str
					)
				)
			}
			elsif $/<atom><notSet><setElement><terminal> {
				make CharacterSet.new(
					:negated( True ),
					:modifier(
						$/<ebnfSuffix><MODIFIER>.ast
					),
					:greed(
						$/<ebnfSuffix><GREED> ??
							$/<ebnfSuffix><GREED>.ast !!
							''
					),
					# XXX can improve
					:content(
						~$/<atom><notSet><setElement><terminal><STRING_LITERAL>[0]
					)
				)
			}
			elsif $/<atom><terminal><scalar>.ast {
				make Terminal.new(
					:modifier(
						$/<ebnfSuffix><MODIFIER>.ast
					),
					:greed(
						$/<ebnfSuffix><GREED> ??
							$/<ebnfSuffix><GREED>.ast !!
							''
					),
					:name(
						ANTLR-to-perl(
							$/<atom><terminal><scalar>.ast
						)
					)
				)
			}
		}
		elsif $/<ebnf> {
			# XXX The // '' should probably go away...
			make Grouping.new(
				:modifier(
					$/<ebnf><ebnfSuffix><MODIFIER>.ast // ''
				),
				:greed(
					$/<ebnf><ebnfSuffix><GREED> ??
						$/<ebnf><ebnfSuffix><GREED>.ast !!
						''
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
			make Range.new(
				:modifier(
					 $/<element>[0]<ebnfSuffix><MODIFIER>.ast
				),
				:greed(
					$/<element>[0]<ebnfSuffix><GREED> ??
						$/<element>[0]<ebnfSuffix><GREED>.ast !!
						''
				),
				:from(
					ANTLR-to-perl(
						$/<element>[0]<atom><range><from>.ast
					)
				),
				:to(
					ANTLR-to-perl(
						$/<element>[0]<atom><range><to>.ast
					)
				),
			)
		}
		elsif $/<element>[0]<atom><notSet> and
			$/<element>[1]<atom><DOT> and
			$/<element>[2]<atom><DOT> {
			make Range.new(
				:modifier(
					$/<element>[3]<ebnfSuffix><MODIFIER>.ast // ''
				),
				:greed(
					$/<element>[3]<ebnfSuffix><GREED> ??
						$/<element>[3]<ebnfSuffix><GREED>.ast !!
						''
				),
				:negated( True ),
				:from(
					ANTLR-to-perl(
						$/<element>[0]<atom><notSet><setElement><terminal><scalar>.ast ) ),
				:to(
					ANTLR-to-perl(
						$/<element>[3]<atom><terminal><scalar>.ast
					)
				)
			)
		}
		else {
			make Concatenation.new( :content( $/<element>>>.ast ) )
		}
	}

	method parserAlt( $/ ) {
		make $/<parserElement>.ast
	}

	method lexerAtom( $/ ) {
		if $/<LEXER_CHAR_SET> {
			my @content;
			for $/<LEXER_CHAR_SET> {
				@content.append( ~$_ )
			}
			make CharacterSet.new(
				:content( @content )
			)
		}
		elsif $/<terminal> {
			make Terminal.new(
				:name(
					ANTLR-to-perl(
						$/<terminal><STRING_LITERAL>.ast
					)
				)
			)
		}
	}

	method lexerElement( $/ ) {
		if $/<ebnfSuffix> {
			my @content;
			for $/<lexerAtom><LEXER_CHAR_SET> {
				@content.append( $_ )
			}
			make CharacterSet.new(
				:modifier( $/<ebnfSuffix><MODIFIER>.ast ),
				:greed(
					$/<ebnfSuffix><GREED> ??
						$/<ebnfSuffix><GREED>.ast !! ''
				),
				:content( @content )
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
		make $/<parserRuleSpec> ??
			$/<parserRuleSpec>.ast !!
			$/<lexerRuleSpec>.ast
	}

	method TOP( $/ ) {
		my @body;
		for $/<prequelConstruct> {
			@body.append( $_.ast )
		}
		for $/<ruleSpec> {
			@body.append( $_.ast )
		}
		my $grammar = Grammar.new(
			:name( $/<ID>.ast ),
			:content( @body )
		);
		make $grammar
	}
}

# vim: ft=perl6
