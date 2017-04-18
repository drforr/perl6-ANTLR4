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
		name      => Q{Christmas},
		type      => Any,
		option    => { },
		import    => { },
		token     => { },
		action    => { },
		rule      => { },
		mode      => { }
	}, Q{default grammar};

	$parsed = $g.parse(
		Q:to{END},
lexer grammar Christmas;
END
		:actions($a)
	);

	is-deeply $parsed.ast, {
		type      => Q{lexer},
		name      => Q{Christmas},
		option    => { },
		import    => { },
		token     => { },
		action    => { },
		rule      => { },
		mode      => { }
	}, Q{lexer grammar};

	$parsed = $g.parse(
		Q:to{END},
parser grammar Christmas;
END
		:actions($a)
	);

	is-deeply $parsed.ast, {
		type      => Q{parser},
		name      => Q{Christmas},
		option    => { },
		import    => { },
		token     => { },
		action    => { },
		rule      => { },
		mode      => { }
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
		type      => Q{parser},
		name      => Q{Christmas},
		option    => { },
		import    => { },
		token     => { },
		action    => { },
		rule      => { },
		mode      => { }
	}, Q{empty options};

	$parsed = $g.parse(
		Q:to{END},
parser grammar Christmas;
options { tokenVocab=Antlr; }
END
		:actions($a)
	);

	is-deeply $parsed.ast, {
		type      => Q{parser},
		name      => Q{Christmas},
		option    => {
			tokenVocab => Q{Antlr}
		},
		import    => { },
		token     => { },
		action    => { },
		rule      => { },
		mode      => { }
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
		type      => Q{parser},
		name      => Q{Christmas},
		option    => { },
		import    => { },
		token     => {
			INDENT => Any
		},
		action    => { },
		rule      => { },
		mode      => { }
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
		type      => Q{parser},
		name      => Q{Christmas},
		option    => { },
		import    => {
			ChristmasParser => Any,
			ChristmasLexer => 'Alias'
		},
		token     => { },
		action    => { },
		rule      => { },
		mode      => { }
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
		rule      => { },
		mode      => { }
	}, Q{action};

	done-testing;
}, Q{action};

subtest {
	$parsed = $g.parse(
		Q:to{END},
parser grammar Christmas;
fragment exponent throws XFoo : <assoc=right> term {doStuff();}? ;
Literal : 'term' -> more, channel(HIDDEN) ;
parametrized[String name, int total] returns [int amount] : foo ;
fragment parametrized_literal : foo[$NAME.getText()] ;
public test_locals locals[int n = 0] : 'foo' ;
test_options options{I=1;} : 'bar' ;
test_catching : 'bar' ; catch [int amount] {amount++} finally {amount=1}
mode Remainder;
lexer_stuff : 'blah' ;
mode SkipThis;
mode YetAnother;
fragment more_lexer_stuff : 'blah' ;
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
			test_options => {
				type   => Any,
				throw  => Any,
				return => Any,
				action => Any
			},
			test_catching => {
				type   => Any,
				throw  => Any,
				return => Any,
				action => Any
			},
			test_locals => {
				type   => 'public',
				throw  => Any,
				return => Any,
				action => Any
			},
			parametrized => {
				type   => Any,
				throw  => Any,
				return => '[int amount]',
				action => '[String name, int total]'
			},
			Literal => {
				type   => Any,
				throw  => Any,
				return => Any,
				action => Any
#				lexerCommand => {
#					more    => Any,
#					channel => 'HIDDEN'
#				},
#				concatenation => [ {
#					type    => 'literal',
#					content => 'term',
#				} ]
			},
			parametrized_literal => {
				type   => 'fragment',
				throw  => Any,
				return => Any,
				action => Any
			},
			exponent => {
				type   => 'fragment',
				throw  => {
					XFoo => Any
				},
				return => Any,
				action => Any
			}
		},
		mode      => {
			Remainder => {
				lexer_stuff => {
					type   => Any,
					throw  => Any,
					return => Any,
					action => Any
				}
			},
			# Skip SkipThis because it contains no rules, and
			# without rules it'd just be a comment.
			#
			YetAnother => {
				more_lexer_stuff => {
					type   => 'fragment',
					throw  => Any,
					return => Any,
					action => Any
				}
			}
		}
	}, Q{single import};

	done-testing;
}, Q{rule};

# vim: ft=perl6
