use v6;
use ANTLR4::Actions::Perl6;
use Test;

plan 11;

sub parse( $str ) {
	return ANTLR4::Grammar.parse(
		$str, 
		:actions( ANTLR4::Actions::Perl6.new )
	).ast;
}

# The double comment blocks are around bits of the grammar that don't
# necessarily translate into Perl 6.
#
# Taking a much more pragmatic approach this time 'round.

subtest 'grammar basics', {
	is parse( Q:to[END] ), Q:to[END], 'empty grammar';
	grammar Empty;
	END
	grammar Empty {
	}
	END

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'lexer grammar';
	lexer grammar Empty;
	END
	#|{ "type" : "lexer" }
	grammar Empty {
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'parser grammar';
	parser grammar Empty;
	END
	#|{ "type" : "parser" }
	grammar Empty {
	}
	END
)
)

	done-testing;
};

subtest 'outer options', {
#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'empty options';
	grammar Empty;
	options { }
	END
	#|{ "options" : { } }
	grammar Empty {
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'single option';
	grammar Empty;
	options { tokenVocab=Antlr; }
	END
	#|{ "options" : { "tokenVocab" : "Antlr" } }
	grammar Empty {
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'import';
	grammar Empty;
	import ChristmasParser;
	END
	#|{ "import" : { "ChristmasParser" : null } }
	grammar Empty {
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'import with alias';
	grammar Empty;
	import ChristmasParser=Christmas;
	END
	#|{ "import" : { "ChristmasParser" : "Christmas" } }
	grammar Empty {
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'import with alias';
	grammar Empty;
	@members {
		/** Track whether we are inside of a rule and whether it is lexical parser.
		 */
		public void setCurrentRuleType(int ruleType) {
			this._currentRuleType = ruleType;
		}
	}
	END
	#|{ "actions" : "/** Track whether we are inside of a rule and whether it is lexical parser.
		 */
		public void setCurrentRuleType(int ruleType) {
			this._currentRuleType = ruleType;
		}" }
	grammar Empty {
	}
	END
)
)

	done-testing;
};

subtest 'single rule, token', {
	is parse( Q:to[END] ), Q:to[END], 'single token';
	grammar Empty;
	tokens { INDENT }
	END
	grammar Empty {
		token INDENT {
			||	'indent'
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'two tokens';
	grammar Empty;
	tokens { INDENT, DEDENT }
	END
	grammar Empty {
		token INDENT {
			||	'indent'
		}
		token DEDENT {
			||	'dedent'
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'single rule';
	grammar Empty;
	number : ;
	END
	grammar Empty {
		rule number {
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'two rules';
	grammar Empty;
	number : ;
	string : ;
	END
	grammar Empty {
		rule number {
		}
		rule string {
		}
	}
	END

	done-testing;
};

subtest 'rule options', {
#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'single rule with options';
	grammar Empty;
	fragment parametrized[String name, int total]
		 returns [int amount] throws XFoo options{I=1;} : ;
	END
	grammar Empty {
		#|{ "type" : "fragment", "parameters" : [ { "type" : "String", "name" : "name" }, { "type" : "int", "name" : "total" } ], "returns" : { "type" : "int", "name" : "amount" }, "throws" : "XFoo", "options" : [ { "key" : "I", "vaue" : "1" } ] }
		rule parametrized {
			||
		}
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'single rule with options';
	grammar Empty;
	public test_catch_locals locals[int n = 0] : ;
		 catch [int amount] {amount++} finally {amount=1}
	END
	grammar Empty {
		#|{ "visibility" : "public", "locals" : "int n = 0", "catch" : { "type" : "int", "name" : "amount", "code" : "amount++" }, "finally" : "amount=1" }
		rule test_catch_locals {
			||
		}
	}
	END
)
)

	done-testing;
};

# '-> more' &c are per-alternative, not at the rule level.
# '<assoc=right> are also per-alternative.
#
subtest 'modes', {
#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'single rule with options';
	grammar Empty;
	plain : ;
	mode Remainder;
		lexer_stuff : ;
	mode SkipThis;
	mode YetAnother;
		parser_stuff : ;
	END
	grammar Empty {
		rule plain {
		}
		#|{ "mode" : "Remainder" }
		rule lexer_stuff {
			||
		}
		#|{ "mode" : "SkipThis" }
		#|{ "mode" : "YetAnother" }
		rule parser_stuff {
			||
		}
	}
	END
)
)

	done-testing;
};

subtest 'lexer rule with single term', {
	is parse( Q:to[END] ), Q:to[END], 'token';
	grammar Lexer;
	plain : T ;
	END
	grammar Lexer {
		rule plain {
			||	<T>
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'terminal';
	grammar Lexer;
	plain : 'terminal' ;
	END
	grammar Lexer {
		rule plain {
			||	terminal
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'terminal that needs quoting';
	grammar Lexer;
	plain : '(' '\t' ')' ;
	END
	grammar Lexer {
		rule plain {
			||	'('
				'\t'
				')'
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'char set';
	grammar Lexer;
	plain : [char set] ;
	END
	grammar Lexer {
		rule plain {
			||	<[ c h a r   s e t ]>
		}
	}
	END

	# XXX don't forget escaped characters

	is parse( Q:to[END] ), Q:to[END], 'char range';
	grammar Lexer;
	plain : 'a'..'z' ;
	END
	grammar Lexer {
		rule plain {
			||	<[ a .. z ]>
		}
	}
	END

	subtest 'grouped range', {
		is parse( Q:to[END] ), Q:to[END], 'question';
		grammar Lexer;
		plain : 'a'..'z'? ;
		END
		grammar Lexer {
			rule plain {
				||	<[ a .. z ]>?
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'star';
		grammar Lexer;
		plain : 'a'..'z'* ;
		END
		grammar Lexer {
			rule plain {
				||	<[ a .. z ]>*
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'plus';
		grammar Lexer;
		plain : 'a'..'z'+ ;
		END
		grammar Lexer {
			rule plain {
				||	<[ a .. z ]>+
			}
		}
		END

		done-testing;
	};

	# XXX Make sure this is ANTLR's <dot>

	is parse( Q:to[END] ), Q:to[END], 'dot';
	grammar Lexer;
	plain : . ;
	END
	grammar Lexer {
		rule plain {
			||	.
		}
	}
	END

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'action';
	grammar Lexer;
	plain : {System.out.println("Found end");} ;
	END
	grammar Lexer {
		#|{ "action" : "System.out.println(\"Found end\");" }
		rule plain {
			||	.
		}
	}
	END
)
)

	subtest 'negation', {
		is parse( Q:to[END] ), Q:to[END], 'character';
		grammar Lexer;
		plain : ~'X' ;
		END
		grammar Lexer {
			rule plain {
				||	<-[ X ]>
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'range';
		grammar Lexer;
		plain : ~'X'..'Z' ;
		END
		grammar Lexer {
			rule plain {
				||	<-[ X .. Z ]>
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'subrule';
		grammar Lexer;
		plain : ~('W'|'Y') ;
		END
		grammar Lexer {
			rule plain {
				||	<-[ W Y ]>
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'set';
		grammar Lexer;
		plain : ~[ABZ] ;
		END
		grammar Lexer {
			rule plain {
				||	<-[ A B Z ]>
			}
		}
		END

		done-testing;
	};

	done-testing;
};

subtest 'modifiers', {
	is parse( Q:to[END] ), Q:to[END], 'ques';
	grammar Lexer;
	plain : 'X'? ;
	END
	grammar Lexer {
		rule plain {
			||	X?
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'star';
	grammar Lexer;
	plain : 'X'* ;
	END
	grammar Lexer {
		rule plain {
			||	X*
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'plus';
	grammar Lexer;
	plain : 'X'+ ;
	END
	grammar Lexer {
		rule plain {
			||	X+
		}
	}
	END

	done-testing;
};

subtest 'actions', {
#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'skip';
	grammar Lexer;
	plain : 'X' -> skip ;
	END
	grammar Lexer {
		#|{ "skip" : true }
		rule plain {
			||	X
		}
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'pushMode';
	grammar Lexer;
	plain : 'X' -> pushMode(INSIDE) ;
	END
	grammar Lexer {
		#|{ "pushMode" : "INSIDE" }
		rule plain {
			||	X
		}
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'popMode';
	grammar Lexer;
	plain : 'X' -> popMode(INSIDE) ;
	END
	grammar Lexer {
		#|{ "popMode" : "INSIDE" }
		rule plain {
			||	X
		}
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'more';
	grammar Lexer;
	plain : 'X' -> more ;
	END
	grammar Lexer {
		#|{ "more" : true }
		rule plain {
			||	X
		}
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'type';
	grammar Lexer;
	plain : 'X' -> type(STRING) ;
	END
	grammar Lexer {
		#|{ "type" : "STRING" }
		rule plain {
			||	X
		}
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'channel';
	grammar Lexer;
	plain : 'X' -> channel(HIDDEN) ;
	END
	grammar Lexer {
		#|{ "channel" : "HIDDEN" }
		rule plain {
			||	X
		}
	}
	END
)
)

	done-testing;
};

subtest 'multiple terms', {
	is parse( Q:to[END] ), Q:to[END], 'two literals';
	grammar Lexer;
	plain : 'X' 'Y' ;
	END
	grammar Lexer {
		rule plain {
			||	X
				Y
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'literal and nonliteral';
	grammar Lexer;
	plain : 'X' Y ;
	END
	grammar Lexer {
		rule plain {
			||	X
				<Y>
		}
	}
	END

	done-testing;
};

subtest 'multiple alternations', {
	is parse( Q:to[END] ), Q:to[END], 'two literals';
	grammar Lexer;
	plain : 'X' | 'Y' ;
	END
	grammar Lexer {
		rule plain {
			||	X
			||	Y
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'literal or nonliteral';
	grammar Lexer;
	plain : 'X' Y ;
	END
	grammar Lexer {
		rule plain {
			||	X
				<Y>
		}
	}
	END

	done-testing;
};

subtest 'grouping', {
	is parse( Q:to[END] ), Q:to[END], 'single terminal';
	grammar Lexer;
	plain : ( 'X' ) ;
	END
	grammar Lexer {
		rule plain {
			||	(
					||	X
				)
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'single nonterminal';
	grammar Lexer;
	plain : ( X ) ;
	END
	grammar Lexer {
		rule plain {
			||	(
					||	<X>
				)
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'two terms grouped';
	grammar Lexer;
	plain : ( 'X' 'Y' ) ;
	END
	grammar Lexer {
		rule plain {
			||	(
					||	X
						Y
				)
		}
	}
	END

	subtest 'with modifiers', {
		is parse( Q:to[END] ), Q:to[END], 'question';
		grammar Lexer;
		plain : ( 'X' 'Y' )? ;
		END
		grammar Lexer {
			rule plain {
				||	(
						||	X
							Y
					)?
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'star';
		grammar Lexer;
		plain : ( 'X' 'Y' )* ;
		END
		grammar Lexer {
			rule plain {
				||	(
						||	X
							Y
					)*
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'plus';
		grammar Lexer;
		plain : ( 'X' 'Y' )+ ;
		END
		grammar Lexer {
			rule plain {
				||	(
						||	X
							Y
					)+
			}
		}
		END

		done-testing;
	};

	done-testing;
};

done-testing;

# vim: ft=perl6
