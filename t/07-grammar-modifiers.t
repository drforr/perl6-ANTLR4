use v6;
use ANTLR4::Grammar;
use Test;

plan 4;

# The double comment blocks are around bits of the grammar that don't
# necessarily translate into Perl 6.
#
# Taking a much more pragmatic approach this time 'round.
#
subtest 'grammar basics', {
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'lexer grammar';
	lexer grammar Empty;
	END
	#|{ "type" : "lexer" }
	grammar Empty {
	}
	END

	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'parser grammar';
	parser grammar Empty;
	END
	#|{ "type" : "parser" }
	grammar Empty {
	}
	END

	done-testing;
};

# A blank option array may be possible, but it won't be placed
# into the JSON block.
#
is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'single option';
grammar Empty;
options { tokenVocab=Antlr; }
END
#|{ "option" : { "tokenVocab" : "Antlr" } }
grammar Empty {
}
END

subtest 'import', {
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'import';
	grammar Empty;
	import ChristmasParser;
	END
	#|{ "import" : { "ChristmasParser" : null } }
	grammar Empty {
	}
	END

	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'import with alias';
	grammar Empty;
	import ChristmasParser=Christmas;
	END
	#|{ "import" : { "ChristmasParser" : "Christmas" } }
	grammar Empty {
	}
	END

	done-testing;
};

subtest 'actions', {
#`(
#`(
	is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'import with alias';
	grammar Empty;
	@members {
		/** Track whether we are inside of a rule and whether it is lexical parser.
		 */
		public void setCurrentRuleType(int ruleType) {
			this._currentRuleType = ruleType;
		}
	}
	END
	#|{ "actions" : { "@members" : "/** Track whether we are inside of a rule and whether it is lexical parser.
		 */
		public void setCurrentRuleType(int ruleType) {
			this._currentRuleType = ruleType;
		}" } }
	grammar Empty {
	}
	END
)
)

	done-testing;
};

done-testing;

# vim: ft=perl6
