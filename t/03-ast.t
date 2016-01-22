use v6;
use ANTLR4::Grammar;
use ANTLR4::Actions::AST;
use Test;

plan 20;

my $a = ANTLR4::Actions::AST.new;
my $g = ANTLR4::Grammar.new;

#
# When adding a new layer to the datastructure, do just one is-deeply() test.
#
# This way we can show the nested nature of the dataset, without having to
# continually repeat the huge data structures each time.
#
is-deeply
  $g.parse( q{grammar Minimal;}, :actions($a) ).ast,
  { type    => 'DEFAULT',
    name    => 'Minimal',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    action  => [ ],
    content => [ ] },
  q{Minimal grammar};

#
# Now check the individual keys of the current layer.
#
# Earlier we determined that the overall layout has the defaults we want,
# so just investigate each key, instead of is-deeply() on the root dataset.
#
is $g.parse( q{lexer grammar Name;}, :actions($a) ).ast.<type>,
  'lexer',
   q{Optional 'lexer' term};

subtest sub {
  my $parsed;

  plan 4;

  $parsed = $g.parse(
    q{grammar Name; options {a=2;}}, :actions($a) ).ast;
  is-deeply $parsed.<options>, [ a => 2 ],
    q{Numeric option};

  $parsed = $g.parse(
    q{grammar Name; options {a='foo';}}, :actions($a) ).ast;
  is-deeply $parsed.<options>, [ a => 'foo' ],
    q{String option};

  $parsed = $g.parse(
    q{grammar Name; options {a=b,c;}}, :actions($a) ).ast;
  is-deeply $parsed.<options>, [ a => [ 'b', 'c' ] ],
    q{List option};

  $parsed = $g.parse(
    q{grammar Name; options {a=b,c;de=3;}}, :actions($a) ).ast;
  is-deeply $parsed.<options>, [ a => [ 'b', 'c' ], de => 3 ],
    q{Multiple options};
}, q{Top-level options};

subtest sub {
  my $parsed;

  plan 2;

  $parsed = $g.parse(
    q{grammar Name; options {a=2;} import Foo;}, :actions($a) ).ast;
  is-deeply $parsed.<import>, [ Foo => Nil ],
    q{Single grammar};

  $parsed = $g.parse(
    q{grammar Name; options {a=2;} import Foo,Bar=Test;},
    :actions($a) ).ast;
  is-deeply $parsed.<import>, [ Foo => Nil, Bar => 'Test' ],
    q{Two grammars, one aliased};
}, q{Imports};

is-deeply
  $g.parse(
    q{grammar Name; tokens { INDENT, DEDENT }},
    :actions($a) ).ast.<tokens>,
  [ 'INDENT', 'DEDENT' ],
  q{Multiple tokens};

subtest sub {
  my $parsed;

  plan 2;

  $parsed = $g.parse(
    q{grammar Name;
      @members { protected int curlies = 0; }}, :actions($a) ).ast;
  is-deeply $parsed.<action>,
    [ '@members' => '{ protected int curlies = 0; }' ],
    q{Action};

  $parsed = $g.parse(
    q{grammar Name;
      @members { protected int curlies = 0; }
      @sample::stuff { 1; }}, :actions($a) ).ast;
  is-deeply $parsed.<action>,
    [ '@members' => '{ protected int curlies = 0; }',
      '@sample::stuff' => '{ 1; }' ],
    q{Multiple actions};
}, q{Actions};

#
# Show off the first actual rule.
#
is-deeply
  $g.parse(
    q{grammar Name; number : '1' ;},
    :actions($a) ).ast,
  { type    => 'DEFAULT',
    name    => 'Name',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    action  => [ ],
    content =>
      [${ type      => 'rule',
          name      => 'number',
          attribute => [ ],
          action    => Nil,
          returns   => Nil,
          throws    => [ ],
          locals    => Nil,
          options   => [ ],
          content   =>
            [${ type    => 'alternation',
                label   => Nil,
                options => [ ],
                command => [ ],
                content =>
                  [${ type    => 'concatenation',
                      label   => Nil,
                      options => [ ],
                      command => [ ],
                      content =>
                        [${ type         => 'terminal',
                            content      => '1',
                            alias        => Nil,
                            modifier     => Nil,
                            greedy       => False,
                            complemented => False }] }] }] }] },
  q{Single rule};

