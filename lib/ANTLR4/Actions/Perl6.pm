=begin pod

=head1 ANTLR4::Actions::Perl6

C<ANTLR4::Actions::Perl6> generates a perl6 representation of an ANTLR4 AST.

=head1 Synopsis

    use ANTLR4::Actions::Perl6;
    use ANTLR4::Grammar;
    my $p = ANTLR4::Actions::Perl6.new;

    say $p.parsefile('ECMAScript.g4').perl6;

=head1 Documentation

The action in this file will return a completely unblessed abstract syntax
tree (AST) of the ANTLR4 grammar perl6 has been asked to parse. Other variants
may return an object or even the nearest perl6 equivalent grammar, but this
just returns a hash reference with nested array references.

=end pod

use v6;
use JSON::Tiny;
use ANTLR4::Grammar;
use ANTLR4::Actions::AST;

class ANTLR4::Actions::Perl6 {
	has ANTLR4::Grammar $g = ANTLR4::Grammar.new;
	has ANTLR4::Actions::AST $a = ANTLR4::Actions::AST.new;

	my class ANTLR4::Actions::Perl6::Shim {
		has $.ast;
		has $.perl6;
	}

	method reconstruct( $ast ) {
		my $str = qq{grammar $ast.<name> { }};
		my $json;
		for <type options import tokens actions> -> $key {
			$json.{$key} = $ast.{$key} if $ast.{$key};
		}
		if $json {
			$str ~= q< #=> ~ to-json($json);
		}
		$str;
	}

	method parse( $str ) {
		my $ast = $!g.parse( $str, :actions($!a) ).ast;
		ANTLR4::Actions::Perl6::Shim.new(
			ast => $ast,
			perl6 => self.reconstruct( $ast )
		)
	}
}

# vim: ft=perl6
