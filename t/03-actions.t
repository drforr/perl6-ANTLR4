use v6;
BEGIN { @*INC.push('lib') };
use ANTLR4::Grammar;
use ANTLR4::Actions::AST;
use Test;

plan 33;

my $a = ANTLR4::Actions::AST.new;
my $g = ANTLR4::Grammar.new;

#
# When adding a new layer to the datastructure, do just one is_deeply() test.
#
# This way we can show the nested nature of the dataset, without having to
# continually repeat the huge data structures each time.
#
is_deeply
  $g.parse( q{grammar Minimal;}, :actions($a) ).ast,
  { name    => 'Minimal',
    type    => Nil,
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   => [ ] },
  'Minimal grammar';

#
# Now check the individual keys of the current layer.
#
# Earlier we determined that the overall layout has the defaults we want,
# so just investigate each key, instead of is_deeply() on the root dataset.
#
{
  my $parsed;
  $parsed = $g.parse(
    q{lexer grammar Name;}, :actions($a) ).ast;
  is $parsed.<type>, 'lexer';
}

{
  my $parsed;
  $parsed = $g.parse(
    q{lexer grammar Name; options {a=2;}}, :actions($a) ).ast;
  is_deeply $parsed.<options>, [ a => 2 ];
  $parsed = $g.parse(
    q{lexer grammar Name; options {a='foo';}}, :actions($a) ).ast;
  is_deeply $parsed.<options>, [ a => 'foo' ];
  $parsed = $g.parse(
    q{lexer grammar Name; options {a=b,c;}}, :actions($a) ).ast;
  is_deeply $parsed.<options>, [ a => [ 'b', 'c' ] ];
  $parsed = $g.parse(
    q{lexer grammar Name; options {a=b,c;de=3;}}, :actions($a) ).ast;
  is_deeply $parsed.<options>, [ a => [ 'b', 'c' ], de => 3 ];
}

{
  my $parsed;
  $parsed = $g.parse(
    q{lexer grammar Name; options {a=2;} import Foo;}, :actions($a) ).ast;
  is_deeply $parsed.<import>, [ Foo => Nil ];
  $parsed = $g.parse(
    q{lexer grammar Name; options {a=2;} import Foo,Bar=Test;},
    :actions($a) ).ast;
  is_deeply $parsed.<import>, [ Foo => Nil, Bar => 'Test' ];
}

{
  my $parsed;
  $parsed = $g.parse(
    q{lexer grammar Name;
      @members { protected int curlies = 0; }}, :actions($a) ).ast;
  is_deeply $parsed.<actions>,
    [ '@members' => '{ protected int curlies = 0; }' ];

  $parsed = $g.parse(
    q{lexer grammar Name;
      @members { protected int curlies = 0; }
      @sample::stuff { 1; }}, :actions($a) ).ast;
  is_deeply $parsed.<actions>,
    [ '@members' => '{ protected int curlies = 0; }',
      '@sample::stuff' => '{ 1; }' ];
}

#
# Show off the first actual rule.
#
is_deeply
  $g.parse(
    q{lexer grammar Name;
options {a=b,c;de=3;}
import Foo,Bar=Test;
tokens { Foo, Bar }
@members { protected int curlies = 0; }
@sample::stuff { 1; }
number : '1' ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options =>
      [ a => [ 'b', 'c' ],
        de => 3 ],
    import  =>
      [ Foo => Nil,
        Bar => 'Test' ],
    tokens  => [ 'Foo', 'Bar' ],
    actions =>
      [ '@members'       => '{ protected int curlies = 0; }',
        '@sample::stuff' => '{ 1; }' ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => Nil,
                   options  => [ ],
                   commands => [ ],
                   content  =>
                     [{ type         => 'terminal',
                        content      => '1',
                        modifier     => Nil,
                        greedy       => False,
                        complemented => False }] }] }] }] },
  'grammar with options and single simple rule';

{
  my $parsed = $g.parse(
    q{lexer grammar Name; number : <assoc=right> '1' ;}, :actions($a) ).ast;

  is_deeply $parsed.<rules>[0]<content>[0]<content>[0]<options>,
    [ assoc => 'right' ];
}

is_deeply
  $g.parse(
    q{lexer grammar Name; number : ( '1' )+? ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => Nil,
                   options  => [ ],
                   commands => [ ],
                   content  =>
                     [{ type         => 'capturing group',
                        modifier     => '+',
                        greedy       => True,
                        complemented => False,
                        content =>
                          [{ type         => 'alternation',
                             content      =>
                               [{ type         => 'terminal',
                                  content      => '1',
                                  modifier     => Nil,
                                  greedy       => False,
                                  complemented => False }] }] }] }] }] }] },
  'grammar with options and single simple rule';

