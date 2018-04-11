use v6;
use ANTLR4::Grammar;
use Test;

plan 5;

is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'channel XXX PARTIALLY BROKEN';
grammar Empty;
BLOCK_COMMENT :	 EOF  -> channel(HIDDEN) ;
END
grammar Empty {
	token BLOCK_COMMENT {
		||	$
	}
}
END

is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'push XXX PARTIALLY BROKEN';
grammar Empty;
BLOCK_COMMENT : ('0'..'9') -> pushMode(I) ;
END
grammar Empty {
	token BLOCK_COMMENT {
		||	(	||	<[ 0 .. 9 ]>
			)
	}
}
END

subtest 'token options', {
#`(
#`(
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'single token with options';
	grammar Empty;
	fragment parametrized[String name, int total]
		 returns [int amount] throws XFoo options{I=1;} : ;
	END
	grammar Empty {
		#|{ "type" : "fragment", "parameters" : [ { "type" : "String", "name" : "name" }, { "type" : "int", "name" : "total" } ], "returns" : { "type" : "int", "name" : "amount" }, "throws" : "XFoo", "options" : [ { "key" : "I", "vaue" : "1" } ] }
		token parametrized {
			||
		}
	}
	END
)
)

#`(
#`(
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'single token with options';
	grammar Empty;
	public test_catch_locals locals[int n = 0] : ;
		 catch [int amount] {amount++} finally {amount=1}
	END
	grammar Empty {
		#|{ "visibility" : "public", "locals" : "int n = 0", "catch" : { "type" : "int", "name" : "amount", "code" : "amount++" }, "finally" : "amount=1" }
		token test_catch_locals {
			||
		}
	}
	END
)
)

	done-testing;
};

is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'action';
grammar Lexer;
plain : {System.out.println("Found end");} ;
END
grammar Lexer {
	token plain {
		||	#|{System.out.println("Found end");}
	}
}
END

subtest 'actions', {
#`(
#`(
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'skip';
	grammar Lexer;
	plain : 'X' -> skip ;
	END
	grammar Lexer {
		#|{ "skip" : true }
		token plain {
			||	X
		}
	}
	END
)
)

#`(
#`(
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'more';
	grammar Lexer;
	plain : 'X' -> more ;
	END
	grammar Lexer {
		#|{ "more" : true }
		token plain {
			||	X
		}
	}
	END
)
)

#`(
#`(
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'type';
	grammar Lexer;
	plain : 'X' -> type(STRING) ;
	END
	grammar Lexer {
		#|{ "type" : "STRING" }
		token plain {
			||	X
		}
	}
	END
)
)

#`(
#`(
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'channel';
	grammar Lexer;
	plain : 'X' -> channel(HIDDEN) ;
	END
	grammar Lexer {
		#|{ "channel" : "HIDDEN" }
		token plain {
			||	X
		}
	}
	END
)
)

	done-testing;
};

done-testing;

# vim: ft=perl6
