use v6;
use ANTLR4::Grammar;
use ANTLR4::Actions::AST;
use Test;

plan 4;

my $a = ANTLR4::Actions::AST.new;
my $g = ANTLR4::Grammar.new;
my $parsed;

#`(
$parsed = $g.parse(
	Q:to{END},
grammar Christmas;
DOC_COMMENT : '/**' .*? ( '*/' | EOF )? ;

mode LexerCharSet;

fragment LEXER_CHAR_SET_BODY : ~( ~[\]\\] | '\\' . )+ -> more ;

END
	:actions($a)
).ast;
)

subtest {
	$parsed = $g.parse(
		Q:to{END},
grammar Christmas;
END
		:actions($a)
	);

	is-deeply $parsed.ast, {
		name         => Q{Christmas},
		variant      => Any,
		option       => { },
		import       => { },
		token        => { },
		action       => { }
	}, Q{default grammar};

	$parsed = $g.parse(
		Q:to{END},
lexer grammar Christmas;
END
		:actions($a)
	);

	is-deeply $parsed.ast, {
		variant      => Q{lexer},
		name         => Q{Christmas},
		option       => { },
		import       => { },
		token        => { },
		action       => { }
	}, Q{lexer grammar};

	$parsed = $g.parse(
		Q:to{END},
parser grammar Christmas;
END
		:actions($a)
	);

	is-deeply $parsed.ast, {
		variant      => Q{parser},
		name         => Q{Christmas},
		option       => { },
		import       => { },
		token        => { },
		action       => { }
	}, Q{parser grammar};

	done-testing;
}, Q{grammar types};

subtest {
	$parsed = $g.parse(
		Q:to{END},
parser grammar Christmas;
options { }
END
		:actions($a)
	);

	is-deeply $parsed.ast, {
		variant      => Q{parser},
		name         => Q{Christmas},
		option       => { },
		import       => { },
		token        => { },
		action       => { }
	}, Q{empty options};

	$parsed = $g.parse(
		Q:to{END},
parser grammar Christmas;
options { tokenVocab=Antlr; }
END
		:actions($a)
	);

	is-deeply $parsed.ast, {
		variant      => Q{parser},
		name         => Q{Christmas},
		option       => {
			tokenVocab => Q{Antlr}
		},
		import       => { },
		token        => { },
		action       => { }
	}, Q{single option};

	done-testing;
}, Q{options};

subtest {
	$parsed = $g.parse(
		Q:to{END},
parser grammar Christmas;
import ChristmasParser, ChristmasLexer=Alias;
END
		:actions($a)
	);

	is-deeply $parsed.ast, {
		variant      => Q{parser},
		name         => Q{Christmas},
		option       => { },
		import       => {
			ChristmasParser => Any,
			ChristmasLexer => 'Alias'
		},
		token        => { },
		action       => { }
	}, Q{single import};

	done-testing;
}, Q{import};

subtest {
	$parsed = $g.parse(
		Q:to{END},
parser grammar Christmas;
@members {
	/** Track whether we are inside of a rule and whether it is lexical parser.
	 */
	public void setCurrentRuleType(int ruleType) {
		this._currentRuleType = ruleType;
	}
}
END
		:actions($a)
	);

	is-deeply $parsed.ast, {
		variant      => Q{parser},
		name         => Q{Christmas},
		option       => { },
		import       => { },
		token        => { },
		action       => {
			name    => 'members',
			content => Q:to{END}.chomp
{
	/** Track whether we are inside of a rule and whether it is lexical parser.
	 */
	public void setCurrentRuleType(int ruleType) {
		this._currentRuleType = ruleType;
	}
}
END
		}
	}, Q{action};

	done-testing;
}, Q{action};

# vim: ft=perl6
