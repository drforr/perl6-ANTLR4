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
use ANTLR4::Actions::AST;

class ANTLR4::Actions::Perl6 is ANTLR4::Actions::AST
	{
	method sillywalk_TOP($x)
		{
		my $str = 'grammar ';
		$str ~= $/<name>;
		$str ~= ' { }';
		if $/<type>
			{
			$str ~= "#={ type '" ~ $x.<type> ~ "' }";
			}

		if $/<tokens>
			{
			$str ~= '#={ tokens {' ~
				@( $x.<tokens> ).join(',') ~
				'} } ';
			}
		$str;
		}

	method TOP($/)
		{
		make $.sillywalk_TOP($/.ast);
		}
	}

# vim: ft=perl6
