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

	method to-json-comment( $json, $indent ) {
		my $json-str = to-json( $json );
		return qq<{"" x $indent}#|$json-str>;
	}

	method rule-json( $ast, $indent = 1 ) {
		my $json;
		for <type throw return action local option catch finally> -> $key {
			$json.{$key} = $ast.{$key} if $ast.{$key};
		}
		return $json ?? self.to-json-comment( $json, 1 ) !! '';
	}

	method outer-json( $ast ) {
		my $json;
		for <type option import action> -> $key {
			$json.{$key} = $ast.{$key} if $ast.{$key};
		}
		return $json ?? self.to-json-comment( $json, 0 ) !! '';
	}

	method token( $name, $indent = 1 ) {
		my $lc = lc( $name );
		qq<token $name \{ '{$lc}' \}>
	}

	method tokens( $ast ) {
		map { self.token( $_ ) }, $ast.keys.sort;
	}

	method indent-lines( @text, $indent = 0 ) {
		my $indent-str = $.indent-char xx $indent;
say "|$_|" for @text;
		map { qq<{$indent-str}{$_}\n> }, grep { $_ ne '' }, @text;
	}

	method rule( $ast, $name, $indent = 1 ) {
		my $json = self.rule-json( $ast.{$name}, $indent );
		self.indent-lines( [
			$json,
			qq<rule $name \{>,
			<}>,
		], $indent
		);
	}

	method rules( $ast ) {
		map { self.rule( $ast, $_ ) }, $ast.keys.sort;
	}

	method grammar( $ast ) {
#		my $tokens = self.tokens( $ast.<token> ).join( '' );
#		my $rules  = self.rules( $ast.<rule> ).join( '' );
#		qq<{$json}grammar $ast.<name> \{{$tokens}{$rules}\}>;
		self.indent-lines( [
			self.outer-json( $ast ),
			qq<grammar $ast.<name> \{>,
#			self.tokens( $ast.<token> ).join( '' ),
			self.indent-lines( [
				map { self.token( $_ ) }, $ast.<token>.keys.sort
			], 1 ),
			qq<}>
		] ).chomp;
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
