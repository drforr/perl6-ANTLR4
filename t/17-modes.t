use v6;
use ANTLR4::Grammar;
use Test;

plan 2;

# '-> more' &c are per-alternative, not at the rule level.
# '<assoc=right> are also per-alternative.
#

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
#`{
is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'single rule with options XXX PARTIALLY BROKEN';
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
	token lexer_stuff {
		||
	}
	token parser_stuff {
		||
	}
}
END
}

#`(
is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'pushMode';
grammar Lexer;
plain : 'X' -> pushMode(INSIDE) ;
END
grammar Lexer {
	token plain {
		||	'X'
			#|{pushMode(INSIDE)}
	}
}
END
)
is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'pushMode XXX PARTIALLY BROKEN';
grammar Lexer;
plain : 'X' -> pushMode(INSIDE) ;
END
grammar Lexer {
	token plain {
		||	'X'
	}
}
END

#`(
is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'popMode';
grammar Lexer;
plain : 'X' -> popMode(INSIDE) ;
END
grammar Lexer {
	token plain {
		||	'X'
			#|{popMode(INSIDE)}
	}
}
END
)
is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'popMode XXX PARTIALLY BROKEN';
grammar Lexer;
plain : 'X' -> popMode(INSIDE) ;
END
grammar Lexer {
	token plain {
		||	'X'
	}
}
END

done-testing;

# vim: ft=perl6
