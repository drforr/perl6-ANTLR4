use v6;
use ANTLR4::Grammar;
use ANTLR4::Actions::AST;
use Test;

plan 1;

my $a = ANTLR4::Actions::AST.new;
my $g = ANTLR4::Grammar.new;

is-deeply
  $g.parse( q{grammar Minimal;}, :actions($a) ).ast,
  { type     => 'DEFAULT',
    name     => 'Minimal',
    options  => [ ],
    imports  => [ ],
    tokens   => [ ],
    actions  => [ ],
    contents => [ ] },
  q{Minimal grammar};

#
# When adding a new layer to the datastructure, do just one is-deeply() test.
#
# This way we can show the nested nature of the dataset, without having to
# continually repeat the huge data structures each time.
#
subtest sub {
  my $parsed;

  plan 5;

  $parsed = $g.parse(
    q{lexer grammar Name;}, :actions($a) ).ast;
  is $parsed.<type>, 'lexer',
    q{Lexer};

  subtest sub {
    my $parsed;

    plan 3;

    subtest sub {
      my $parsed;

      plan 3;

      $parsed = $g.parse(
        q{grammar Name; options {a=2;}}, :actions($a) ).ast;
      is-deeply $parsed.<options>, [ a => 2 ],
        q{Numeric option};

      $parsed = $g.parse(
        q{grammar Name; options {a='foo';}}, :actions($a) ).ast;
      is-deeply $parsed.<options>, [ a => 'foo' ],
        q{String option};

      $parsed = $g.parse(
        q{grammar Name; options {a=b;}}, :actions($a) ).ast;
      is-deeply $parsed.<options>, [ a => [ 'b' ] ],
        q{Atomic option};

    }, q{Single option};

    $parsed = $g.parse(
      q{grammar Name; options {a=2;} options {b=3;}}, :actions($a) ).ast;
    is-deeply $parsed.<options>, [ a => 2, b => 3 ],
      q{Repeated single option};

    subtest sub {
      my $parsed;

      plan 2;

      $parsed = $g.parse(
        q{grammar Name; options {a=b,cde;}}, :actions($a) ).ast;
      is-deeply $parsed.<options>, [ a => [ 'b', 'cde' ] ],
        q{Multiple atomic options};

      $parsed = $g.parse(
        q{grammar Name; options {a=b,cde;f='foo';}}, :actions($a) ).ast;
      is-deeply $parsed.<options>, [ a => [ 'b', 'cde' ], f => 'foo' ],
        q{Multiple mixed options};
    }, q{Multiple options};

  }, q{Options};

  subtest sub {
    my $parsed;

    plan 2;

    $parsed = $g.parse(
      q{grammar Name; options {a=2;} import Foo;}, :actions($a) ).ast;
    is-deeply $parsed.<imports>, [ Foo => Nil ],
      q{Single import};

    subtest sub {
      my $parsed;
     
      plan 2;

      $parsed = $g.parse(
        q{grammar Name; options {a=2;} import Foo,Bar;},
        :actions($a) ).ast;
      is-deeply $parsed.<imports>, [ Foo => Nil, Bar => Nil ],
        q{Two grammars};

      $parsed = $g.parse(
        q{grammar Name; options {a=2;} import Foo,Bar=Test;},
        :actions($a) ).ast;
      is-deeply $parsed.<imports>, [ Foo => Nil, Bar => 'Test' ],
        q{Two grammars, last aliased};

    }, q{Multiple imports};

  }, q{Import};

  subtest sub {
    my $parsed;

    plan 2;

    $parsed = $g.parse(
      q{grammar Name; tokens { INDENT }},
      :actions($a) ).ast;
    is-deeply $parsed.<tokens>, [ 'INDENT' ],
      q{Single token};

    $parsed = $g.parse(
      q{grammar Name; tokens { INDENT, DEDENT }},
      :actions($a) ).ast;
    is-deeply $parsed.<tokens>, [ 'INDENT', 'DEDENT' ],
      q{Multiple tokens};

  }, q{Tokens};

  subtest sub {
    my $parsed;

    plan 2;

    $parsed = $g.parse(
      q{grammar Name; @members { protected int curlies = 0; }},
      :actions($a) ).ast;
    is-deeply $parsed.<actions>,
      [ '@members' => '{ protected int curlies = 0; }' ],
      q{Single action};

    $parsed = $g.parse(
      q{grammar Name;
        @members { protected int curlies = 0; }
        @sample::stuff { 1; }}, :actions($a) ).ast;
    is-deeply $parsed.<actions>,
      [ '@members' => '{ protected int curlies = 0; }',
        '@sample::stuff' => '{ 1; }' ],
      q{Multiple tokens};

  }, q{Actions};

}, q{Top-level keys};

