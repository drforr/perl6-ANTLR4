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

# Little helper class
#
# Take 'foo', [ 'bar', [ 'baz', 'qux' ] ] and turn it into:
# foo {
#   bar {
#     baz
#     qux
#   }
# }
#
# This way I don't need to worry about balancing braces and indentation.
# Just let the class handle it for me.
#
# And in case I want to change the brace style later on I've got one point in
# the application to change.
#
# This should have its own mini-test suite, but that would mean exposing it,
# and it's a tiny ting as it is.
#
my class Outline {
	has @.line;
	method indent( $line, $depth ) {
		@.line.append( ( "\t" x $depth ) ~ $line );
	}
	method outline( @item, $depth = 0 ) {
		for @item {
			when Array {
				@.line[*-1] ~= ' {'; # }
				self.outline( @( $_ ), $depth + 1 );
				self.indent( '}', $depth );
			}
			when Str {
				self.indent( $_, $depth ) if /\S/;
			}
		}
	}
	method render {
		join( "\n", @.line );
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

	method to-json-comment( $ast, @key ) {
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

	method token( $ast ) {
		my @token;
		for $ast.keys -> $name {
			@token.append(
				"token $name", [
					"'{lc($name)}'"
				]
			);
		}
		@token;
	}

	method term( $ast ) {
		my @term;
		given $ast.<type> {
			when 'terminal' {
				@term.append( qq{'$ast.<name>'} );
			}
			when 'alternation' {
				for @( $ast.<term> ) -> $term {
					@term.append( '| ' ~ self.term( $term ) )
				}
			}
			when 'concatenation' {
				for @( $ast.<term> ) -> $term {
					@term.append( self.term( $term ) )
				}
			}
		}
		@term;
	}

	method rule( $ast ) {
		my @rule;
		for $ast.keys -> $name {
			my @term;
			@term.append(
				self.term( $ast.{$name}.<term> )
			);
			@rule.append(
				self.to-json-comment(
					$ast.{$name},
					[<type throw return action
					  local option catch finally>]
				),
				"rule $name", [
					@term
				]
			);
		}
		@rule;
	}

	method grammar( $ast ) {
		my $o = Outline.new;
		my @term;
		@term.append( self.token( $ast.<token> ) );
		@term.append( self.rule( $ast.<rule> ) );
			
		$o.outline( [
			self.to-json-comment(
				$ast,
				[<type option import action>]
			),
			"grammar $ast.<name>", [
				@term
			]
		] );
		$o.render;
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
