use v6;
use ANTLR4::Actions::Perl6;
use Test;

plan 9;

my $p = ANTLR4::Actions::Perl6.new;

subtest sub {
  is $p.parse( q{grammar Minimal;} ).perl6,
     'grammar Minimal {  }',
     'minimal grammar';

  is $p.parse( q{lexer grammar Minimal;} ).perl6,
     'grammar Minimal {  } #={ "type" : "lexer" }',
     'optional type';
  is $p.parse( q{grammar Minimal; options {a=2;}} ).perl6,
     'grammar Minimal {  } #={ "options" : [ { "a" : 2 } ] }',
     'optional options';
  is $p.parse( q{grammar Minimal; import Foo;} ).perl6,
     'grammar Minimal {  } #={ "import" : [ { "Foo" : null } ] }',
     'optional import';
  is $p.parse( q{grammar Minimal; tokens { INDENT, DEDENT }} ).perl6,
     'grammar Minimal {  } #={ "tokens" : [ "INDENT", "DEDENT" ] }',
     'optional tokens';
  is $p.parse( q{grammar Minimal; @members { int i = 0; }} ).perl6,
     'grammar Minimal {  } #={ "action" : [ { "@members" : "{ int i = 0; }" } ] }',
     'optional actions';
}, 'Grammar and its options';

