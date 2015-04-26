use v6;
BEGIN { @*INC.push('lib') };
use ANTLR4::Grammar;
use ANTLR4::Actions;
use Test;

plan 9;

my $a = ANTLR4::Actions.new;
my $g = ANTLR4::Grammar.new;

is_deeply $g.parse( q{grammar Name;}, :actions($a) ).ast,
          { name    => 'Name',
            type    => '',
            options => [ ],
            import  => [ ],
            tokens  => [ ] };

is_deeply $g.parse( q{lexer grammar Name;}, :actions($a) ).ast,
          { name    => 'Name',
            type    => 'lexer',
            options => [ ],
            import  => [ ],
            tokens  => [ ] };

is_deeply $g.parse( q{lexer grammar Name; options {a=2;}}, :actions($a) ).ast,
          { name    => 'Name',
            type    => 'lexer',
            options => [ a => 2 ],
            import  => [ ],
            tokens  => [ ] };

is_deeply $g.parse(
	q{lexer grammar Name; options {a='foo';}}, :actions($a) ).ast,
          { name    => 'Name',
            type    => 'lexer',
            options => [ a => "'foo'" ],
            import  => [ ],
            tokens  => [ ] };

is_deeply $g.parse(
	q{lexer grammar Name; options {a=b,c;}}, :actions($a) ).ast,
          { name    => 'Name',
            type    => 'lexer',
            options => [ a => [ 'b', 'c' ] ],
            import  => [ ],
            tokens  => [ ] };

is_deeply $g.parse(
	q{lexer grammar Name; options {a=b,c;de=3;}}, :actions($a) ).ast,
          { name    => 'Name',
            type    => 'lexer',
            options => [ a => [ 'b', 'c' ], de => 3 ],
            import  => [ ],
            tokens  => [ ] };

is_deeply $g.parse(
	q{lexer grammar Name; options {a=b,c;de=3;} import Foo;}, :actions($a) ).ast,
          { name    => 'Name',
            type    => 'lexer',
            options => [ a => [ 'b', 'c' ], de => 3 ],
	    import  => [ 'Foo' => ''  ],
            tokens  => [ ] };

is_deeply $g.parse(
	q{lexer grammar Name; options {a=b,c;de=3;} import Foo,Bar=Test;}, :actions($a) ).ast,
          { name    => 'Name',
            type    => 'lexer',
            options => [ a => [ 'b', 'c' ], de => 3 ],
	    import  => [ Foo => '', Bar => 'Test' ],
            tokens  => [ ] };

#
# XXX tokens should really be a set, come to think of it.
#
is_deeply $g.parse(
	q{lexer grammar Name; options {a=b,c;de=3;} import Foo,Bar=Test; tokens { Foo, Bar }}, :actions($a) ).ast,
          { name    => 'Name',
            type    => 'lexer',
            options => [ a => [ 'b', 'c' ], de => 3 ],
	    import  => [ Foo => '', Bar => 'Test' ],
            tokens  => [ 'Foo', 'Bar' ] };

is_deeply $g.parse(
	q{lexer grammar Name; options {a=b,c;de=3;} import Foo,Bar=Test; tokens { Foo, Bar } @members { protected int curlies = 0; }}, :actions($a) ).ast,
          { name    => 'Name',
            type    => 'lexer',
            options => [ a => [ 'b', 'c' ], de => 3 ],
            import  => [ Foo => '', Bar => 'Test' ],
            tokens  => [ 'Foo', 'Bar' ],
            action  => [ '@members' => '{ protected int curlies = 0; }' ] };

# vim: ft=perl6
