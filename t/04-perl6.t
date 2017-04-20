use v6;
use ANTLR4::Actions::Perl6;
use Test;

plan 10;

my $p = ANTLR4::Actions::Perl6.new;
my $parsed;

subtest {
	$parsed = $p.parse( q{grammar Minimal;} );

	is $parsed.perl6, Q:to{END}, Q{minimal grammar};
grammar Minimal {
}
END

	$parsed = $p.parse( q{lexer grammar Minimal;} );

	is $parsed.perl6, Q:to{END}, Q{lexer type};
grammar Minimal { #={ "type" : "lexer" }
}
END

	$parsed = $p.parse( q{grammar Minimal; options {a=2;}} );

	is $parsed.perl6, Q:to{END}, Q{option};
grammar Minimal { #={ "option" : { "a" : "2" } }
}
END

	$parsed = $p.parse( q{grammar Minimal; import Foo;} );

	is $parsed.perl6, Q:to{END}, Q{import};
grammar Minimal { #={ "import" : { "Foo" : null } }
}
END

	$parsed = $p.parse( q{grammar Minimal; tokens { INDENT, DEDENT }} );

	is $parsed.perl6, Q:to{END}, Q{token};
grammar Minimal {
	token DEDENT { 'dedent' }
	token INDENT { 'indent' }
}
END

	$parsed = $p.parse( q{grammar Minimal; @members { int i = 0; }} );

	is $parsed.perl6, Q:to{END}, Q{action};
grammar Minimal { #={ "action" : { "name" : "@members", "content" : "{ int i = 0; }" } }
}
END

	done-testing;

}, 'Grammar and its top-level options';

subtest {
	$parsed = $p.parse( q{grammar Minimal; fragment number : ;} );

	is $parsed.perl6, Q:to{END}, Q{type};
grammar Minimal {
	rule number { #={ "type" : "fragment" }
	}
}
END

	$parsed = $p.parse( q{grammar Minimal; number throws XFoo : ;} );

	is $parsed.perl6, Q:to{END}, Q{throw};
grammar Minimal {
	rule number { #={ "throw" : { "XFoo" : null } }
	}
}
END

	$parsed = $p.parse( q{grammar Minimal; number returns [int amount] : ;} );

	is $parsed.perl6, Q:to{END}, Q{return};
grammar Minimal {
	rule number { #={ "return" : "[int amount]" }
	}
}
END

	$parsed = $p.parse( q{grammar Minimal; number[String name, int total] : ;} );

	is $parsed.perl6, Q:to{END}, Q{action};
grammar Minimal {
	rule number { #={ "action" : "[String name, int total]" }
	}
}
END

	$parsed = $p.parse( q{grammar Minimal; number locals[int n = 0] : ;} );

	is $parsed.perl6, Q:to{END}, Q{local};
grammar Minimal {
	rule number { #={ "local" : "[int n = 0]" }
	}
}
END

	$parsed = $p.parse( q{grammar Minimal; number options{I=1;} : ;} );

	is $parsed.perl6, Q:to{END}, Q{option};
grammar Minimal {
	rule number { #={ "option" : { "I" : "1" } }
	}
}
END

	$parsed = $p.parse( q{grammar Minimal; number : ; catch[int amount] {amount++} } );

	is $parsed.perl6, Q:to{END}, Q{catch};
grammar Minimal {
	rule number { #={ "catch" : [ { "argument" : "[int amount]" }, { "action" : "{amount++}" } ] }
	}
}
END

	$parsed = $p.parse( q{grammar Minimal; number : ; finally {amount=1} } );

	is $parsed.perl6, Q:to{END}, Q{catch};
grammar Minimal {
	rule number { #={ "finally" : "{amount=1}" }
	}
}
END

	done-testing;
}, 'Options surrounding single empty rule (legal in ANTLR)';