is-deeply
  $g.parse(
    q{grammar Name; number : '1' {action++;} ;},
    :actions($a) ).ast,
  { type    => 'DEFAULT',
    name    => 'Name',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    action  => [ ],
    content =>
      [${ type      => 'rule',
          name      => 'number',
          attribute => [ ],
          action    => Nil,
          returns   => Nil,
          throws    => [ ],
          locals    => Nil,
          options   => [ ],
          content   =>
            [${ type    => 'alternation',
                label   => Nil,
                options => [ ],
                command => [ ],
                content =>
                  [${ type    => 'concatenation',
                      label   => Nil,
                      options => [ ],
                      command => [ ],
                      content =>
                        [{ type         => 'terminal',
                           content      => '1',
                           alias        => Nil,
                           modifier     => Nil,
                           greedy       => False,
                           complemented => False },
                         { type         => 'action',
                           content      => '{action++;}',
                           alias        => Nil,
                           modifier     => Nil,
                           greedy       => False,
                           complemented => False }] }] }] }] },
  q{Single rule with associated action};

#
# Rule-level
#
is-deeply $g.parse(
  q{grammar Name; protected number : '1' ;},
   :actions($a) ).ast.<content>[0]<attribute>,
  [ 'protected' ],
  q{rule with multiple alternating terms};

subtest sub {
  my $parsed;

  plan 3;

  $parsed = $g.parse(
    q{grammar Name; number : <assoc=right> '1' ;}, :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0]<options>,
    [ assoc => 'right' ],
    q{Rule with option};

  $parsed = $g.parse(
    q{grammar Name; number : '1' # One ;}, :actions($a) ).ast;
  is $parsed.<content>[0]<content>[0]<content>[0]<label>, 'One',
    q{Rule with label};

#`(
  $parsed = $g.parse(
    q{grammar Name; number : '1' -> channel(HIDDEN) ;}, :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0]<command>,
    [ channel => 'HIDDEN' ],
    q{Rule with command};
)
}, q{Term-level flags};

is-deeply
  $g.parse(
    q{grammar Name; number : ( '1' ) ;},
    :actions($a) ).ast,
  { type    => 'DEFAULT',
    name    => 'Name',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    action  => [ ],
    content =>
      [${ type      => 'rule',
          name      => 'number',
          attribute => [ ],
          action    => Nil,
          returns   => Nil,
          throws    => [ ],
          locals    => Nil,
          options   => [ ],
          content   =>
            [${ type    => 'alternation',
                label   => Nil,
                options => [ ],
                command => [ ],
                content =>
                  [${ type    => 'concatenation',
                       label   => Nil,
                       options => [ ],
                       command => [ ],
                       content =>
                         [${ type         => 'capturing group',
                              alias        => Nil,
                              modifier     => Nil,
                              greedy       => False,
                              complemented => False,
                              content =>
                                [{ type         => 'concatenation',
                                   label        => Nil,
                                   options      => [ ],
                                   command      => [ ],
                                   content      =>
                                     [${ type         => 'terminal',
                                         content      => '1',
                                         alias        => Nil,
                                         modifier     => Nil,
                                         greedy       => False,
                                         complemented => False }] }] }] }] }] }] },
  q{Single rule with options and capturing group};

is-deeply
  $g.parse(
    q{grammar Name; number : ( '1' '2' ) -> skip ;},
    :actions($a) ).ast,
  { type    => 'DEFAULT',
    name    => 'Name',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    action  => [ ],
    content =>
      [${ type      => 'rule',
          name      => 'number',
          attribute => [ ],
          action    => Nil,
          returns   => Nil,
          throws    => [ ],
          locals    => Nil,
          options   => [ ],
          content   =>
            [{ type    => 'alternation',
               label   => Nil,
               options => [ ],
               command => [ ],
               content =>
                 [{ type    => 'concatenation',
                     label   => Nil,
                     options => [ ],
                     command => [ skip => Nil ],
                     content =>
                       [{ type         => 'capturing group',
                           alias        => Nil,
                           modifier     => Nil,
                           greedy       => False,
                           complemented => False,
                           content =>
                             [{ type    => 'alternation',
                                label   => Nil,
                                options => [ ],
                                command => [ ],
                                content =>
                                  [{ type    => 'concatenation',
                                     label   => Nil,
                                     options => [ ],
                                     command => [ ],
                                     content =>
                                       [{ type         => 'terminal',
                                          content      => '1',
                                          alias        => Nil,
                                          modifier     => Nil,
                                          greedy       => False,
                                          complemented => False },
                                        { type         => 'terminal',
                                          content      => '2',
                                          alias        => Nil,
                                          modifier     => Nil,
                                          greedy       => False,
                                          complemented => False }] }] }] }] }] }] }] },
  q{Single rule with options and skipped capturing group};

#`(
is-deeply
  $g.parse(
    q{grammar Name; number : ( '1' | '2' ) -> skip ;},
    :actions($a) ).ast,
  { type    => 'DEFAULT',
    name    => 'Name',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    action  => [ ],
    content =>
      [{ type      => 'rule',
          name      => 'number',
          attribute => [ ],
          action    => Nil,
          returns   => Nil,
          throws    => [ ],
          locals    => Nil,
          options   => [ ],
          content   =>
            [{ type    => 'alternation',
               label   => Nil,
               options => [ ],
               command => [ ],
               content =>
                 [{ type    => 'concatenation',
                     label   => Nil,
                     options => [ ],
                     command => [ skip => Nil ],
                     content =>
                       [{ type         => 'capturing group',
                          alias        => Nil,
                          modifier     => Nil,
                          greedy       => False,
                          complemented => False,
                          content =>
                            [{ type    => 'alternation',
                               label   => Nil,
                               options => [ ],
                               command => [ ],
                               content =>
                                 [{ type    => 'concatenation',
                                    label   => Nil,
                                    options => [ ],
                                    command => [ ],
                                    content =>
                                      [{ type         => 'terminal',
                                         content      => '1',
                                         alias        => Nil,
                                         modifier     => Nil,
                                         greedy       => False,
                                         complemented => False }] },
                                  { type    => 'concatenation',
                                    label   => Nil,
                                    options => [ ],
                                    command => [ ],
                                    content =>
                                      [{ type         => 'terminal',
                                         content      => '2',
                                         alias        => Nil,
                                         modifier     => Nil,
                                         greedy       => False,
                                         complemented => False }] }] }] }] }] }] }] },
  q{grammar with options and skipped capturing group};
)

