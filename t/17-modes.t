use v6;
use ANTLR4::Grammar;
use Test;

plan 1;

# '-> more' &c are per-alternative, not at the rule level.
# '<assoc=right> are also per-alternative.
#

ok 1, 'XXX Make this work';

#`(
#`(
is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'single rule with options';
grammar Empty;
plain : ;
mode Remainder;
	lexer_stuff : ;
mode SkipThis;
mode YetAnother;
	parser_stuff : ;
END
grammar Empty {
	token plain {
	}
	#|{ "mode" : "Remainder" }
	token lexer_stuff {
		||
	}
	#|{ "mode" : "SkipThis" }
	#|{ "mode" : "YetAnother" }
	token parser_stuff {
		||
	}
}
END
)
)

#`(
#`(
is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'pushMode';
grammar Lexer;
plain : 'X' -> pushMode(INSIDE) ;
END
grammar Lexer {
	#|{ "pushMode" : "INSIDE" }
	token plain {
		||	X
	}
}
END
)
)

#`(
#`(
is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'popMode';
grammar Lexer;
plain : 'X' -> popMode(INSIDE) ;
END
grammar Lexer {
	#|{ "popMode" : "INSIDE" }
	token plain {
		||	X
	}
}
END
)
)

done-testing;

# vim: ft=perl6
