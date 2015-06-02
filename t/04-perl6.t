use v6;
BEGIN { @*INC.push('lib') };
use ANTLR4::Actions::Perl6;
use Test;

plan 1;

my $p = ANTLR4::Actions::Perl6.new;

subtest sub {
  is $p.parse( q{grammar Minimal;} ).perl6,
     'grammar Minimal { }',
     'minimal grammar';
  is $p.parse( q{lexer grammar Minimal;} ).perl6,
     'grammar Minimal { } #={ "type" : "lexer" }',
     'type';
  is $p.parse( q{grammar Minimal; options {a=2;}} ).perl6,
     'grammar Minimal { } #={ "options" : [ { "a" : 2 } ] }',
     'options';
  is $p.parse( q{grammar Minimal; import Foo;} ).perl6,
     'grammar Minimal { } #={ "import" : [ { "Foo" : null } ] }',
     'import';
  is $p.parse( q{grammar Minimal; tokens { INDENT, DEDENT }} ).perl6,
     'grammar Minimal { } #={ "tokens" : [ "INDENT", "DEDENT" ] }',
     'tokens';
  is $p.parse( q{grammar Minimal; @members { int i = 0; }} ).perl6,
     'grammar Minimal { } #={ "actions" : [ { "@members" : "{ int i = 0; }" } ] }',
     'actions';
}, 'Top-level terms';