subtest {
#`(
	$parsed = $p.parse( q{grammar Minimal; number : '1' ;} );

	is $parsed.perl6, Q:to{END}, Q{action};
grammar Minimal {
	rule number {
	}
}
END
)
	subtest {
#`(
		is $p.parse( q{grammar Minimal; number : '1'* ;}).perl6,
			q{grammar Minimal { rule number { '1'* } }},
			'star';
)
#`(
		is $p.parse( q{grammar Minimal; number : '1'+ ;}).perl6,
			q{grammar Minimal { rule number { '1'+ } }},
			'plus';
)
#`(
		is $p.parse( q{grammar Minimal; number : ~'1' ;}).perl6,
			q{grammar Minimal { rule number { !'1' } }},
			'complement';
)

#`(
		is $p.parse( q{grammar Minimal; number : '1'*? ;}).perl6,
			q{grammar Minimal { rule number { '1'*? } }},
			'greedy star';
)
		done-testing;
	}, 'terminal with options';

	subtest {
#`(
		is $p.parse( q{grammar Minimal; number : 'a' ;}).perl6,
			q{grammar Minimal { rule number { 'a' } }},
			'alpha terminal';
)
#`(
		is $p.parse( q{grammar Minimal; number : 'a123b' ;}).perl6,
			q{grammar Minimal { rule number { 'a123b' } }},
			'mixed alphanumeric terminal';
)
#`(
		is $p.parse( q{grammar Minimal; number : '\u263a' ;}).perl6,
			q{grammar Minimal { rule number { '\x[263a]' } }},
			'Unicode terminal';
)
		done-testing;
	}, 'terminal of different types';