is-deeply
  $g.parse(
    q{grammar Name; number : '1' ;},
    :actions($a) ).ast,
  { type     => 'DEFAULT',
    name     => 'Name',
    options  => [ ],
    imports  => [ ],
    tokens   => [ ],
    actions  => [ ],
    contents =>
      [${ type      => 'rule',
          name      => 'number',
          attribute => Nil,
          action    => Nil,
          return    => Nil,
          throws    => [ ],
          local     => Nil,
          options   => [ ],
          contents  =>
            [${ type     => 'alternation',
                label    => Nil,
                options  => [ ],
                commands => [ ],
                contents =>
                  [${ type     => 'concatenation',
                      label    => Nil,
                      options  => [ ],
                      commands => [ ],
                      contents =>
                        [${ type         => 'terminal',
                            content      => '1',
                            alias        => Nil,
                            modifier     => Nil,
                            greedy       => False,
                            complemented => False }] }] }] }] },
  q{Single rule};

subtest sub {
  my $parsed;

  plan 6;

  $parsed = $g.parse(
    q{grammar Name; number [int x] : '1' ;}, :actions($a) ).ast;
  is-deeply $parsed.<contents>[0]<action>, '[int x]',
    q{Action};

  $parsed = $g.parse(
    q{grammar Name; protected number : '1' ;}, :actions($a) ).ast;
  is-deeply $parsed.<contents>[0]<attribute>, 'protected',
    q{Attribute};

  $parsed = $g.parse(
    q{grammar Name; number returns [int x] : '1' ;}, :actions($a) ).ast;
  is-deeply $parsed.<contents>[0]<return>, '[int x]',
    q{Returns};

  subtest sub {
    my $parsed;

    plan 2;

    $parsed = $g.parse(
      q{grammar Name; number throws XFoo : '1' ;}, :actions($a) ).ast;
    is-deeply $parsed.<contents>[0]<throws>, [ 'XFoo' ],
      q{Single exception};

    $parsed = $g.parse(
      q{grammar Name; number throws XFoo, XBar : '1' ;}, :actions($a) ).ast;
    is-deeply $parsed.<contents>[0]<throws>, [ 'XFoo', 'XBar' ],
      q{Multiple exceptions};

  }, q{Throws};

  $parsed = $g.parse(
    q{grammar Name; number locals [int x] : '1' ;}, :actions($a) ).ast;
  is-deeply $parsed.<contents>[0]<local>, '[int x]',
    q{Locals};

  $parsed = $g.parse(
    q{grammar Name; number options{a=2;} : '1' ;}, :actions($a) ).ast;
  is-deeply $parsed.<contents>[0]<options>, [ a => 2 ],
    q{Options};

}, q{Rule-level keys};

diag "Nothing at the second layer, apparently";