is_deeply
  $g.parse(
    q{lexer grammar Name; number : '1' # One ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => 'One',
                   options  => [ ],
                   commands => [ ],
                   content  =>
                     [{ type         => 'terminal',
                        content      => '1',
                        modifier     => Nil,
                        greedy       => False,
                        complemented => False }] }] }] }] },
  'grammar with single labeled rule';

is_deeply
  $g.parse(
    q{lexer grammar Name; number : '1' -> channel(HIDDEN) ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => Nil, 
                   options  => [ ],
                   commands => [ 'channel' => 'HIDDEN' ],
                   content  =>
                     [{ type         => 'terminal',
                        content      => '1',
                        modifier     => Nil,
                        greedy       => False,
                        complemented => False }] }] }] }] },
  'grammar with single channeled rule';

is_deeply
  $g.parse(
    q{lexer grammar Name; number : ~'1'+? -> channel(HIDDEN) ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => Nil, 
                   options  => [ ],
                   commands => [ 'channel' => 'HIDDEN' ],
                   content  =>
                     [{ type         => 'terminal',
                        content      => '1',
                        modifier     => '+',
                        greedy       => True,
                        complemented => True }] }] }] }] },
  'grammar with single channeled rule';

is_deeply
  $g.parse(
    q{lexer grammar Name; number : digits -> channel(HIDDEN) ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => Nil, 
                   options  => [ ],
                   commands => [ 'channel' => 'HIDDEN' ],
                   content  =>
                     [{ type         => 'nonterminal',
                        content      => 'digits',
                        modifier     => Nil,
                        greedy       => False,
                        complemented => False }] }] }] }] },
  'grammar with single channeled rule';

is_deeply
  $g.parse(
    q{lexer grammar Name; number : ~digits+? -> channel(HIDDEN) ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => Nil, 
                   options  => [ ],
                   commands => [ 'channel' => 'HIDDEN' ],
                   content  =>
                     [{ type         => 'nonterminal',
                        content      => 'digits',
                        modifier     => '+',
                        greedy       => True,
                        complemented => True }] }] }] }] },
  'grammar with single channeled rule and all flags';

is_deeply
  $g.parse(
    q{lexer grammar Name; number : [0-9] -> channel(HIDDEN) ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => Nil, 
                   options  => [ ],
                   commands => [ 'channel' => 'HIDDEN' ],
                   content  =>
                     [{ type         => 'character class',
                        content      => [ '0-9' ],
                        modifier     => Nil,
                        greedy       => False,
                        complemented => False }] }] }] }] },
  'grammar with single channeled rule';

is_deeply
  $g.parse(
    q{lexer grammar Name;
number [int x]
       returns [int y]
       throws XFoo
       locals [int z]
       options{a=2;}
  : '1' # One ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => '[int x]',
         returns  => '[int y]',
         throws   => [ 'XFoo' ],
         locals   => '[int z]',
         options  => [ a => 2 ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => 'One',
                   options  => [ ],
                   commands => [ ],
                   content  =>
                     [{ type         => 'terminal',
                        content      => '1',
                        modifier     => Nil,
                        greedy       => False,
                        complemented => False }] }] }] }] },
  'grammar with single labeled rule with action';

is_deeply
  $g.parse(
    q{lexer grammar Name; number : '1'+ # One ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  => 
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => 'One',
                   options  => [ ],
                   commands => [ ],
                   content  =>
                     [{ type         => 'terminal',
                        content      => '1',
                        modifier     => '+',
                        greedy       => False,
                        complemented => False }] }] }] }] },
  'grammar with options and labeled rule with modifier';

is_deeply
  $g.parse(
    q{lexer grammar Name; number : '1'+? # One ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => 'One',
                   options  => [ ],
                   commands => [ ],
                   content  =>
                     [{ type         => 'terminal',
                        content      => '1',
                        modifier     => '+',
                        greedy       => True,
                        complemented => False }] }] }] }] },
  'grammar with options and labeled rule with greedy modifier';

is_deeply
  $g.parse(
    q{lexer grammar Name; number : ~'1'+? # One ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => 'One',
                   options  => [ ],
                   commands => [ ],
                   content  =>
                     [{ type         => 'terminal',
                        content      => '1',
                        modifier     => '+',
                        greedy       => True,
                        complemented => True }] }] }] }] },
  'grammar, rule with complemented terminal';

is_deeply
  $g.parse(
    q{lexer grammar Name; number : ~[]+? # One ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => 'One',
                   options  => [ ],
                   commands => [ ],
                   content  =>
                     [{ type         => 'character class',
                        content      => [ ],
                        modifier     => '+',
                        greedy       => True,
                        complemented => True }] }] }] }] },
  'grammar, rule with empty character class';