#`(
is-deeply
  $g.parse(
    q{grammar Name; number : ( '1' ) -> skip ;},
    :actions($a) ).ast,
  { type    => 'DEFAULT',
    name    => 'Name',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    action  => [ ],
    content =>
      [{ type      => 'rule',
         name      => 'number',
         attribute => [ ],
         action    => Nil,
         returns   => Nil,
         throws    => [ ],
         locals    => Nil,
         options   => [ ],
         content   =>
           [{ type    => 'alternation',
              label   => Nil,
              options => [ ],
              command => [ ],
              content =>
                [${ type    => 'concatenation',
                   label   => Nil,
                   options => [ ],
                   command => [ skip => Nil ],
                   content =>
                     [{ type         => 'capturing group',
                        alias        => Nil,
                        modifier     => Nil,
                        greedy       => False,
                        complemented => False,
                        content =>
                          [{ type    => 'alternation',
                             label   => Nil,
                             options => [ ],
                             command => [ ],
                             content =>
                               [{ type    => 'concatenation',
                                  label   => Nil,
                                  options => [ ],
                                  command => [ ],
                                  content =>
                                    [{ type         => 'terminal',
                                       content      => '1',
                                       alias        => Nil,
                                       modifier     => Nil,
                                       greedy       => False,
                                       complemented => False }] }] }] }] }] }] }] },
  q{grammar with options and skipped capturing group};
)

is-deeply
  $g.parse(
    q{grammar Name; number : ( '1' )+? ;},
    :actions($a) ).ast,
  { type    => 'DEFAULT',
    name    => 'Name',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    action  => [ ],
    content =>
      [${ type      => 'rule',
          name      => 'number',
          attribute => [ ],
          action    => Nil,
          returns   => Nil,
          throws    => [ ],
          locals    => Nil,
          options   => [ ],
          content   =>
            [${ type    => 'alternation',
                label   => Nil,
                options => [ ],
                command => [ ],
                content =>
                  [${ type    => 'concatenation',
                      label   => Nil,
                      options => [ ],
                      command => [ ],
                      content =>
                        [${ type         => 'capturing group',
                            alias        => Nil,
                            modifier     => '+',
                            greedy       => True,
                            complemented => False,
                            content =>
                              [{ type         => 'concatenation',
                                 label        => Nil,
                                 options      => [ ],
                                 command      => [ ],
                                 content      =>
                                   [${ type         => 'terminal',
                                       content      => '1',
                                       alias        => Nil,
                                       modifier     => Nil,
                                       greedy       => False,
                                       complemented => False }] }] }] }] }] }] },
  q{grammar with options and single simple rule};