#`(
	is $p.parse( q{grammar Minimal; protected number : '1';}).perl6,
		q{grammar Minimal { rule number { '1' } #={ "attribute" : "protected" } }},
		'attribute';
)
#`(
	is $p.parse( q{grammar Minimal; number [int x] : '1';}).perl6,
		q{grammar Minimal { rule number { '1' } #={ "action" : "[int x]" } }},
		'action';
)
#`(
	is $p.parse( q{grammar Minimal; number returns [int x] : '1';}).perl6,
		q{grammar Minimal { rule number { '1' } #={ "returns" : "[int x]" } }},
		'return type';
)
#`(
	is $p.parse( q{grammar Minimal; number throws XFoo : '1';}).perl6,
		q{grammar Minimal { rule number { '1' } #={ "throws" : [ "XFoo" ] } }},
		'throw';
)

#`(
	is $p.parse( q{grammar Minimal; number locals [int y] : '1';}).perl6,
		q{grammar Minimal { rule number { '1' } #={ "locals" : "[int y]" } }},
		'locals';
)
#`(
	is $p.parse( q{grammar Minimal; number options{a=2;} : '1';}).perl6,
		q{grammar Minimal { rule number { '1' } #={ "options" : [ { "a" : 2 } ] } }},
		'options';
)
	done-testing;
}, 'Single rule and rule-level options';

subtest {
#`(
	is $p.parse( q{grammar Minimal; number : <assoc=right> '1' ;}).perl6,
		q{grammar Minimal { rule number { '1' #={ "options" : [ { "assoc" : "right" } ] } } }},
		'optional option';
)
#`(
	is $p.parse( q{grammar Minimal; number : '1' # One ;}).perl6,
		q{grammar Minimal { rule number { '1' #={ "label" : "One" } } }},
		'optional label';
)
#`(
	is $p.parse( q{grammar Minimal; number : '1' -> skip ;}).perl6,
		q{grammar Minimal { rule number { '1' #={ "command" : [ { "skip" : null } ] } } }},
		'optional command';
)
#`(
	is $p.parse( q{grammar Minimal; number : {$amount = 0;} '1' ;}).perl6,
		q{grammar Minimal { rule number {  #={ "content" : "{$amount = 0;}" } '1' } }},
		'optional action';
)
	done-testing;
}, 'Single rule and term-level options';

subtest {
#`(
	is $p.parse( q{grammar Minimal; number : ab ;}).perl6,
		q{grammar Minimal { rule number { <ab> } }},
		'non-terminal';
)

	subtest {
#`(
		is $p.parse( q{grammar Minimal; number : ab* ;}).perl6,
			q{grammar Minimal { rule number { <ab>* } }},
			'star';
)
#`(
		is $p.parse( q{grammar Minimal; number : ab+ ;}).perl6,
			q{grammar Minimal { rule number { <ab>+ } }},
			'plus';
)
#`(
		is $p.parse( q{grammar Minimal; number : ~ab ;}).perl6,
			q{grammar Minimal { rule number { <!ab> } }},
			'complement';
)
#`(
		is $p.parse( q{grammar Minimal; number : ab*? ;}).perl6,
			q{grammar Minimal { rule number { <ab>*? } }},
			'greedy star';
)
		done-testing;
	}, 'non-terminal modifiers';

#`(
	is $p.parse( q{grammar Minimal; number : 'a'..'z' ;}).perl6,
		q{grammar Minimal { rule number { 'a'..'z' } }},
		'range';
)
#`(
	is $p.parse( q{grammar Minimal; number : '\u263a'..'\u263f' ;}).perl6,
		q{grammar Minimal { rule number { '\x[263a]'..'\x[263f]' } }},
		'Unicode range';
)

	subtest {
#`(
		is $p.parse( q{grammar Minimal; number : 'a'..'z'* ;}).perl6,
			q{grammar Minimal { rule number { 'a'..'z'* } }},
			'star';
)
#`(
		is $p.parse( q{grammar Minimal; number : 'a'..'z'+ ;}).perl6,
			q{grammar Minimal { rule number { 'a'..'z'+ } }},
			'plus';
)
		#
		# The grammar doesn't allow ~'a'..'z', so skip it.
		#
		#is $p.parse( q{grammar Minimal; number : ~'a'..'z' ;}).perl6,
		#   q{grammar Minimal { rule number { ( ( !'a'..z' ) ) } }},
		#   'complement';
#`(
		is $p.parse( q{grammar Minimal; number : 'a'..'z'*? ;}).perl6,
			q{grammar Minimal { rule number { 'a'..'z'*? } }},
			'greedy star';
)
		done-testing;
	}, 'range modifiers';

#`(
	is $p.parse( q{grammar Minimal; number : [] ;}).perl6,
		q{grammar Minimal { rule number { <[  ]> } }},
		'empty character class';
)
	subtest {
#`(
		is $p.parse( q{grammar Minimal; number : []* ;}).perl6,
			q{grammar Minimal { rule number { <[  ]>* } }},
			'star';
)
#`(
		is $p.parse( q{grammar Minimal; number : []+ ;}).perl6,
			q{grammar Minimal { rule number { <[  ]>+ } }},
			'plus';
)
#`(
		is $p.parse( q{grammar Minimal; number : ~[] ;}).perl6,
			q{grammar Minimal { rule number { <-[  ]> } }},
			'complement';
)
#`(
		is $p.parse( q{grammar Minimal; number : []*? ;}).perl6,
			q{grammar Minimal { rule number { <[  ]>*? } }},
			'greedy star';
)
		done-testing;
	}, 'empty character class modifiers';

#`(
	is $p.parse( q{grammar Minimal; number : [a] ;}).perl6,
		q{grammar Minimal { rule number { <[ a ]> } }},
		'character class';
)
#`(
	is $p.parse( q{grammar Minimal; number : [ ] ;}).perl6,
		q{grammar Minimal { rule number { <[ ' ' ]> } }},
		'character class';
)
	subtest {
#`(
		is $p.parse( q{grammar Minimal; number : [a]* ;}).perl6,
			q{grammar Minimal { rule number { <[ a ]>* } }},
			'star';
)
#`(
		is $p.parse( q{grammar Minimal; number : [a]+ ;}).perl6,
			q{grammar Minimal { rule number { <[ a ]>+ } }},
			'plus';
)
#`(
		is $p.parse( q{grammar Minimal; number : ~[a] ;}).perl6,
			q{grammar Minimal { rule number { <-[ a ]> } }},
			'complement';
)
#`(
		is $p.parse( q{grammar Minimal; number : [a]*? ;}).perl6,
			q{grammar Minimal { rule number { <[ a ]>*? } }},
			'greedy star';
)
		done-testing;
	}, 'character class modifiers';

	subtest {
#`(
		is $p.parse( q{grammar Minimal; number : [a-b] ;}).perl6,
			q{grammar Minimal { rule number { <[ a .. b ]> } }},
			'hyphenated character class';
)
#`(
		is $p.parse( q{grammar Minimal; number : [-a-b] ;}).perl6,
			q{grammar Minimal { rule number { <[ - a .. b ]> } }},
			'hyphenated character class';
)
#`(
		is $p.parse( q{grammar Minimal; number : [-a-b\u000d] ;}).perl6,
			q{grammar Minimal { rule number { <[ - a .. b \\x[000d] ]> } }},
			'Unicode character class';
)
		done-testing;
	}, 'character class variants';

