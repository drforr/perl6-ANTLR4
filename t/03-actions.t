use v6;
BEGIN { @*INC.push('lib') };
use ANTLR4::Grammar;
use ANTLR4::Actions;
use Test;

plan 2;

my $a = ANTLR4::Actions.new;
my $g = ANTLR4::Grammar.new;

is_deeply $g.parse( q{grammar Name;}, :actions($a) ).ast,
          { name => 'Name',
            type => 'default' };

is_deeply $g.parse( q{lexer grammar Name;}, :actions($a) ).ast,
          { name => 'Name',
            type => 'lexer' };

is_deeply $g.parse( q{lexer grammar Name; options {a=2;}}, :actions($a) ).ast,
          { name => 'Name',
            type => 'lexer',
            options => { a => 2 } };

is_deeply $g.parse(
	q{lexer grammar Name; options {a='foo';}}, :actions($a) ).ast,
          { name => 'Name',
            type => 'lexer',
            options => { a => "'foo'" } }; # XXX think about that later.

is_deeply $g.parse(
	q{lexer grammar Name; options {a=b,c;}}, :actions($a) ).ast,
          { name => 'Name',
            type => 'lexer',
            options => { a => [ 'b', 'c' ] } };

# vim: ft=perl6
