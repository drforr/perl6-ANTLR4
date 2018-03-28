use v6;
use ANTLR4::Grammar;
use Test;

plan 9;

# No, I'm not going to go through all the permutations of the possible stuff
# inside character ranges, just the basic types outline above.
#
# And I'll bravely assume that other permutations such as C<Str Str> will
# work if these do.
#
is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'terminal,terminal';
grammar Lexer;
plain : 'terminal' 'other' ;
END
grammar Lexer {
	rule plain {
		||	terminal
			other
	}
}
END

is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'terminal,character range';
grammar Lexer;
plain : 'terminal' 'a'..'z' ;
END
grammar Lexer {
	rule plain {
		||	terminal
			<[ a .. z ]>
	}
}
END

is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'terminal,character set';
grammar Lexer;
plain : 'terminal' [by] ;
END
grammar Lexer {
	rule plain {
		||	terminal
			<[ b y ]>
	}
}
END

# This is needed because a terminal for some reason shifts ANTLR to
# using the lexerAlt stuff, which needs to be built out separately.
# Again, I could redesign the grammar to get rid of this problem,
# but I think I'm going to leave it as-is to show what sort of
# challenges can result from this.
#
subtest 'terminal,character set modifiers', {
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'terminal,negated character set';
	grammar Lexer;
	plain : 'terminal' ~[by] ;
	END
	grammar Lexer {
		rule plain {
			||	terminal
				<-[ b y ]>
		}
	}
	END

	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'terminal,character set with question';
	grammar Lexer;
	plain : 'terminal' [by]? ;
	END
	grammar Lexer {
		rule plain {
			||	terminal
				<[ b y ]>?
		}
	}
	END

	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'terminal,character set with star';
	grammar Lexer;
	plain : 'terminal' [by]* ;
	END
	grammar Lexer {
		rule plain {
			||	terminal
				<[ b y ]>*
		}
	}
	END

	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'terminal,character set with plus';
	grammar Lexer;
	plain : 'terminal' [by]+ ;
	END
	grammar Lexer {
		rule plain {
			||	terminal
				<[ b y ]>+
		}
	}
	END

	done-testing;
};

is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'terminal,negated subrule';
grammar Lexer;
plain : 'terminal' ~('W') ;
END
grammar Lexer {
	rule plain {
		||	terminal
			<-[ W ]>
	}
}
END

is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'terminal-wildcard';
grammar Lexer;
plain : 'terminal' . ;
END
grammar Lexer {
	rule plain {
		||	terminal
			.
	}
}
END

is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'terminal-nonterminal';
grammar Lexer;
plain : 'terminal' Str ;
END
grammar Lexer {
	rule plain {
		||	terminal
			<Str>
	}
}
END

is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'regression from Clojure';
grammar Lexer;
plain: '0' [xX] HEXD+ ;
END
grammar Lexer {
	rule plain {
		||	'0'
			<[ x X ]>
			<HEXD>+
	}
}
END

is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'regression from Abnf';
grammar Lexer;
plain : '\r'? -> channel(HIDDEN) ;
END
grammar Lexer {
	rule plain {
		||	'\r'?
	}
}
END

done-testing;

# vim: ft=perl6
