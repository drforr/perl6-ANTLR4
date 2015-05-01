use v6;
BEGIN { @*INC.push('lib') };
use ANTLR4::Grammar;
use ANTLR4::Actions;
use Test;

plan 26;

my $a = ANTLR4::Actions.new;
my $g = ANTLR4::Grammar.new;

is_deeply
  $g.parse( q{grammar Name;}, :actions($a) ).ast,
  { name    => 'Name',
    type    => Nil,
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   => [ ] },
  'minimal file';

is_deeply
  $g.parse( q{lexer grammar Name;}, :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   => [ ] },
  'minimal lexer grammar';

is_deeply
  $g.parse( q{lexer grammar Name; options {a=2;}}, :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options =>
      [ a => 2 ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   => [ ] },
  'lexer grammar with option';

is_deeply
  $g.parse( q{lexer grammar Name; options {a='foo';}}, :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options =>
      [ a => 'foo' ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   => [ ] },
  'lexer grammar with option';

is_deeply
  $g.parse( q{lexer grammar Name; options {a=b,c;}}, :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options =>
      [ a => [ 'b', 'c' ] ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   => [ ] },
  'lexer grammar with complex option';

is_deeply
  $g.parse( q{lexer grammar Name; options {a=b,c;de=3;}}, :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options =>
      [ a => [ 'b', 'c' ],
        de => 3 ],
    import  => [ ],
    tokens  => [ ],
    actions => [ ],
    rules   => [ ] }, 'lexer grammar with complex options';

is_deeply
  $g.parse(
    q{lexer grammar Name; options {a=b,c;de=3;} import Foo;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options =>
      [ a => [ 'b', 'c' ],
        de => 3 ],
    import  =>
      [ Foo => Nil ],
    tokens  => [ ],
    actions => [ ],
    rules   => [ ] },
  'lexer grammar with options and import';

is_deeply
  $g.parse(
    q{lexer grammar Name; options {a=b,c;de=3;} import Foo,Bar=Test;},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options =>
      [ a => [ 'b', 'c' ],
        de => 3 ],
    import  =>
      [ Foo => Nil,
        Bar => 'Test' ],
    tokens  => [ ],
    actions => [ ],
    rules   => [ ] },
  'lexer grammar with options and imports';

#
# XXX tokens should really be a set, come to think of it.
#
is_deeply
  $g.parse(
    q{lexer grammar Name; options {a=b,c;de=3;} import Foo,Bar=Test; tokens { Foo, Bar }},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options =>
      [ a => [ 'b', 'c' ],
        de => 3 ],
    import  =>
      [ Foo => Nil,
        Bar => 'Test' ],
    tokens  =>
      [ 'Foo', 'Bar' ],
    actions => [ ],
    rules   => [ ] },
  'lexer grammar with options, imports and tokens';

is_deeply
  $g.parse(
    q{lexer grammar Name; options {a=b,c;de=3;} import Foo,Bar=Test; tokens { Foo, Bar } @members { protected int curlies = 0; }},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options =>
      [ a => [ 'b', 'c' ],
        de => 3 ],
    import  =>
      [ Foo => Nil,
        Bar => 'Test' ],
    tokens  =>
      [ 'Foo', 'Bar' ],
    actions =>
      [ '@members' => '{ protected int curlies = 0; }' ],
    rules   => [ ] },
  'lexer grammar with options, imports, tokens and action';

is_deeply
  $g.parse(
    q{lexer grammar Name;
options {a=b,c;de=3;}
import Foo,Bar=Test;
tokens { Foo, Bar }
@members { protected int curlies = 0; }},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options =>
      [ a => [ 'b', 'c' ],
        de => 3 ],
    import  =>
      [ Foo => Nil,
        Bar => 'Test' ],
    tokens  =>
      [ 'Foo', 'Bar' ],
    actions =>
      [ '@members'       => '{ protected int curlies = 0; }' ],
    rules   => [ ] },
  'lexer grammar with options, imports, tokens and action';

is_deeply
  $g.parse(
    q{lexer grammar Name;
options {a=b,c;de=3;}
import Foo,Bar=Test;
tokens { Foo, Bar }
@members { protected int curlies = 0; }
@sample::stuff { 1; }},
    :actions($a) ).ast,
  { name    => 'Name',
    type    => 'lexer',
    options =>
      [ a => [ 'b', 'c' ],
        de => 3 ],
    import  =>
      [ Foo => Nil,
        Bar => 'Test' ],
    tokens  =>
      [ 'Foo', 'Bar' ],
    actions =>
      [ '@members'       => '{ protected int curlies = 0; }',
        '@sample::stuff' => '{ 1; }' ],
    rules   => [ ] },
  'lexer grammar with all the options, no rules yet';

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
    tokens  =>
      [ 'Foo', 'Bar' ],
    actions =>
      [ '@members'       => '{ protected int curlies = 0; }',
        '@sample::stuff' => '{ 1; }' ],
    rules   =>
      [{ name     => 'number',
         modifier => [ ],
         content  =>
           [{ type => 'alternation',
              content =>
                [{ type    => 'concatenation',
                   label   => Nil,
                   content => [{ type         => 'terminal',
                                 content      => '1',
                                 modifier     => Nil,
                                 greedy       => False,
                                 complemented => False }] }] }] }] },
  'lexer grammar with options and single simple rule';

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
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type    => 'concatenation',
                   label   => 'One',
                   content => [{ type         => 'terminal',
                                 content      => '1',
                                 modifier     => Nil,
                                 greedy       => False,
                                 complemented => False }] }] }] }] },
  'lexer grammar with single labeled rule';

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
         content  => 
           [{ type    => 'alternation',
              content =>
                [{ type    => 'concatenation',
                   label   => 'One',
                   content => [{ type         => 'terminal',
                                 content      => '1',
                                 modifier     => '+',
                                 greedy       => False,
                                 complemented => False }] }] }] }] },
  'lexer grammar with options and labeled rule with modifier';

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
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type    => 'concatenation',
                   label   => 'One',
                   content => [{ type         => 'terminal',
                                 content      => '1',
                                 modifier     => '+',
                                 greedy       => True,
                                 complemented => False }] }] }] }] },
  'lexer grammar with options and labeled rule with greedy modifier';

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
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type    => 'concatenation',
                   label   => 'One',
                   content => [{ type         => 'terminal',
                                 content      => '1',
                                 modifier     => '+',
                                 greedy       => True,
                                 complemented => True }] }] }] }] },
  'lexer grammar, rule with complemented terminal';

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
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type    => 'concatenation',
                   label   => 'One',
                   content => [{ type         => 'character class',
                                 content      => [ ],
                                 modifier     => '+',
                                 greedy       => True,
                                 complemented => True }] }] }] }] },
  'lexer grammar, rule with empty character class';

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
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type    => 'concatenation',
                   label   => 'One',
                   content => [{ type         => 'character class',
                                 content      => [ '0' ],
                                 modifier     => '+',
                                 greedy       => True,
                                 complemented => True }] }] }] }] },
  'lexer grammar, rule with character class';

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
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type    => 'concatenation',
                   label   => 'One',
                   content => [{ type         => 'character class',
                                 content      => [ '0-9' ],
                                 modifier     => '+',
                                 greedy       => True,
                                 complemented => True }] }] }] }] },
  'lexer grammar, rule with hyphenated character class';

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
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type    => 'concatenation',
                   label   => 'One',
                   content => [{ type         => 'character class',
                                 content      =>
                                   [ '-', '0-9' ],
                                 modifier     => '+',
                                 greedy       => True,
                                 complemented => True }] }] }] }] },
  'lexer grammar, rule with leading hyphenated character class';

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
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type    => 'concatenation',
                   label   => 'One',
                   content => [{ type         => 'character class',
                                 content      =>
                                   [ '-', '0-9', '\\f', '\\u000d' ],
                                 modifier     => '+',
                                 greedy       => True,
                                 complemented => True }] }] }] }] },
  'lexer grammar, rule with christmas-tree character class';

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
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type    => 'concatenation',
                   label   => 'One',
                   content => [{ type         => 'nonterminal',
                                 content      => 'non_digits',
                                 modifier     => '+',
                                 greedy       => True,
                                 complemented => True }] }] }] }] },
  'lexer grammar, rule with complemented nonterminal';

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
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type    => 'concatenation',
                   label   => 'One',
                   content => [{ type         => 'nonterminal',
                                 content      => 'non_digits',
                                 modifier     => '+',
                                 greedy       => True,
                                 complemented => True },
                               { type         => 'character class',
                                 content      =>
                                   [ '-', '0-9', '\\f', '\\u000d' ],
                                 modifier     => '+',
                                 greedy       => True,
                                 complemented => True }] }] }] }] },
  'lexer grammar, rule with multiple concatenated terms';

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
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type    => 'concatenation',
                   label   => Nil,
                   content =>
                     [{ type         => 'nonterminal',
                        content      => 'non_digits',
                        modifier     => '+',
                        greedy       => True,
                        complemented => True }] },
                 { type    => 'concatenation',
                   label   => 'One',
                   content =>
                     [{ type         => 'character class',
                        content      =>
                          [ '-', '0-9', '\\f', '\\u000d' ],
                        modifier     => '+',
                        greedy       => True,
                        complemented => True }] }] }] }] },
  'lexer grammar, rule with multiple alternating terms';

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
         content  =>
           [{ type    => 'alternation',
              content =>
                [{ type    => 'concatenation',
                   label   => Nil,
                   content =>
                     [{ type         => 'nonterminal',
                        content      => 'non_digits',
                        modifier     => '+',
                        greedy       => True,
                        complemented => True }] },
                 { type    => 'concatenation',
                   label   => 'One',
                   content =>
                     [{ type         => 'character class',
                        content      =>
                          [ '-', '0-9', '\\f', '\\u000d' ],
                        modifier     => '+',
                        greedy       => True,
                        complemented => True }] }] }] }] },
  'lexer grammar, rule with multiple alternating terms';

# vim: ft=perl6
