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

# Sigh, go full-OO on this.

my role Named { has $.name; }

class Terminal {
	also does Named;

	method to-lines { return $.name }
}

class Wildcard { method to-lines { return "." } }

class Nonterminal {
	also does Named;

	method to-lines { return "<$.name>" }
}

class Range {
	has $.from;
	has $.to;
	has $.negated;

	method to-lines {
		if $.negated {
			return "<-[ $.from .. $.to ]>"
		}
		return "<[ $.from .. $.to ]>"
	}
}

class CharacterSet {
	has @.content;
	has $.negated;

	method to-lines {
		if $.negated {
			return ( '<-[', @.content, ']>' )
		}
		return ( '<[', @.content, ']>' )
	}
}

class Alternation {
	has @.content;

	method to-lines {
		my @content;
		for @.content {
			# XXX The (() is a cue to where the indent will happen.
			@content.append( '||', '((', $_.to-lines, '))' );
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
		@content.flat
	}
}

class Block {
	also does Named;

	has $.type;
	has @.content;

	method to-lines {
		my @content;
		for @.content {
			@content.append( $_.to-lines );
		}
		return (
			"$.type $.name \{",
			@content || Any,
			"\}"
		).flat
	}
}

class Grouping is Block {
	method to-lines {
		my @content;
		for @.content {
			@content.append( $_.to-lines );
		}
		return ( "\(", @content || Any, "\)" )
	}
}

class Token is Block {
	method to-lines {
		my $lc-name = lc( $.name );
		return ( "token $.name \{", "'$lc-name'", "\}" )
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

	has @.content;

	method to-lines {
		my @content;
		for @.content {
			@content.append( $_.to-lines );
		}
		return ( "grammar $.name \{", @content || Any, "\}" ).flat
	}
}

class ANTLR4::Actions::Perl6 {
	method tokenName( $/ ) {
		make Token.new( :name( ~$/<ID> ) )
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
			make Nonterminal.new( :name( ~$/<ID> ) )
		}
		else {
			make Terminal.new( :name( ~$/<scalar>[0] ) )
		}
	}

	method range( $/ ) {
		make Range.new(
			:from( ~$/<from>[0] ),
			:to( ~$/<to>[0] )
		)
	}

	method notSet( $/ ) {
		if $/<setElement><LEXER_CHAR_SET> {
			my @content;
			for $/<setElement><LEXER_CHAR_SET> {
				@content.append( $_ )
			}
			make CharacterSet.new(
				:negated( True ),
				:content( @content )
			)
		}
		elsif $/<blockSet> {
			my @content;
			for $/<blockSet><setElementAltList><setElement> {
				@content.append( ~$_<terminal><scalar>[0] )
			}
			make CharacterSet.new(
				:negated( True ),
				:content( @content )
			)
		}
		else {
			make CharacterSet.new(
				:negated( True ),
				:content(
					$/<setElement><terminal><STRING_LITERAL>[0]
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

	method element( $/ ) {
		if $/<atom> {
			make $/<atom>.ast
		}
		elsif $/<ebnf> {
			make Grouping.new(
				:content(
					$/<ebnf>.ast
				)
			)
		}
	}

	method parserElement( $/ ) {
		if $/<element>.elems == 4 and
			$/<element>[0]<atom><notSet> and
			$/<element>[1]<atom><DOT> and
			$/<element>[2]<atom><DOT> {
			make Range.new(
				:negated( True ),
				:from( ~$/<element>[0]<atom><notSet><setElement><terminal><scalar>[0] ),
				:to( ~$/<element>[3]<atom><terminal><scalar>[0] ),
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
			make ~$/<LEXER_CHAR_SET>[0]
		}
		else {
			make ~$/<notSet>
		}
	}

	method lexerAlt( $/ ) {
		my @content;
		for $/<lexerElement> {
			@content.append( $_<lexerAtom>.ast )
		}
		make CharacterSet.new(
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
			:name( ~$/<ID> ),
			:content( $/<parserAltList>.ast )
		)
	}

	method lexerRuleSpec( $/ ) {
		make Rule.new(
			:name( ~$/<ID> ),
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
			:name( ~$/<ID> ),
			:content( @body )
		);
		make $grammar.to-lines.join( "\n" );
	}

	sub translate-unicode( Str $str ) {
		my $copy = $str;
		$copy ~~ s/\\u(....)/\\x[$0]/;
		$copy
	}
}

# vim: ft=perl6