is_deeply
  $g.parse(
    q{lexer grammar Name; number : ~[0]+? # One ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => 'One',
                   options  => [ ],
                   commands => [ ],
                   content  =>
                     [{ type         => 'character class',
                        content      => [ '0' ],
                        modifier     => '+',
                        greedy       => True,
                        complemented => True }] }] }] }] },
  'grammar, rule with character class';

is_deeply
  $g.parse(
    q{lexer grammar Name; number : ~[0-9]+? # One ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => 'One',
                   options  => [ ],
                   commands => [ ],
                   content  =>
                     [{ type         => 'character class',
                        content      => [ '0-9' ],
                        modifier     => '+',
                        greedy       => True,
                        complemented => True }] }] }] }] },
  'grammar, rule with hyphenated character class';

is_deeply
  $g.parse(
    q{lexer grammar Name; number : ~[-0-9]+? # One ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => 'One',
                   options  => [ ],
                   commands => [ ],
                   content  =>
                     [{ type         => 'character class',
                        content      => [ '-', '0-9' ],
                        modifier     => '+',
                        greedy       => True,
                        complemented => True }] }] }] }] },
  'grammar, rule with leading hyphenated character class';

is_deeply
  $g.parse(
    q{lexer grammar Name; number : ~[-0-9\f\u000d]+? # One ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => 'One',
                   options  => [ ],
                   commands => [ ],
                   content  =>
                     [{ type         => 'character class',
                        content      => [ '-', '0-9', '\\f', '\\u000d' ],
                        modifier     => '+',
                        greedy       => True,
                        complemented => True }] }] }] }] },
  'grammar, rule with christmas-tree character class';

is_deeply
  $g.parse(
    q{lexer grammar Name; number : ~non_digits+? # One ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => 'One',
                   options  => [ ],
                   commands => [ ],
                   content  =>
                     [{ type         => 'nonterminal',
                        content      => 'non_digits',
                        modifier     => '+',
                        greedy       => True,
                        complemented => True }] }] }] }] },
  'grammar, rule with complemented nonterminal';

is_deeply
  $g.parse(
    q{lexer grammar Name; number : 'a'..'z'+? # One ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => 'One',
                   options  => [ ],
                   commands => [ ],
                   content  =>
                     [{ type         => 'range',
			content      => [{ from => 'a',
                                           to   => 'z' }],
                        modifier     => '+',
                        greedy       => True,
                        complemented => False }] }] }] }] },
  'grammar, rule with range literal';

is_deeply
  $g.parse(
    q{lexer grammar Name; number : ~non_digits+? ~[-0-9\f\u000d]+? # One ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => 'One',
                   options  => [ ],
                   commands => [ ],
                   content  =>
                     [{ type         => 'nonterminal',
                        content      => 'non_digits',
                        modifier     => '+',
                        greedy       => True,
                        complemented => True },
                      { type         => 'character class',
                        content      => [ '-', '0-9', '\\f', '\\u000d' ],
                        modifier     => '+',
                        greedy       => True,
                        complemented => True }] }] }] }] },
  'grammar, rule with multiple concatenated terms';

is_deeply
  $g.parse(
    q{lexer grammar Name; number : ~non_digits+? | ~[-0-9\f\u000d]+? # One ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => Nil,
                   options  => [ ],
                   commands => [ ],
                   content  =>
                     [{ type         => 'nonterminal',
                        content      => 'non_digits',
                        modifier     => '+',
                        greedy       => True,
                        complemented => True }] },
                 { type     => 'concatenation',
                   label    => 'One',
                   options  => [ ],
                   commands => [ ],
                   content  =>
                     [{ type         => 'character class',
                        content      => [ '-', '0-9', '\\f', '\\u000d' ],
                        modifier     => '+',
                        greedy       => True,
                        complemented => True }] }] }] }] },
  'grammar, rule with multiple alternating terms';

is_deeply
  $g.parse(
    q{lexer grammar Name; protected number : ~non_digits+? | ~[-0-9\f\u000d]+? # One ;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   =>
      [{ name     => 'number',
         modifier => [ 'protected' ],
         action   => Nil,
         returns  => Nil,
         throws   => [ ],
         locals   => Nil,
         options  => [ ],
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type     => 'concatenation',
                   label    => Nil,
                   options  => [ ],
                   commands => [ ],
                   content  =>
                     [{ type         => 'nonterminal',
                        content      => 'non_digits',
                        modifier     => '+',
                        greedy       => True,
                        complemented => True }] },
                 { type     => 'concatenation',
                   label    => 'One',
                   options  => [ ],
                   commands => [ ],
                   content  =>
                     [{ type         => 'character class',
                        content      => [ '-', '0-9', '\\f', '\\u000d' ],
                        modifier     => '+',
                        greedy       => True,
                        complemented => True }] }] }] }] },
  'grammar, rule with multiple alternating terms';

# vim: ft=perl6