########################################
# 
# subtest sub {
#   my $parsed;
#   $parsed = $g.parse(
#     q{grammar Name;
#       @members { protected int curlies = 0; }}, :actions($a) ).ast;
#   is-deeply $parsed.<actions>,
#     [ '@members' => '{ protected int curlies = 0; }' ],
#     q{Single action};
# 
#   $parsed = $g.parse(
#     q{grammar Name;
#       @members { protected int curlies = 0; }
#       @sample::stuff { 1; }}, :actions($a) ).ast;
#   is-deeply $parsed.<actions>,
#     [ '@members' => '{ protected int curlies = 0; }',
#       '@sample::stuff' => '{ 1; }' ],
#     q{Two actions};
# }, 'Actions';
# 
# #
# # Show off the first actual rule.
# #
# is-deeply
#   $g.parse(
#     q{grammar Name; number : '1' ;},
#     :actions($a) ).ast,
#   { name    => 'Name',
#     type    => Nil,
#     options => [ ],
#     import  => [ ],
#     tokens  => [ ],
#     actions => [ ],
#     content =>
#       [{ name     => 'number',
#          modifier => [ ],
#          action   => Nil,
#          returns  => Nil,
#          throws   => [ ],
#          locals   => Nil,
#          options  => [ ],
#          content  =>
#            [{ type    => 'alternation',
#               content =>
#                 [{ type     => 'concatenation',
#                    label    => Nil,
#                    options  => [ ],
#                    commands => [ ],
#                    content  =>
#                      [{ type         => 'terminal',
#                         content      => '1',
#                         modifier     => Nil,
#                         greedy       => False,
#                         complemented => False }] }] }] }] },
#   'grammar with options and single simple rule';
# 
# #
# # Rule-level
# #
# subtest sub {
#   my $parsed;
# 
#   $parsed = $g.parse(
#     q{grammar Name; protected number : '1' ;}, :actions($a) ).ast,
#   is-deeply $parsed.<content>[0]<modifier>,
#     [ 'protected' ],
#     'grammar, rule with multiple alternating terms';
# }, 'rule-level options';
# 
# subtest sub {
#   my $parsed;
# 
#   $parsed = $g.parse(
#     q{grammar Name; number : <assoc=right> '1' ;}, :actions($a) ).ast;
#   is-deeply $parsed.<content>[0]<content>[0]<content>[0]<options>,
#     [ assoc => 'right' ],
#     q{Rule with option};
# 
#   $parsed = $g.parse(
#     q{grammar Name; number : '1' # One ;}, :actions($a) ).ast;
#   is $parsed.<content>[0]<content>[0]<content>[0]<label>, 'One',
#     q{Rule with label};
# 
#   $parsed = $g.parse(
#     q{grammar Name; number : '1' -> channel(HIDDEN) ;}, :actions($a) ).ast;
#   is-deeply $parsed.<content>[0]<content>[0]<content>[0]<commands>,
#     [ channel => 'HIDDEN' ],
#     q{Rule with command};
# }, 'Term-level flags';
# 
# is-deeply
#   $g.parse(
#     q{grammar Name; number : ( '1' )+? ;},
#     :actions($a) ).ast,
#   { name    => 'Name',
#     type    => Nil,
#     options => [ ],
#     import  => [ ],
#     tokens  => [ ],
#     actions => [ ],
#     content =>
#       [{ name     => 'number',
#          modifier => [ ],
#          action   => Nil,
#          returns  => Nil,
#          throws   => [ ],
#          locals   => Nil,
#          options  => [ ],
#          content  =>
#            [{ type    => 'alternation',
#               content =>
#                 [{ type     => 'concatenation',
#                    label    => Nil,
#                    options  => [ ],
#                    commands => [ ],
#                    content  =>
#                      [{ type         => 'capturing group',
#                         modifier     => '+',
#                         greedy       => True,
#                         complemented => False,
#                         content =>
#                           [{ type         => 'alternation',
#                              content      =>
#                                [{ type         => 'terminal',
#                                   content      => '1',
#                                   modifier     => Nil,
#                                   greedy       => False,
#                                   complemented => False }] }] }] }] }] }] },
#   'grammar with options and single simple rule';
# 
# subtest sub {
#   my $parsed;
# 
#   $parsed =
#     $g.parse( q{grammar Name; number : ~'1'+? -> skip ;},
#               :actions($a) ).ast;
#   is-deeply $parsed.<content>[0]<content>[0]<content>[0],
#     { type     => 'concatenation',
#       label    => Nil, 
#       options  => [ ],
#       commands => [ 'skip' => Nil ],
#       content  =>
#         [{ type         => 'terminal',
#            content      => '1',
#            modifier     => '+',
#            greedy       => True,
#            complemented => True }] },
#     q{Channeled rule};
# 
#   $parsed =
#     $g.parse( q{grammar Name; number : ~'1'+? -> channel(HIDDEN) ;},
#               :actions($a) ).ast;
#   is-deeply $parsed.<content>[0]<content>[0]<content>[0]<content>[0],
#     { type         => 'terminal',
#        content      => '1',
#        modifier     => '+',
#        greedy       => True,
#        complemented => True },
#     q{Channeled rule with flags and modifier};
# 
#   $parsed =
#     $g.parse( q{grammar Name; number : digits -> channel(HIDDEN) ;},
#               :actions($a) ).ast;
#   is-deeply $parsed.<content>[0]<content>[0]<content>[0]<content>[0],
#     { type         => 'nonterminal',
#        content      => 'digits',
#        modifier     => Nil,
#        greedy       => False,
#        complemented => False },
#     q{Channeled rule with nonterminal};
# 
#   $parsed =
#     $g.parse( q{grammar Name; number : ~digits+? -> channel(HIDDEN) ;},
#               :actions($a) ).ast,
#   is-deeply $parsed.<content>[0]<content>[0]<content>[0]<content>[0],
#     { type         => 'nonterminal',
#        content      => 'digits',
#        modifier     => '+',
#        greedy       => True,
#        complemented => True },
#     q{Channeled rule with nonterminal};
# 
#   $parsed =
#     $g.parse( q{grammar Name; number : [0-9] -> channel(HIDDEN) ;},
#               :actions($a) ).ast;
#   is-deeply $parsed.<content>[0]<content>[0]<content>[0]<content>[0],
#     { type         => 'character class',
#        content      => [ '0-9' ],
#        modifier     => Nil,
#        greedy       => False,
#        complemented => False },
#     q{Channeled rule with nonterminal};
# 
#   $parsed =
#     $g.parse( q{grammar Name; number : ~[0-9]+? -> channel(HIDDEN) ;},
#               :actions($a) ).ast;
#   is-deeply $parsed.<content>[0]<content>[0]<content>[0]<content>[0],
#     { type         => 'character class',
#        content      => [ '0-9' ],
#        modifier     => '+',
#        greedy       => True,
#        complemented => True },
#     q{Channeled rule with nonterminal};
# 
#   $parsed =
#     $g.parse( q{grammar Name; number : 'a'..'f' -> channel(HIDDEN) ;},
#               :actions($a) ).ast;
#   is-deeply $parsed.<content>[0]<content>[0]<content>[0]<content>[0],
#     { type         => 'range',
#        content      => [{ from => 'a',
#                           to   => 'f' }],
#        modifier     => Nil,
#        greedy       => False,
#        complemented => False },
#     q{Channeled rule with range};
# }, 'command';
# 
# is-deeply
#   $g.parse(
#     q{grammar Name;
# number [int x]
#        returns [int y]
#        throws XFoo
#        locals [int z]
#        options{a=2;}
#   : '1' # One ;},
#     :actions($a) ).ast,
#   { name    => 'Name',
#     type    => Nil,
#     options => [ ],
#     import  => [ ],
#     tokens  => [ ],
#     actions => [ ],
#     content =>
#       [{ name     => 'number',
#          modifier => [ ],
#          action   => '[int x]',
#          returns  => '[int y]',
#          throws   => [ 'XFoo' ],
#          locals   => '[int z]',
#          options  => [ a => 2 ],
#          content  =>
#            [{ type    => 'alternation',
#               content =>
#                 [{ type     => 'concatenation',
#                    label    => 'One',
#                    options  => [ ],
#                    commands => [ ],
#                    content  =>
#                      [{ type         => 'terminal',
#                         content      => '1',
#                         modifier     => Nil,
#                         greedy       => False,
#                         complemented => False }] }] }] }] },
#   'grammar with single labeled rule with action';
# 
# subtest sub {
#   my $parsed;
# 
#   $parsed = $g.parse(
#     q{grammar Name; number : ~'1'+? # One ;},
#     :actions($a) ).ast;
#   is-deeply $parsed.<content>[0]<content>[0]<content>[0],
#     { type     => 'concatenation',
#       label    => 'One',
#       options  => [ ],
#       commands => [ ],
#       content  =>
#         [{ type         => 'terminal',
#            content      => '1',
#            modifier     => '+',
#            greedy       => True,
#            complemented => True }] },
#   'rule with flags';
# 
#   $parsed = $g.parse(
#     q{grammar Name; number : ~[]+? # One ;},
#     :actions($a) ).ast;
#   is-deeply $parsed.<content>[0]<content>[0]<content>[0],
#     { type     => 'concatenation',
#       label    => 'One',
#       options  => [ ],
#       commands => [ ],
#       content  =>
#         [{ type         => 'character class',
#            content      => [ ],
#            modifier     => '+',
#            greedy       => True,
#            complemented => True }] },
#   'character class with flags';
# 
#   $parsed = $g.parse(
#     q{grammar Name; number : ~[0]+? # One ;},
#     :actions($a) ).ast;
#   is-deeply $parsed.<content>[0]<content>[0]<content>[0],
#     { type     => 'concatenation',
#       label    => 'One',
#       options  => [ ],
#       commands => [ ],
#       content  =>
#         [{ type         => 'character class',
#            content      => [ '0' ],
#            modifier     => '+',
#            greedy       => True,
#            complemented => True }] },
#   'character class with flags';
# 
#   $parsed = $g.parse(
#     q{grammar Name; number : ~[0-9]+? # One ;},
#     :actions($a) ).ast;
#   is-deeply $parsed.<content>[0]<content>[0]<content>[0],
#     { type     => 'concatenation',
#       label    => 'One',
#       options  => [ ],
#       commands => [ ],
#       content  =>
#         [{ type         => 'character class',
#            content      => [ '0-9' ],
#            modifier     => '+',
#            greedy       => True,
#            complemented => True }] },
#   'character class with flags';
# 
#   $parsed = $g.parse(
#     q{grammar Name; number : ~[-0-9]+? # One ;},
#     :actions($a) ).ast;
#   is-deeply $parsed.<content>[0]<content>[0]<content>[0],
#     { type     => 'concatenation',
#       label    => 'One',
#       options  => [ ],
#       commands => [ ],
#       content  =>
#         [{ type         => 'character class',
#            content      => [ '-', '0-9' ],
#            modifier     => '+',
#            greedy       => True,
#            complemented => True }] },
#   'character class with lone hyphen and flags';
# 
#   $parsed = $g.parse(
#     q{grammar Name; number : ~[-0-9\f\u000d]+? # One ;},
#     :actions($a) ).ast;
#   is-deeply $parsed.<content>[0]<content>[0]<content>[0],
#     { type     => 'concatenation',
#       label    => 'One',
#       options  => [ ],
#       commands => [ ],
#       content  =>
#         [{ type         => 'character class',
#            content      => [ '-', '0-9', '\\f', '\\u000d' ],
#            modifier     => '+',
#            greedy       => True,
#            complemented => True }] },
#   'character class with lone hyphen and flags';
# 
#   $parsed = $g.parse(
#     q{grammar Name; number : ~non_digits+? # One ;},
#     :actions($a) ).ast;
#   is-deeply $parsed.<content>[0]<content>[0]<content>[0],
#     { type     => 'concatenation',
#       label    => 'One',
#       options  => [ ],
#       commands => [ ],
#       content  =>
#         [{ type         => 'nonterminal',
#            content      => 'non_digits',
#            modifier     => '+',
#            greedy       => True,
#            complemented => True }] },
#   'character class with lone hyphen and flags';
# 
#   $parsed = $g.parse(
#     q{grammar Name; number : 'a'..'z' # One ;},
#     :actions($a) ).ast;
#   is-deeply $parsed.<content>[0]<content>[0]<content>[0],
#     { type     => 'concatenation',
#       label    => 'One',
#       options  => [ ],
#       commands => [ ],
#       content  =>
#         [{ type         => 'range',
#            content      => [{ from => 'a',
#                               to   => 'z' }],
#            modifier     => Nil,
#            greedy       => False,
#            complemented => False }] },
#   'range';
# 
#   $parsed = $g.parse(
#     q{grammar Name; number : 'a'..'z'+? # One ;},
#     :actions($a) ).ast;
#   is-deeply $parsed.<content>[0]<content>[0]<content>[0],
#     { type     => 'concatenation',
#       label    => 'One',
#       options  => [ ],
#       commands => [ ],
#       content  =>
#         [{ type         => 'range',
#            content      => [{ from => 'a',
#                               to   => 'z' }],
#            modifier     => '+',
#            greedy       => True,
#            complemented => False }] },
#   'range with greed';
# }, 'labeled rule';
# 
# subtest sub {
#   my $parsed;
# 
#   $parsed =
#     $g.parse(
#       q{grammar Name; number : ~non_digits+? ~[-0-9\f\u000d]+? # One ;},
#       :actions($a) ).ast,
#   is-deeply $parsed.<content>[0]<content>[0],
#     { type    => 'alternation',
#       content =>
#         [{ type     => 'concatenation',
#            label    => 'One',
#            options  => [ ],
#            commands => [ ],
#            content  =>
#              [{ type         => 'nonterminal',
#                 content      => 'non_digits',
#                 modifier     => '+',
#                 greedy       => True,
#                 complemented => True },
#               { type         => 'character class',
#                 content      => [ '-', '0-9', '\\f', '\\u000d' ],
#                 modifier     => '+',
#                 greedy       => True,
#                 complemented => True }] }] },
#     'grammar, rule with multiple concatenated terms';
# 
#   $parsed =
#     $g.parse(
#       q{grammar Name; number : ~non_digits+? | ~[-0-9\f\u000d]+? # One ;},
#       :actions($a) ).ast,
#   is-deeply $parsed.<content>[0]<content>[0],
#     { type    => 'alternation',
#       content =>
#         [{ type     => 'concatenation',
#            label    => Nil,
#            options  => [ ],
#            commands => [ ],
#            content  =>
#              [{ type         => 'nonterminal',
#                 content      => 'non_digits',
#                 modifier     => '+',
#                 greedy       => True,
#                 complemented => True }] },
#          { type     => 'concatenation',
#            label    => 'One',
#            options  => [ ],
#            commands => [ ],
#            content  =>
#              [{ type         => 'character class',
#                 content      => [ '-', '0-9', '\\f', '\\u000d' ],
#                 modifier     => '+',
#                 greedy       => True,
#                 complemented => True }] }] },
#     'grammar, rule with multiple alternating terms';
# }, 'multiple terms';
# 
# # vim: ft=perl6
########################################3

# vim: ft=perl6
