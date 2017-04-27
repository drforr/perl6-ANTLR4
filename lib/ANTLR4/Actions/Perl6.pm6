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

my class Outline {
	has $.indent-char = "\t";
	has @.line;

	method indent( $line, $depth = 0 ) {
		( $.indent-char x $depth ) ~ $line
	}

	method outline( @lines, $depth = 0 ) {
		for @lines -> $line {
			given $line {
				when Array {
					self.outline(
						@( $line ),
						$depth + 1
					);
				}
				when '' { }
				default {
					@.line.append(
						self.indent( $line, $depth )
					);
				}
			}
		}
	}

	method render {
		join( "\n", @.line )
	}
}

class ANTLR4::Actions::Perl6 {
	has ANTLR4::Grammar $g =
		ANTLR4::Grammar.new;
	has ANTLR4::Actions::AST $a =
		ANTLR4::Actions::AST.new;

	has Str $.indent-char = qq{\t};

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
		return qq<#|$json-str>;
	}

	method rule-json( $ast ) {
		my $json;
		for <type throw return action local option catch finally> -> $key {
			$json.{$key} = $ast.{$key} if $ast.{$key};
		}
		return $json ?? self.to-json-comment( $json ) !! '';
	}

	method outer-json( $ast ) {
		my $json;
		for <type option import action> -> $key {
			$json.{$key} = $ast.{$key} if $ast.{$key};
		}
		return $json ?? self.to-json-comment( $json ) !! '';
	}

	method grammar( $ast ) {
		my @token;
		my @rule;
		for $ast.<token>.keys -> $name {
			@token.append( [
				"token $name \{", [
					"'{lc($name)}'"
				],
				"\}"
			] );
		}
		for $ast.<rule>.keys -> $name {
			my @term;
			if $ast.<rule>{$name}.<term> {
				for $ast.<rule>{$name}.<term> -> $term {
					@term.append( $term.<name> );
				}
			}
			@rule.append( [
				self.rule-json( $ast.<rule>{$name} ),
				"rule $name \{", [
					@term
				],
				"\}"
			] );
		}
		my $ds = [
			self.outer-json( $ast ),
			"grammar $ast.<name> \{",
			@token,
			@rule,
			"\}"
		];
		my $outline = Outline.new;
		$outline.outline( $ds );
		$outline.render;
	}

	method get-shim( $ast ) {
		ANTLR4::Actions::Perl6::Shim.new(
			ast   => $ast,
			perl6 => self.grammar( $ast )
		);
	}

	method parse( Str $str ) {
		self.get-shim(
			$!g.parse( $str, :actions($!a) ).ast
		);
	}

	method parsefile( Str $filename ) {
		self.get-shim(
			$!g.parsefile( $filename, :actions($!a) ).ast
		);
	}
}

# vim: ft=perl6