subtest sub {
  is $p.parse( q{grammar Minimal; number : '1' ;}).perl6,
     q{grammar Minimal { rule number { '1' } }},
     'minimal rule';

  subtest sub {
    is $p.parse( q{grammar Minimal; number : '1'* ;}).perl6,
       q{grammar Minimal { rule number { '1'* } }},
       'star';
    is $p.parse( q{grammar Minimal; number : '1'+ ;}).perl6,
       q{grammar Minimal { rule number { '1'+ } }},
       'plus';
    is $p.parse( q{grammar Minimal; number : ~'1' ;}).perl6,
       q{grammar Minimal { rule number { !'1' } }},
       'complement';

    is $p.parse( q{grammar Minimal; number : '1'*? ;}).perl6,
       q{grammar Minimal { rule number { '1'*? } }},
       'greedy star';
  }, 'terminal with options';

  subtest sub {
    is $p.parse( q{grammar Minimal; number : 'a' ;}).perl6,
       q{grammar Minimal { rule number { 'a' } }},
       'alpha terminal';

    is $p.parse( q{grammar Minimal; number : 'a123b' ;}).perl6,
       q{grammar Minimal { rule number { 'a123b' } }},
       'mixed alphanumeric terminal';

    is $p.parse( q{grammar Minimal; number : '\u263a' ;}).perl6,
       q{grammar Minimal { rule number { '\x[263a]' } }},
       'Unicode terminal';
  }, 'terminal of different types';

  is $p.parse( q{grammar Minimal; protected number : '1';}).perl6,
     q{grammar Minimal { rule number { '1' } #={ "attribute" : "protected" } }},
     'rule with attribute';
  is $p.parse( q{grammar Minimal; number [int x] : '1';}).perl6,
     q{grammar Minimal { rule number { '1' } #={ "action" : "[int x]" } }},
     'optional action';
  is $p.parse( q{grammar Minimal; number returns [int x] : '1';}).perl6,
     q{grammar Minimal { rule number { '1' } #={ "returns" : "[int x]" } }},
     'optional return type';
  is $p.parse( q{grammar Minimal; number throws XFoo : '1';}).perl6,
     q{grammar Minimal { rule number { '1' } #={ "throws" : [ "XFoo" ] } }},
   is $p.parse( q{grammar Minimal; number locals [int y] : '1';}).perl6,
     q{grammar Minimal { rule number { '1' } #={ "locals" : "[int y]" } }},
     'optional exception';
  is $p.parse( q{grammar Minimal; number options{a=2;} : '1';}).perl6,
     q{grammar Minimal { rule number { '1' } #={ "options" : [ { "a" : 2 } ] } }},
     'optional local variables';
}, 'Single rule and rule-level options';

subtest sub {
  is $p.parse( q{grammar Minimal; number : <assoc=right> '1' ;}).perl6,
     q{grammar Minimal { rule number { '1' #={ "options" : [ { "assoc" : "right" } ] } } }},
     'optional option';
  is $p.parse( q{grammar Minimal; number : '1' # One ;}).perl6,
     q{grammar Minimal { rule number { '1' #={ "label" : "One" } } }},
     'optional label';
  is $p.parse( q{grammar Minimal; number : '1' -> skip ;}).perl6,
     q{grammar Minimal { rule number { '1' #={ "command" : [ { "skip" : null } ] } } }},
     'optional command';
  is $p.parse( q{grammar Minimal; number : {$amount = 0;} '1' ;}).perl6,
     q{grammar Minimal { rule number {  #={ "content" : "{$amount = 0;}" } '1' } }},
     'optional action';
}, 'Single rule and term-level options';

subtest sub {
  is $p.parse( q{grammar Minimal; number : ab ;}).perl6,
     q{grammar Minimal { rule number { <ab> } }},
     'non-terminal';

  subtest sub {
    is $p.parse( q{grammar Minimal; number : ab* ;}).perl6,
       q{grammar Minimal { rule number { <ab>* } }},
       'star';
    is $p.parse( q{grammar Minimal; number : ab+ ;}).perl6,
       q{grammar Minimal { rule number { <ab>+ } }},
       'plus';
    is $p.parse( q{grammar Minimal; number : ~ab ;}).perl6,
       q{grammar Minimal { rule number { <!ab> } }},
       'complement';

    is $p.parse( q{grammar Minimal; number : ab*? ;}).perl6,
       q{grammar Minimal { rule number { <ab>*? } }},
       'greedy star';
  }, 'non-terminal modifiers';

  is $p.parse( q{grammar Minimal; number : 'a'..'z' ;}).perl6,
     q{grammar Minimal { rule number { 'a'..'z' } }},
     'range';

  is $p.parse( q{grammar Minimal; number : '\u263a'..'\u263f' ;}).perl6,
     q{grammar Minimal { rule number { '\x[263a]'..'\x[263f]' } }},
     'Unicode range';

  subtest sub {
    is $p.parse( q{grammar Minimal; number : 'a'..'z'* ;}).perl6,
       q{grammar Minimal { rule number { 'a'..'z'* } }},
       'star';
    is $p.parse( q{grammar Minimal; number : 'a'..'z'+ ;}).perl6,
       q{grammar Minimal { rule number { 'a'..'z'+ } }},
       'plus';
    #
    # The grammar doesn't allow ~'a'..'z', so skip it.
    #
    #is $p.parse( q{grammar Minimal; number : ~'a'..'z' ;}).perl6,
    #   q{grammar Minimal { rule number { ( ( !'a'..z' ) ) } }},
    #   'complement';

    is $p.parse( q{grammar Minimal; number : 'a'..'z'*? ;}).perl6,
       q{grammar Minimal { rule number { 'a'..'z'*? } }},
       'greedy star';
  }, 'range modifiers';

  is $p.parse( q{grammar Minimal; number : [] ;}).perl6,
     q{grammar Minimal { rule number { <[  ]> } }},
     'empty character class';

  subtest sub {
    is $p.parse( q{grammar Minimal; number : []* ;}).perl6,
       q{grammar Minimal { rule number { <[  ]>* } }},
       'star';
    is $p.parse( q{grammar Minimal; number : []+ ;}).perl6,
       q{grammar Minimal { rule number { <[  ]>+ } }},
       'plus';
    is $p.parse( q{grammar Minimal; number : ~[] ;}).perl6,
       q{grammar Minimal { rule number { <-[  ]> } }},
       'complement';

    is $p.parse( q{grammar Minimal; number : []*? ;}).perl6,
       q{grammar Minimal { rule number { <[  ]>*? } }},
       'greedy star';
  }, 'empty character class modifiers';

  is $p.parse( q{grammar Minimal; number : [a] ;}).perl6,
     q{grammar Minimal { rule number { <[ a ]> } }},
     'character class';

  is $p.parse( q{grammar Minimal; number : [ ] ;}).perl6,
     q{grammar Minimal { rule number { <[ ' ' ]> } }},
     'character class';

  subtest sub {
    is $p.parse( q{grammar Minimal; number : [a]* ;}).perl6,
       q{grammar Minimal { rule number { <[ a ]>* } }},
       'star';
    is $p.parse( q{grammar Minimal; number : [a]+ ;}).perl6,
       q{grammar Minimal { rule number { <[ a ]>+ } }},
       'plus';
    is $p.parse( q{grammar Minimal; number : ~[a] ;}).perl6,
       q{grammar Minimal { rule number { <-[ a ]> } }},
       'complement';

    is $p.parse( q{grammar Minimal; number : [a]*? ;}).perl6,
       q{grammar Minimal { rule number { <[ a ]>*? } }},
       'greedy star';
  }, 'character class modifiers';

  subtest sub {
    is $p.parse( q{grammar Minimal; number : [a-b] ;}).perl6,
       q{grammar Minimal { rule number { <[ a .. b ]> } }},
       'hyphenated character class';
  
    is $p.parse( q{grammar Minimal; number : [-a-b] ;}).perl6,
       q{grammar Minimal { rule number { <[ - a .. b ]> } }},
       'hyphenated character class';
  
    is $p.parse( q{grammar Minimal; number : [-a-b\u000d] ;}).perl6,
       q{grammar Minimal { rule number { <[ - a .. b \\x[000d] ]> } }},
       'Unicode character class';
  }, 'character class variants';

  is $p.parse( q{grammar Minimal; number : . ;}).perl6,
     q{grammar Minimal { rule number { . } }},
     'regular expression';
}, 'Single rule and remaining basic term types';

subtest sub {
  is $p.parse( q{grammar Minimal; number : 'a' 'b';}).perl6,
     q{grammar Minimal { rule number { 'a' 'b' } }},
     'two concatenated terms';
  is $p.parse( q{grammar Minimal; number : 'a' 'b' -> skip ;}).perl6,
     q{grammar Minimal { rule number { 'a' 'b' #={ "command" : [ { "skip" : null } ] } } }},
     'two concatenated terms with skipping';
}, 'concatenation test';

subtest sub {
  is $p.parse( q{grammar Minimal; number : 'a' | ;}).perl6,
     q{grammar Minimal { rule number { 'a' | (Nil) } }},
     'one term with blank alternation';
  is $p.parse( q{grammar Minimal; number : 'a' | 'b';}).perl6,
     q{grammar Minimal { rule number { 'a' | 'b' } }},
     'two alternated terms';
  is $p.parse( q{grammar Minimal; number : 'a' | 'b' -> skip ;}).perl6,
     q{grammar Minimal { rule number { 'a' | 'b' #={ "command" : [ { "skip" : null } ] } } }},
     'two alternated terms with skipping';
}, 'alternation test';

subtest sub {
  is $p.parse( q{grammar Minimal; number : <assoc=right> ~'1'+? ;}).perl6,
     q{grammar Minimal { rule number { !'1'+? #={ "options" : [ { "assoc" : "right" } ] } } }},
     'with option';

  is $p.parse( q{grammar Minimal; number : ~'1'+? # One ;}).perl6,
     q{grammar Minimal { rule number { !'1'+? #={ "label" : "One" } } }},
     'with label';
}, 'concatenated options';

subtest sub {
  is $p.parse( q{grammar Minimal; number : ~'1'+? -> skip ;}).perl6,
     q{grammar Minimal { rule number { !'1'+? #={ "command" : [ { "skip" : null } ] } } }},
     'with complement';
}, 'concatenated commands';

subtest sub {
  is $p.parse( q{grammar Minimal; number : ( '1' ) ;}).perl6,
     q{grammar Minimal { rule number { ( '1' ) } }},
     'redundant parenthesis';

  is $p.parse( q{grammar Minimal; number : ( '1' '2' ) ;}).perl6,
     q{grammar Minimal { rule number { ( '1' '2' ) } }},
     'redundant parenthesis with two terms';

  is $p.parse( q{grammar Minimal; number : ( '1' | '2' ) ;}).perl6,
     q{grammar Minimal { rule number { ( '1' | '2' ) } }},
     'redundant parenthesis with two terms';
}, 'rule with redundant parentheses';

# vim: ft=perl6
