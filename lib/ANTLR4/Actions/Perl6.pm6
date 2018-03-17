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

role Indent {
	method indent( $depth = 0 ) {
		"\t" x $depth
	}
}
class Block {
	also does Indent;
	has $.type;
	has $.name;
	has @.content;

	method to-string( $depth = 0 ) {
		my $result;
		$result ~= self.indent( $depth ) ~ "$.type $.name \{\n";
		$result ~= .to-string( $depth + 1 ) for @.content;
		$result ~= self.indent( $depth ) ~ "\}\n";
		$result;
	}
}
class Token is Block {
	method to-string( $depth = 0 ) {
		my $lc-name = lc( $.name );
		my $result;
		$result ~= self.indent( $depth ) ~ "token $.name \{\n";
		$result ~= self.indent( $depth + 1 ) ~ "'" ~ $lc-name ~ "'\n";
#		$result ~= "'" ~ $lc-name ~ "'\n";
		$result ~= self.indent( $depth ) ~ "\}\n";
		$result;
	}
}
class Rule is Block { has $.type = 'rule'; }
class Notes {
	also does Indent;
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
class Grammar is Block { has $.type = 'grammar'; }

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
		for $/ -> $prequel {
			when $prequel<tokensSpec> {
				@tokens.append( $prequel<tokensSpec>.ast );
			}
		}
		make @tokens
	}

	method parserRuleSpec( $/ ) {
		make Rule.new(
			:name( ~$/<ID> )
		)
	}

	method ruleSpec( $/ ) {
		make $/<parserRuleSpec>.ast
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
		make $grammar.to-string;
	}

	sub translate-unicode( Str $str ) {
		my $copy = $str;
		$copy ~~ s/\\u(....)/\\x[$0]/;
		$copy
	}
}

# vim: ft=perl6
