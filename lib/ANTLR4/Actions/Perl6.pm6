=begin pod

=head1 ANTLR4::Actions::Perl6

C<ANTLR4::Actions::Perl6> generates a perl6 representation of an ANTLR4 AST.

=head1 Synopsis

    use ANTLR4::Actions::Perl6;
    use ANTLR4::Grammar;
    my $p = ANTLR4::Actions::Perl6.new;

    say $p.parse('grammar Minimal { identifier : [A-Z][A-Za-z]+ ; }').perl6;
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
	has ANTLR4::Grammar $g =
		ANTLR4::Grammar.new;
	has ANTLR4::Actions::AST $a =
		ANTLR4::Actions::AST.new;

	my class ANTLR4::Actions::Perl6::Shim {
		has $.ast;
		has $.perl6;
	}

	sub translate-unicode( Str $str ) {
		my $copy = $str;
		$copy ~~ s/\\u(....)/\\x[$0]/;
		$copy
	}

	method to-json-comment( $json ) {
		my $json-str = to-json( $json );
		return qq{ #=$json-str};
	}

	method build-tokens( $ast ) {
		my $token = '';
		if $ast.<token> {
			my @token = map {
				my $lc = lc $_;
				qq{\ttoken $_ \{ '$lc' \}}
			}, $ast.<token>.keys.sort;
			$token = @token.join("\n") ~ "\n";
		}
		$token;
	}

	method build-rule-json( $ast ) {
		my $json;
		for <type throw return action local option catch finally> -> $key {
			$json.{$key} = $ast.{$key} if $ast.{$key};
		}
		return $json ?? self.to-json-comment( $json ) !! '';
	}

	method build-outer-json( $ast ) {
		my $json;
		for <type option import action> -> $key {
			$json.{$key} = $ast.{$key} if $ast.{$key};
		}
		return $json ?? self.to-json-comment( $json ) !! '';
	}

	method build-rules( $ast ) {
		my $rules = '';
		if $ast.<rule> {
			my @rules = map {
				qq:to{END}.chomp
	rule $_ \{{self.build-rule-json( $ast.<rule>.{$_} )}\n\t\}
END
			}, $ast.<rule>.keys.sort;
			return @rules.join( "\n" ) ~ "\n";
		}
		'';
	}

	method reconstruct( $ast ) {
		my $grammar = qq:to{END};
grammar $ast.<name> \{{self.build-outer-json( $ast )}
{self.build-tokens( $ast )}{self.build-rules( $ast )}\}
END
		$grammar;
	}

	method parse( Str $str ) {
		my $ast = $!g.parse( $str, :actions($!a) ).ast;
		ANTLR4::Actions::Perl6::Shim.new(
			ast => $ast,
			perl6 => self.reconstruct( $ast ) )
	}

	method parsefile( Str $filename ) {
		my $ast = $!g.parsefile( $filename, :actions($!a) ).ast;
		ANTLR4::Actions::Perl6::Shim.new(
			ast => $ast,
			perl6 => self.reconstruct( $ast ) )
	}
}

# vim: ft=perl6
