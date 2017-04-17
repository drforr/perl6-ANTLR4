use v6;
use ANTLR4::Grammar;
use ANTLR4::Actions::AST;
use Test;

plan 6;

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
		name     => Q{Christmas},
		type     => Any,
		option   => { },
		import   => { },
		token    => { },
		action   => { },
		rule     => { },
		fragment => { },
		mode     => { }
	}, Q{default grammar};

	$parsed = $g.parse(
		Q:to{END},
lexer grammar Christmas;
END
		:actions($a)
	);

	is-deeply $parsed.ast, {
		type     => Q{lexer},
		name     => Q{Christmas},
		option   => { },
		import   => { },
		token    => { },
		action   => { },
		rule     => { },
		fragment => { },
		mode     => { }
	}, Q{lexer grammar};

	$parsed = $g.parse(
		Q:to{END},
parser grammar Christmas;
END
		:actions($a)
	);

	is-deeply $parsed.ast, {
		type     => Q{parser},
		name     => Q{Christmas},
		option   => { },
		import   => { },
		token    => { },
		action   => { },
		rule     => { },
		fragment => { },
		mode     => { }
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
		type     => Q{parser},
		name     => Q{Christmas},
		option   => { },
		import   => { },
		token    => { },
		action   => { },
		rule     => { },
		fragment => { },
		mode     => { }
	}, Q{empty options};

	$parsed = $g.parse(
		Q:to{END},
parser grammar Christmas;
options { tokenVocab=Antlr; }
END
		:actions($a)
	);

	is-deeply $parsed.ast, {
		type     => Q{parser},
		name     => Q{Christmas},
		option   => {
			tokenVocab => Q{Antlr}
		},
		import   => { },
		token    => { },
		action   => { },
		rule     => { },
		fragment => { },
		mode     => { }
	}, Q{single option};

	done-testing;
}, Q{options};

subtest {
	$parsed = $g.parse(
		Q:to{END},
parser grammar Christmas;
tokens { INDENT }
END
		:actions($a)
	);

	is-deeply $parsed.ast, {
		type     => Q{parser},
		name     => Q{Christmas},
		option   => { },
		import   => { },
		token    => {
			INDENT => Any
		},
		action   => { },
		rule     => { },
		fragment => { },
		mode     => { }
	}, Q{single token};

	done-testing;
}, Q{token};

subtest {
	$parsed = $g.parse(
		Q:to{END},
parser grammar Christmas;
import ChristmasParser, ChristmasLexer=Alias;
END
		:actions($a)
	);

	is-deeply $parsed.ast, {
		type     => Q{parser},
		name     => Q{Christmas},
		option   => { },
		import   => {
			ChristmasParser => Any,
			ChristmasLexer => 'Alias'
		},
		token    => { },
		action   => { },
		rule     => { },
		fragment => { },
		mode     => { }
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
		type     => Q{parser},
		name     => Q{Christmas},
		option   => { },
		import   => { },
		token    => { },
		action   => {
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
		},
		rule     => { },
		fragment => { },
		mode     => { }
	}, Q{action};

	done-testing;
}, Q{action};

subtest {
#`(
	$parsed = $g.parse(
		Q:to{END},
parser grammar Christmas;
fragment exponent : <assoc=right> term {doStuff();} ;
Literal : 'term' -> more, channel(HIDDEN) ;
END
		:actions($a)
	);

	is-deeply $parsed.ast, {
		type     => Q{parser},
		name     => Q{Christmas},
		option   => { },
		import   => { },
		token    => { },
		action   => { },
		rule     => {
			Literal => {
				lexerCommand => {
					more    => Any,
					channel => 'HIDDEN'
				},
				concatenation => [ {
					type    => 'literal',
					content => 'term',
				} ]
			}
		},
		fragment => {
			test => {
				concatenation => [ {
					type    => 'term',
					content => 'exponent',
					action  => '{doStuff();}',
					option  => {
						assoc => 'right'
					}
				} ]
			}
		},
		mode     => { }
	}, Q{single import};
)
	done-testing;
}, Q{rule};

# vim: ft=perl6