subtest sub {
  my $parsed;

  plan 8;

  $parsed =
    $g.parse( q{grammar Name; number : '1' ;},
              :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0],
    { type    => 'concatenation',
      label   => Nil, 
      options => [ ],
      command => [ ],
      content =>
        [${ type         => 'terminal',
            content      => '1',
            alias        => Nil,
            modifier     => Nil,
            greedy       => False,
            complemented => False }] },
    q{terminal};

  $parsed =
    $g.parse( q{grammar Name; number : ~'1'+? ;},
              :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0],
    { type    => 'concatenation',
      label   => Nil, 
      options => [ ],
      command => [ ],
      content =>
        [${ type         => 'terminal',
            content      => '1',
            alias        => Nil,
            modifier     => '+',
            greedy       => True,
            complemented => True }] },
    q{terminal with options};

  $parsed =
    $g.parse( q{grammar Name; number : digits ;},
              :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0]<content>[0],
    { type         => 'nonterminal',
      content      => 'digits',
      alias        => Nil,
      modifier     => Nil,
      greedy       => False,
      complemented => False },
    q{nonterminal};

  $parsed =
    $g.parse( q{grammar Name; number : ~digits+? ;},
              :actions($a) ).ast,
  is-deeply $parsed.<content>[0]<content>[0]<content>[0]<content>[0],
    { type         => 'nonterminal',
      content      => 'digits',
      alias        => Nil,
      modifier     => '+',
      greedy       => True,
      complemented => True },
    q{nonterminal with all flags};

#`(
  $parsed =
    $g.parse( q{grammar Name; number : [0-9] ;},
              :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0]<content>[0],
    { type         => 'character class',
      content      => [ '0-9' ],
      alias        => Nil,
      modifier     => Nil,
      greedy       => False,
      complemented => False },
    q{character class};
)

  $parsed =
    $g.parse( q{grammar Name; number : ~[0-9]+? ;},
              :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0]<content>[0],
    { type         => 'character class',
      content      => [ '0-9' ],
      alias        => Nil,
      modifier     => '+',
      greedy       => True,
      complemented => True },
    q{character class with all flags};

  $parsed =
    $g.parse( q{grammar Name; number : 'a'..'f' ;},
              :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0]<content>[0],
    { type         => 'range',
      content      => [{ from => 'a',
                         to   => 'f' }],
      alias        => Nil,
      modifier     => Nil,
      greedy       => False,
      complemented => False },
    q{range};

  $parsed =
    $g.parse( q{grammar Name; number : . ;},
              :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0]<content>[0],
    { type         => 'regular expression',
      content      => '.',
      alias        => Nil,
      modifier     => Nil,
      greedy       => False,
      complemented => False },
    q{regular expression};
}, q{rule with single term, no options};

subtest sub {
  my $parsed;

  plan 7;

#`(
  $parsed =
    $g.parse( q{grammar Name; number : ~'1'+? -> skip ;},
              :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0],
    { type    => 'concatenation',
      label   => Nil, 
      options => [ ],
      command => [ 'skip' => Nil ],
      content =>
        [{ type         => 'terminal',
           content      => '1',
           alias        => Nil,
           modifier     => '+',
           greedy       => True,
           complemented => True }] },
    q{skip};
)

#`(
  $parsed =
    $g.parse( q{grammar Name; number : ~'1'+? -> channel(HIDDEN) ;},
              :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0]<content>[0],
    { type         => 'terminal',
      content      => '1',
      alias        => Nil,
      modifier     => '+',
      greedy       => True,
      complemented => True },
    q{channeled terminal};
)

#`(
  $parsed =
    $g.parse( q{grammar Name; number : digits -> channel(HIDDEN) ;},
              :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0]<content>[0],
    { type         => 'nonterminal',
      content      => 'digits',
      alias        => Nil,
      modifier     => Nil,
      greedy       => False,
      complemented => False },
    q{Channeled rule with nonterminal};
)