#`(
	is $p.parse( q{grammar Minimal; number : . ;}).perl6,
	q{grammar Minimal { rule number { . } }},
	'regular expression';
)
	done-testing;
}, 'Single rule and remaining basic term types';

subtest {
#`(
	is $p.parse( q{grammar Minimal; number : 'a' 'b';}).perl6,
		q{grammar Minimal { rule number { 'a' 'b' } }},
		'two concatenated terms';
)
#`(
	is $p.parse( q{grammar Minimal; number : 'a' 'b' -> skip ;}).perl6,
		q{grammar Minimal { rule number { 'a' 'b' #={ "command" : [ { "skip" : null } ] } } }},
		'two concatenated terms with skipping';
)
	done-testing;
}, 'concatenation test';

subtest {
#`(
	is $p.parse( q{grammar Minimal; number : 'a' | ;}).perl6,
		q{grammar Minimal { rule number { 'a' | (Nil) } }},
		'one term with blank alternation';
)
#`(
	is $p.parse( q{grammar Minimal; number : 'a' | 'b';}).perl6,
		q{grammar Minimal { rule number { 'a' | 'b' } }},
		'two alternated terms';
)
#`(
	is $p.parse( q{grammar Minimal; number : 'a' | 'b' -> skip ;}).perl6,
		q{grammar Minimal { rule number { 'a' | 'b' #={ "command" : [ { "skip" : null } ] } } }},
		'two alternated terms with skipping';
)
	done-testing;
}, 'alternation test';

subtest {
#`(
	is $p.parse( q{grammar Minimal; number : <assoc=right> ~'1'+? ;}).perl6,
		q{grammar Minimal { rule number { !'1'+? #={ "options" : [ { "assoc" : "right" } ] } } }},
		'with option';
)
#`(
	is $p.parse( q{grammar Minimal; number : ~'1'+? # One ;}).perl6,
		q{grammar Minimal { rule number { !'1'+? #={ "label" : "One" } } }},
		'with label';
)
	done-testing;
}, 'concatenated options';

subtest {
#`(
	is $p.parse( q{grammar Minimal; number : ~'1'+? -> skip ;}).perl6,
		q{grammar Minimal { rule number { !'1'+? #={ "command" : [ { "skip" : null } ] } } }},
		'with complement';
)
	done-testing;
}, 'concatenated commands';

subtest {
#`(
	is $p.parse( q{grammar Minimal; number : ( '1' ) ;}).perl6,
		q{grammar Minimal { rule number { ( '1' ) } }},
		'redundant parenthesis';
)
#`(
	is $p.parse( q{grammar Minimal; number : ( '1' '2' ) ;}).perl6,
		q{grammar Minimal { rule number { ( '1' '2' ) } }},
		'redundant parenthesis with two terms';
)
#`(
	is $p.parse( q{grammar Minimal; number : ( '1' | '2' ) ;}).perl6,
		q{grammar Minimal { rule number { ( '1' | '2' ) } }},
		'redundant parenthesis with two terms';
)
	done-testing;
}, 'rule with redundant parentheses';

# vim: ft=perl6