subtest sub {
  my $parsed;

  plan 3;

  $parsed = $g.parse(
    q{grammar Name; number : '1' ;}, :actions($a) ).ast;
  is $parsed.<contents>[0]<contents>[0]<contents>[0]<type>, 'concatenation',
    q{Type};

  $parsed = $g.parse(
    q{grammar Name; number : '1' # One ;}, :actions($a) ).ast;
  is $parsed.<contents>[0]<contents>[0]<contents>[0]<label>, 'One',
    q{Label};

  $parsed = $g.parse(
    q{grammar Name; number : <assoc=right> '1' ;}, :actions($a) ).ast;
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<options>,
    [ assoc => 'right' ],
    q{Options};

  diag "Testing the command actually changes top-level stuff";

}, q{Third layer of rule};

is-deeply
  $g.parse(
    q{grammar Name; number : '1' -> channel(HIDDEN) ;},
    :actions($a) ).ast,
  { type     => 'DEFAULT',
    name     => 'Name',
    options  => [ ],
    imports  => [ ],
    tokens   => [ ],
    actions  => [ ],
    contents =>
      [${ type      => 'rule',
          name      => 'number',
          attribute => Nil,
          action    => Nil,
          return    => Nil,
          throws    => [ ],
          local     => Nil,
          options   => [ ],
          contents  =>
            [${ type     => 'alternation',
                label    => Nil,
                options  => [ ],
                commands => [ ],
                contents =>
                  [${ type     => 'concatenation',
                      label    => Nil,
                      options  => [ ],
                      commands => [ channel => 'HIDDEN' ],
                      contents =>
                        [${ type         => 'terminal',
                            content      => '1',
                            alias        => Nil,
                            modifier     => Nil,
                            greedy       => False,
                            complemented => False }] }] }] }] },
  q{Single lexer rule};

#`(
is-deeply
  $g.parse(
    q{grammar Name; number : '1' {action++;} ;},
    :actions($a) ).ast,
  { type     => 'DEFAULT',
    name     => 'Name',
    options  => [ ],
    imports  => [ ],
    tokens   => [ ],
    actions  => [ ],
    contents =>
      [${ type      => 'rule',
          name      => 'number',
          attribute => [ ],
          action    => Nil,
          return    => Nil,
          throws    => [ ],
          local     => Nil,
          options   => [ ],
          contents  =>
            [${ type     => 'alternation',
                label    => Nil,
                options  => [ ],
                commands => [ ],
                contents =>
                  [${ type     => 'concatenation',
                      label    => Nil,
                      options  => [ ],
                      commands => [ ],
                      contents =>
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

subtest sub {
  my $parsed;

  plan 3;

#`(

is-deeply
  $g.parse(
    q{grammar Name; number : ( '1' ) ;},
    :actions($a) ).ast,
  { type     => 'DEFAULT',
    name     => 'Name',
    options  => [ ],
    imports  => [ ],
    tokens   => [ ],
    actions  => [ ],
    contents =>
      [${ type      => 'rule',
          name      => 'number',
          attribute => [ ],
          action    => Nil,
          return    => Nil,
          throws    => [ ],
          local     => Nil,
          options   => [ ],
          contents  =>
            [${ type     => 'alternation',
                label    => Nil,
                options  => [ ],
                commands => [ ],
                contents =>
                  [${ type      => 'concatenation',
                       label    => Nil,
                       options  => [ ],
                       commands => [ ],
                       contents =>
                         [${ type         => 'capturing group',
                              alias        => Nil,
                              modifier     => Nil,
                              greedy       => False,
                              complemented => False,
                              content =>
                                [{ type     => 'concatenation',
                                   label    => Nil,
                                   options  => [ ],
                                   commands => [ ],
                                   content  =>
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
  { type     => 'DEFAULT',
    name     => 'Name',
    options  => [ ],
    imports  => [ ],
    tokens   => [ ],
    actions  => [ ],
    contents =>
      [${ type      => 'rule',
          name      => 'number',
          attribute => [ ],
          action    => Nil,
          return    => Nil,
          throws    => [ ],
          local     => Nil,
          options   => [ ],
          contents  =>
            [{ type     => 'alternation',
               label    => Nil,
               options  => [ ],
               commands => [ ],
               contents =>
                 [{ type      => 'concatenation',
                     label    => Nil,
                     options  => [ ],
                     commands => [ skip => Nil ],
                     contents =>
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
                                contents =>
                                  [{ type     => 'concatenation',
                                     label    => Nil,
                                     options  => [ ],
                                     commands => [ ],
                                     contents =>
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

is-deeply
  $g.parse(
    q{grammar Name; number : ( '1' | '2' ) -> skip ;},
    :actions($a) ).ast,
  { type     => 'DEFAULT',
    name     => 'Name',
    options  => [ ],
    imports  => [ ],
    tokens   => [ ],
    actions  => [ ],
    contents =>
      [${ type      => 'rule',
          name      => 'number',
          attribute => [ ],
          action    => Nil,
          return    => Nil,
          throws    => [ ],
          local     => Nil,
          options   => [ ],
          contents  =>
            [{ type     => 'alternation',
               label    => Nil,
               options  => [ ],
               commands => [ ],
               contents =>
                 [{ type      => 'concatenation',
                     label    => Nil,
                     options  => [ ],
                     commands => $[ skip => Nil ],
                     contents =>
                       [{ type         => 'capturing group',
                          alias        => Nil,
                          modifier     => Nil,
                          greedy       => False,
                          complemented => False,
                          contents     =>
                            [{ type    => 'alternation',
                               label   => Nil,
                               options => [ ],
                               command => [ ],
                               contents =>
                                 [{ type     => 'concatenation',
                                    label    => Nil,
                                    options  => [ ],
                                    commands => [ ],
                                    contents =>
                                      [{ type         => 'terminal',
                                         content      => '1',
                                         alias        => Nil,
                                         modifier     => Nil,
                                         greedy       => False,
                                         complemented => False }] },
                                  { type     => 'concatenation',
                                    label    => Nil,
                                    options  => [ ],
                                    commands => [ ],
                                    contents =>
                                      [{ type         => 'terminal',
                                         content      => '2',
                                         alias        => Nil,
                                         modifier     => Nil,
                                         greedy       => False,
                                         complemented => False }] }] }] }] }] }] }] },
  q{grammar with options and skipped capturing group};

#`(
is-deeply
  $g.parse(
    q{grammar Name; number : ( '1' ) -> skip ;},
    :actions($a) ).ast,
  { type     => 'DEFAULT',
    name     => 'Name',
    options  => [ ],
    imports  => [ ],
    tokens   => [ ],
    actions  => [ ],
    contents =>
      [{ type      => 'rule',
         name      => 'number',
         attribute => [ ],
         action    => Nil,
         return    => Nil,
         throws    => [ ],
         local     => Nil,
         options   => [ ],
         contents  =>
           [{ type     => 'alternation',
              label    => Nil,
              options  => [ ],
              commands => [ ],
              contents =>
                [${ type    => 'concatenation',
                   label    => Nil,
                   options  => [ ],
                   commands => [ skip => Nil ],
                   contents =>
                     [{ type         => 'capturing group',
                        alias        => Nil,
                        modifier     => Nil,
                        greedy       => False,
                        complemented => False,
                        contents =>
                          [{ type    => 'alternation',
                             label   => Nil,
                             options => [ ],
                             command => [ ],
                             contents =>
                               [{ type     => 'concatenation',
                                  label    => Nil,
                                  options  => [ ],
                                  commands => [ ],
                                  contents =>
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
  { type     => 'DEFAULT',
    name     => 'Name',
    options  => [ ],
    imports  => [ ],
    tokens   => [ ],
    actions  => [ ],
    contents =>
      [${ type      => 'rule',
          name      => 'number',
          attribute => [ ],
          action    => Nil,
          return    => Nil,
          throws    => [ ],
          local     => Nil,
          options   => [ ],
          contents  =>
            [${ type     => 'alternation',
                label    => Nil,
                options  => [ ],
                commands => [ ],
                contents =>
                  [${ type     => 'concatenation',
                      label    => Nil,
                      options  => [ ],
                      commands => [ ],
                      contents =>
                        [${ type         => 'capturing group',
                            alias        => Nil,
                            modifier     => '+',
                            greedy       => True,
                            complemented => False,
                            contents     =>
                              [{ type     => 'concatenation',
                                 label    => Nil,
                                 options  => [ ],
                                 commands => [ ],
                                 contents =>
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
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0],
    { type     => 'concatenation',
      label    => Nil, 
      options  => [ ],
      commands => [ ],
      contents =>
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
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0],
    { type     => 'concatenation',
      label    => Nil, 
      options  => [ ],
      commands => [ ],
      contents =>
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
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0],
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
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0],
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
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0],
    { type         => 'character class',
      contents     => [ '0-9' ],
      alias        => Nil,
      modifier     => Nil,
      greedy       => False,
      complemented => False },
    q{character class};
)

  $parsed =
    $g.parse( q{grammar Name; number : ~[0-9]+? ;},
              :actions($a) ).ast;
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0],
    { type         => 'character class',
      contents     => [ '0-9' ],
      alias        => Nil,
      modifier     => '+',
      greedy       => True,
      complemented => True },
    q{character class with all flags};

  $parsed =
    $g.parse( q{grammar Name; number : 'a'..'f' ;},
              :actions($a) ).ast;
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0],
    { type         => 'range',
      contents     => [{ from => 'a',
                         to   => 'f' }],
      alias        => Nil,
      modifier     => Nil,
      greedy       => False,
      complemented => False },
    q{range};

  $parsed =
    $g.parse( q{grammar Name; number : . ;},
              :actions($a) ).ast;
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0],
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
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0],
    { type     => 'concatenation',
      label    => Nil, 
      options  => [ ],
      commands => [ 'skip' => Nil ],
      contents =>
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
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0],
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
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0],
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
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0],
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
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0],
    { type         => 'character class',
      contents     => [ '0-9' ],
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
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0],
    { type         => 'character class',
      contents     => [ '0-9' ],
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
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0],
    { type         => 'range',
      contents     => [{ from => 'a',
                         to   => 'f' }],
      alias        => Nil,
      modifier     => Nil,
      greedy       => False,
      complemented => False },
    q{Channeled rule with range};
)
}, q{command};

subtest sub {
  my $parsed;

  plan 9; # from outer space

  $parsed = $g.parse(
    q{grammar Name; number : ~'1'+? # One ;},
    :actions($a) ).ast;
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0],
    { type     => 'concatenation',
      label    => 'One',
      options  => [ ],
      commands => [ ],
      contents =>
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
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0],
    { type     => 'concatenation',
      label    => 'One',
      options  => [ ],
      commands => [ ],
      contents =>
        [${ type         => 'character class',
            contents     => [ ],
            alias        => Nil,
            modifier     => '+',
            greedy       => True,
            complemented => True }] },
  q{character class with flags};

  $parsed = $g.parse(
    q{grammar Name; number : ~[0]+? # One ;},
    :actions($a) ).ast;
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0],
    { type     => 'concatenation',
      label    => 'One',
      options  => [ ],
      commands => [ ],
      contents =>
        [${ type         => 'character class',
            contents     => [ '0' ],
            alias        => Nil,
            modifier     => '+',
            greedy       => True,
            complemented => True }] },
  q{character class with flags};

  $parsed = $g.parse(
    q{grammar Name; number : ~[0-9]+? # One ;},
    :actions($a) ).ast;
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0],
    { type     => 'concatenation',
      label    => 'One',
      options  => [ ],
      commands => [ ],
      contents =>
        [${ type         => 'character class',
            contents     => [ '0-9' ],
            alias        => Nil,
            modifier     => '+',
            greedy       => True,
            complemented => True }] },
  q{character class with flags};

  $parsed = $g.parse(
    q{grammar Name; number : ~[-0-9]+? # One ;},
    :actions($a) ).ast;
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0],
    { type     => 'concatenation',
      label    => 'One',
      options  => [ ],
      commands => [ ],
      contents =>
        [${ type         => 'character class',
            contents     => [ '-', '0-9' ],
            alias        => Nil,
            modifier     => '+',
            greedy       => True,
            complemented => True }] },
  q{character class with lone hyphen and flags};

  $parsed = $g.parse(
    q{grammar Name; number : ~[-0-9\f\u000d]+? # One ;},
    :actions($a) ).ast;
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0],
    { type     => 'concatenation',
      label    => 'One',
      options  => [ ],
      commands => [ ],
      contents =>
        [${ type         => 'character class',
            contents     => [ '-', '0-9', '\\f', '\\u000d' ],
            alias        => Nil,
            modifier     => '+',
            greedy       => True,
            complemented => True }] },
  q{character class with lone hyphen and flags};

  $parsed = $g.parse(
    q{grammar Name; number : ~non_digits+? # One ;},
    :actions($a) ).ast;
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0],
    { type     => 'concatenation',
      label    => 'One',
      options  => [ ],
      commands => [ ],
      contents =>
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
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0],
    { type     => 'concatenation',
      label    => 'One',
      options  => [ ],
      commands => [ ],
      contents =>
        [${ type         => 'range',
            contents      => [{ from => 'a',
                               to   => 'z' }],
            alias        => Nil,
            modifier     => Nil,
            greedy       => False,
            complemented => False }] },
  q{range};

  $parsed = $g.parse(
    q{grammar Name; number : 'a'..'z'+? # One ;},
    :actions($a) ).ast;
  is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0],
    { type     => 'concatenation',
      label    => 'One',
      options  => [ ],
      commands => [ ],
      contents =>
        [${ type         => 'range',
            contents     => [{ from => 'a',
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
  is-deeply $parsed.<contents>[0]<contents>[0],
    { type     => 'alternation',
      label    => Nil,
      options  => [ ],
      commands => [ ],
      contents =>
        [${ type     => 'concatenation',
            label    => 'One',
            options  => [ ],
            commands => [ ],
            contents =>
              [{ type         => 'nonterminal',
                 content      => 'non_digits',
                 alias        => Nil,
                 modifier     => '+',
                 greedy       => True,
                 complemented => True },
               { type         => 'character class',
                 contents     => [ '-', '0-9', '\\f', '\\u000d' ],
                 alias        => Nil,
                 modifier     => '+',
                 greedy       => True,
                 complemented => True }] }] },
    q{rule with multiple concatenated terms};

  $parsed =
    $g.parse(
      q{grammar Name; number : ~non_digits+? | ~[-0-9\f\u000d]+? # One ;},
      :actions($a) ).ast,
  is-deeply $parsed.<contents>[0]<contents>[0],
    { type     => 'alternation',
      label    => Nil,
      options  => [ ],
      commands => [ ],
      contents =>
        [{ type     => 'concatenation',
           label    => Nil,
           options  => [ ],
           commands => [ ],
           contents =>
             [${ type         => 'nonterminal',
                 content      => 'non_digits',
                 alias        => Nil,
                 modifier     => '+',
                 greedy       => True,
                 complemented => True }] },
         { type     => 'concatenation',
           label    => 'One',
           options  => [ ],
           commands => [ ],
           contents =>
             [${ type         => 'character class',
                 contents     => [ '-', '0-9', '\\f', '\\u000d' ],
                 alias        => Nil,
                 modifier     => '+',
                 greedy       => True,
                 complemented => True }] }] },
    q{rule with multiple alternating terms};
}, q{multiple terms};

)
)

# vim: ft=perl6