#`(
  $parsed =
    $g.parse( q{grammar Name; number : ~digits+? -> channel(HIDDEN) ;},
              :actions($a) ).ast,
  is-deeply $parsed.<content>[0]<content>[0]<content>[0]<content>[0],
    { type         => 'nonterminal',
      content      => 'digits',
      alias        => Nil,
      modifier     => '+',
      greedy       => True,
      complemented => True },
    q{Channeled rule with nonterminal};
)

#`(
  $parsed =
    $g.parse( q{grammar Name; number : [0-9] -> channel(HIDDEN) ;},
              :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0]<content>[0],
    { type         => 'character class',
      content      => [ '0-9' ],
      alias        => Nil,
      modifier     => Nil,
      greedy       => False,
      complemented => False },
    q{Channeled rule with character class};
)

#`(
  $parsed =
    $g.parse( q{grammar Name; number : ~[0-9]+? -> channel(HIDDEN) ;},
              :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0]<content>[0],
    { type         => 'character class',
      content      => [ '0-9' ],
      alias        => Nil,
      modifier     => '+',
      greedy       => True,
      complemented => True },
    q{Channeled rule with character class};
)

#`(
  $parsed =
    $g.parse( q{grammar Name; number : 'a'..'f' -> channel(HIDDEN) ;},
              :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0]<content>[0],
    { type         => 'range',
      content      => [{ from => 'a',
                         to   => 'f' }],
      alias        => Nil,
      modifier     => Nil,
      greedy       => False,
      complemented => False },
    q{Channeled rule with range};
)
}, q{command};

