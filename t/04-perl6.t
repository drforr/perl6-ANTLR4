use v6;
BEGIN { @*INC.push('lib') };
use ANTLR4::Grammar;
use ANTLR4::Actions::AST;
use ANTLR4::Actions::Perl6;
use Test;

plan 1;

my $a = ANTLR4::Actions::Perl6.new;
my $p = ANTLR4::Grammar.new;

is $p.parse( q{grammar Minimal;}, :actions($a) ).ast,
   'grammar Minimal { }';

is $p.parse( q{lexer grammar Minimal;}, :actions($a) ).ast,
   q{grammar Minimal { } #={ type 'lexer' }};

# vim: ft=perl6
