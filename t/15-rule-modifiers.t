use v6;
use ANTLR4::Grammar;
use Test;

plan 5;

# XXX Please note that I've changed my mind a bit on how the out-of-band
# XXX signaling should work. You'll see here that I'm simply returning the
# XXX text that I get out of the parsed stream.
# XXX
# XXX This should get rid of a dependency down the road.
# XXX
#`{
is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'channel';
grammar Empty;
BLOCK_COMMENT :	 EOF  -> channel(HIDDEN) ;
END
grammar Empty {
	token BLOCK_COMMENT {
		||	$
			#|{channel(HIDDEN)}
	}
}
END
}

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

#`{
is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'push';
grammar Empty;
BLOCK_COMMENT : ('0'..'9') -> pushMode(I) ;
END
grammar Empty {
	token BLOCK_COMMENT {
		||	(	||	<[ 0 .. 9 ]>
					#|{pushMode(I)}
			)
	}
}
END
}

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
#`{
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'single token with options';
	grammar Empty;
	fragment parametrized[String name, int total]
		 returns [int amount] throws XFoo options{I=1;} : ;
	END
	grammar Empty {
		#|{fragment parametrized[String name, int total]}
		token parametrized { #|{returns [int amount] throws XFoo options{I=1;}}
		}
	}
	END
}
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'single token with options XXX PARTIALLY BROKEN';
	grammar Empty;
	fragment parametrized[String name, int total]
		 returns [int amount] throws XFoo options{I=1;} : ;
	END
	grammar Empty {
		token parametrized {
		}
	}
	END

#`(
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'single token with options';
	grammar Empty;
	public test_catch_locals locals[int n = 0] : ;
		 catch [int amount] {amount++} finally {amount=1}
	END
	grammar Empty {
		token test_catch_locals { #|{locals[int n = 0]}
			#|{catch [int amount] {amount++} finally {amount=1}}
		}
	}
	END
)
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'single token with options XXX PARTIALLY BROKEN';
	grammar Empty;
	public test_catch_locals locals[int n = 0] : ;
		 catch [int amount] {amount++} finally {amount=1}
	END
	grammar Empty {
		token test_catch_locals {
		}
	}
	END

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
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'skip';
	grammar Lexer;
	plain : 'X' -> skip ;
	END
	grammar Lexer {
		token plain {
			||	'X'
				#|{skip}
		}
	}
	END
)
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'skip XXX PARTIALLY BROKEN';
	grammar Lexer;
	plain : 'X' -> skip ;
	END
	grammar Lexer {
		token plain {
			||	'X'
		}
	}
	END

#`(
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'more';
	grammar Lexer;
	plain : 'X' -> more ;
	END
	grammar Lexer {
		token plain {
			||	'X'
				#|{more}
		}
	}
	END
)
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'more XXX PARTIALLY BROKEN';
	grammar Lexer;
	plain : 'X' -> more ;
	END
	grammar Lexer {
		token plain {
			||	'X'
		}
	}
	END

#`(
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'type';
	grammar Lexer;
	plain : 'X' -> type(STRING) ;
	END
	grammar Lexer {
		token plain {
			||	'X'
				#|{type(STRING)}
		}
	}
	END
)
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'type XXX PARTIALLY BROKEN';
	grammar Lexer;
	plain : 'X' -> type(STRING) ;
	END
	grammar Lexer {
		token plain {
			||	'X'
		}
	}
	END

#`(
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'channel';
	grammar Lexer;
	plain : 'X' -> channel(HIDDEN) ;
	END
	grammar Lexer {
		token plain {
			||	'X'
				#|{channel(HIDDEN)}
		}
	}
	END
)
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'channel XXX PARTIALLY BROKEN';
	grammar Lexer;
	plain : 'X' -> channel(HIDDEN) ;
	END
	grammar Lexer {
		token plain {
			||	'X'
		}
	}
	END

	done-testing;
};

done-testing;

# vim: ft=perl6
