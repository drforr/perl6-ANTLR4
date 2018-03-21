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
	#method indent( @lines ) {
	method indent( *@lines ) {
		map { self.indent-line( $_ ) }, grep { /\S/ }, @lines
	}
}

my role Named { has $.name; }

class Terminal {
	also does Named;

	has $.modifier = '';

	method to-lines {
		my $copy = $.name;
		$copy ~~ s:g/\\u(....)/\\x[$0]/;
		$copy ~~ s:g/<!after \\>\'/\\\'/;
		if $copy ~~ / <-[ a ..z A .. Z ]> / {
			$copy = qq{'$copy'};
		}
		return $copy ~ $.modifier
	}
}

class Wildcard { method to-lines { return "." } }

class Nonterminal {
	also does Named;

	has $.modifier = '';

	method to-lines { return "<$.name>" ~ $.modifier }
}

class Range {
	has $.from;
	has $.to;
	has $.negated;
	has $.modifier = '';

	method to-lines {
		$.negated ??
			"<-[ $.from .. $.to ]>" ~ $.modifier !!
			"<[ $.from .. $.to ]>" ~ $.modifier
	}
}

class CharacterSet {
	has @.content;
	has $.negated;
	has $.modifier = '';

	method to-lines {
		$.negated ??
			"<-[ {@.content} ]>" ~ $.modifier !!
			"<[ {@.content} ]>" ~ $.modifier
	}
}

class Alternation {
	also does Indenting;

	has @.content;

	method to-lines {
		my @content;
		for @.content {
			my @lines = self.indent( $_.to-lines );
			@lines[0] = '||' ~ @lines[0] if @lines[0];
			@content.append( @lines );
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

	has $.type;
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
	has $.modifier = '';

	method to-lines {
		my @content;
		for @.content {
			@content.append( $_.to-lines );
		}
		return (
			"\(",
			self.indent( @content ),
			"\)" ~ $.modifier
		).flat
	}
}

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

	method ebnfSuffix( $/ ) { make $/<MODIFIER>.ast }

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

	# A lovely quirk of the ANTLR grammar is that nonterminals are actually
	# just a variant of the terminal, because ANTLR internally divides
	# lexer and parser grammars, and lexers can't have parser terms
	# so it's not notated separately.
	#
	method terminal( $/ ) {
		if $/<ID> {
			make Nonterminal.new( :name( $/<ID>.ast ) )
		}
		else {
			make Terminal.new( :name( $/<scalar>.ast ) )
		}
	}

	# Keep in mind that there is no 'from' rule, so even though here we
	# reference 'STRING_LITERAL' by its alias, the actual method that
	# gets called is STRING_LITERAL.
	#
	method range( $/ ) {
		make Range.new(
			:from( $/<from>.ast ),
			:to( $/<to>.ast )
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
		if $/<ebnfSuffix> and $/<atom> and $/<atom><notSet> {
			make CharacterSet.new(
				:negated( True ),
				:modifier( $/<ebnfSuffix>.ast ),
				# XXX can improve
				:content(
					$/<atom><notSet><setElement><LEXER_CHAR_SET>>>.Str
				)
			)
		}
		elsif $/<ebnfSuffix> and is-ANTLR-terminal( $/<atom> ) {
			make Terminal.new(
				:modifier( $/<ebnfSuffix>.ast ),
				:name( $/<atom><terminal><scalar>.ast )
			)
		}
		elsif $/<atom> {
			make $/<atom>.ast
		}
		elsif $/<ebnf> {
			# XXX The // '' should probably go away...
			make Grouping.new(
				:modifier( $/<ebnf><ebnfSuffix>.ast // '' ),
				:content(
					Alternation.new(
						:content( $/<ebnf>.ast )
					)
				)
			)
		}
	}

	method parserElement( $/ ) {
		if $/<element>.elems == 1 and
			$/<element>[0]<atom><range> and
			$/<element>[0]<ebnfSuffix> {
			make Range.new(
				:modifier( $/<element>[0]<ebnfSuffix>.ast ),
				:from( $/<element>[0]<atom><range><from>.ast ),
				:to( $/<element>[0]<atom><range><to>.ast ),
			)
		}
		elsif $/<element>.elems == 4 and
			$/<element>[0]<atom><notSet> and
			$/<element>[1]<atom><DOT> and
			$/<element>[2]<atom><DOT> {
			make Range.new(
				:modifier( $/<element>[3]<ebnfSuffix>.ast // '' ),
				:negated( True ),
				:from( $/<element>[0]<atom><notSet><setElement><terminal><scalar>.ast ),
				:to( $/<element>[3]<atom><terminal><scalar>.ast ),
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
		make $/<LEXER_CHAR_SET>.ast
	}

	method lexerAlt( $/ ) {
		my @content;
		for $/<lexerElement> {
			@content.append( $_.<lexerAtom>.ast )
		}
		make CharacterSet.new(
			:modifier( $/<lexerElement>[0]<ebnfSuffix>.ast // '' ),
			:content( @content )
		)
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