is-deeply
  $g.parse(
    q{grammar Name;
number [int x]
       returns [int y]
       throws XFoo
       locals [int z]
       options{a=2;}
  : '1' # One ;},
    :actions($a) ).ast,
  { type    => 'DEFAULT',
    name    => 'Name',
    options => [ ],
    import  => [ ],
    tokens  => [ ],
    action  => [ ],
    content =>
      [${ type      => 'rule',
          name      => 'number',
          attribute => [ ],
          action    => '[int x]',
          returns   => '[int y]',
          throws    => [ 'XFoo' ],
          locals    => '[int z]',
          options   => [ a => 2 ],
          content   =>
            [${ type    => 'alternation',
               label   => Nil,
               options => [ ],
               command => [ ],
               content =>
                 [${ type    => 'concatenation',
                     label   => 'One',
                     options => [ ],
                     command => [ ],
                     content =>
                       [${ type         => 'terminal',
                           content      => '1',
                           alias        => Nil,
                           modifier     => Nil,
                           greedy       => False,
                           complemented => False }] }] }] }] },
  q{grammar with single labeled rule with action};

subtest sub {
  my $parsed;

  plan 9; # from outer space

  $parsed = $g.parse(
    q{grammar Name; number : ~'1'+? # One ;},
    :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0],
    { type    => 'concatenation',
      label   => 'One',
      options => [ ],
      command => [ ],
      content =>
        [${ type         => 'terminal',
            content      => '1',
            alias        => Nil,
            alias        => Nil,
            modifier     => '+',
            greedy       => True,
            complemented => True }] },
  q{rule with flags};

  $parsed = $g.parse(
    q{grammar Name; number : ~[]+? # One ;},
    :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0],
    { type    => 'concatenation',
      label   => 'One',
      options => [ ],
      command => [ ],
      content =>
        [${ type         => 'character class',
            content      => [ ],
            alias        => Nil,
            modifier     => '+',
            greedy       => True,
            complemented => True }] },
  q{character class with flags};

  $parsed = $g.parse(
    q{grammar Name; number : ~[0]+? # One ;},
    :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0],
    { type    => 'concatenation',
      label   => 'One',
      options => [ ],
      command => [ ],
      content =>
        [${ type         => 'character class',
            content      => [ '0' ],
            alias        => Nil,
            modifier     => '+',
            greedy       => True,
            complemented => True }] },
  q{character class with flags};

  $parsed = $g.parse(
    q{grammar Name; number : ~[0-9]+? # One ;},
    :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0],
    { type    => 'concatenation',
      label   => 'One',
      options => [ ],
      command => [ ],
      content =>
        [${ type         => 'character class',
            content      => [ '0-9' ],
            alias        => Nil,
            modifier     => '+',
            greedy       => True,
            complemented => True }] },
  q{character class with flags};

  $parsed = $g.parse(
    q{grammar Name; number : ~[-0-9]+? # One ;},
    :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0],
    { type    => 'concatenation',
      label   => 'One',
      options => [ ],
      command => [ ],
      content =>
        [${ type         => 'character class',
            content      => [ '-', '0-9' ],
            alias        => Nil,
            modifier     => '+',
            greedy       => True,
            complemented => True }] },
  q{character class with lone hyphen and flags};

  $parsed = $g.parse(
    q{grammar Name; number : ~[-0-9\f\u000d]+? # One ;},
    :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0],
    { type    => 'concatenation',
      label   => 'One',
      options => [ ],
      command => [ ],
      content =>
        [${ type         => 'character class',
            content      => [ '-', '0-9', '\\f', '\\u000d' ],
            alias        => Nil,
            modifier     => '+',
            greedy       => True,
            complemented => True }] },
  q{character class with lone hyphen and flags};

  $parsed = $g.parse(
    q{grammar Name; number : ~non_digits+? # One ;},
    :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0],
    { type    => 'concatenation',
      label   => 'One',
      options => [ ],
      command => [ ],
      content =>
        [${ type         => 'nonterminal',
            content      => 'non_digits',
            alias        => Nil,
            modifier     => '+',
            greedy       => True,
            complemented => True }] },
  q{character class with lone hyphen and flags};

  $parsed = $g.parse(
    q{grammar Name; number : 'a'..'z' # One ;},
    :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0],
    { type    => 'concatenation',
      label   => 'One',
      options => [ ],
      command => [ ],
      content =>
        [${ type         => 'range',
            content      => [{ from => 'a',
                               to   => 'z' }],
            alias        => Nil,
            modifier     => Nil,
            greedy       => False,
            complemented => False }] },
  q{range};

  $parsed = $g.parse(
    q{grammar Name; number : 'a'..'z'+? # One ;},
    :actions($a) ).ast;
  is-deeply $parsed.<content>[0]<content>[0]<content>[0],
    { type    => 'concatenation',
      label   => 'One',
      options => [ ],
      command => [ ],
      content =>
        [${ type         => 'range',
            content      => [{ from => 'a',
                               to   => 'z' }],
            alias        => Nil,
            modifier     => '+',
            greedy       => True,
            complemented => False }] },
  q{range with greed};
}, q{labeled rule};

subtest sub {
  my $parsed;

  plan 2;

  $parsed =
    $g.parse(
      q{grammar Name; number : ~non_digits+? ~[-0-9\f\u000d]+? # One ;},
      :actions($a) ).ast,
  is-deeply $parsed.<content>[0]<content>[0],
    { type    => 'alternation',
      label   => Nil,
      options => [ ],
      command => [ ],
      content =>
        [${ type    => 'concatenation',
            label   => 'One',
            options => [ ],
            command => [ ],
            content =>
              [{ type         => 'nonterminal',
                 content      => 'non_digits',
                 alias        => Nil,
                 modifier     => '+',
                 greedy       => True,
                 complemented => True },
               { type         => 'character class',
                 content      => [ '-', '0-9', '\\f', '\\u000d' ],
                 alias        => Nil,
                 modifier     => '+',
                 greedy       => True,
                 complemented => True }] }] },
    q{rule with multiple concatenated terms};

  $parsed =
    $g.parse(
      q{grammar Name; number : ~non_digits+? | ~[-0-9\f\u000d]+? # One ;},
      :actions($a) ).ast,
  is-deeply $parsed.<content>[0]<content>[0],
    { type    => 'alternation',
      label   => Nil,
      options => [ ],
      command => [ ],
      content =>
        [{ type    => 'concatenation',
           label   => Nil,
           options => [ ],
           command => [ ],
           content =>
             [${ type         => 'nonterminal',
                 content      => 'non_digits',
                 alias        => Nil,
                 modifier     => '+',
                 greedy       => True,
                 complemented => True }] },
         { type    => 'concatenation',
           label   => 'One',
           options => [ ],
           command => [ ],
           content =>
             [${ type         => 'character class',
                 content      => [ '-', '0-9', '\\f', '\\u000d' ],
                 alias        => Nil,
                 modifier     => '+',
                 greedy       => True,
                 complemented => True }] }] },
    q{rule with multiple alternating terms};
}, q{multiple terms};

# vim: ft=perl6
