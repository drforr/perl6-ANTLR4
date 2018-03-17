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

my role Indentation {
	method indent { "\t" }
}

my role Named {
	has $.name;
}

class Terminal {
	also does Named;

	method to-lines { return $.name }
}

class Nonterminal {
	also does Named;

	method to-lines { return "<$.name>" }
}

class Alternation {
	also does Indentation;
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
	also does Indentation;
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
	also does Indentation;
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
		return
			"\(" ~
			join( '',
				map { .to-lines }, @.content
			) ~
			"\)";
	}
}

class Token is Block {
	method to-lines {
		my $lc-name = lc( $.name );
		return (
			"token $.name \{",
			"'$lc-name'",
			"\}"
		)
	}
}

class Rule is Block { has $.type = 'rule'; }

class Notes {
	also does Indentation;
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

class Grammar {
	also does Indentation;
	also does Named;
	has @.content;

	method to-lines {
		my @content;
		for @.content {
			@content.append( $_.to-lines );
		}
		return (
			"grammar $.name \{",
			@content || Any,
			"\}"
		).flat
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

	method atom( $/ ) {
		make $/<terminal>.ast
	}

	method element( $/ ) {
		make $/<atom>.ast
	}

	method parserElement( $/ ) {
		make Concatenation.new( :content( $/<element>>>.ast ) )
	}

	method parserAlt( $/ ) {
		make $/<parserElement>.ast
	}

	method parserAltList( $/ ) {
		make Alternation.new( :content( $/<parserAlt>>>.ast ) )
	}

	method parserRuleSpec( $/ ) {
		make Rule.new(
			:name( ~$/<ID> ),
			:content( $/<parserAltList>.ast )
		)
	}

	method ruleSpec( $/ ) {
		make $/<parserRuleSpec>.ast
	}

	method TOP( $/ ) {
say $/;
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
say $grammar.to-lines.perl;
		make $grammar.to-lines.join( "\n" );
	}

	sub translate-unicode( Str $str ) {
		my $copy = $str;
		$copy ~~ s/\\u(....)/\\x[$0]/;
		$copy
	}
}

# vim: ft=perl6
