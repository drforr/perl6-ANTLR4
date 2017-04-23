use v6;
use Test;
use ANTLR4::Grammar;
use ANTLR4::Actions::AST;

plan 5;

my $a = ANTLR4::Actions::AST.new;
my $g = ANTLR4::Grammar.new;
my $parsed;

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
				name    => '@members',
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

	done-testing;
}, Q{grammar-level settings};

#Literal : 'term' -> more, channel(HIDDEN) ;

# '-> more' &c are per-alternative, not at the rule level.
# '<assoc=right> are also per-alternative.
subtest {
	$parsed = $g.parse(
		Q:to{END},
parser grammar Christmas;
plain : ;
fragment parametrized[String name, int total]
         returns [int amount] throws XFoo options{I=1;} : ;
public test_catch_locals locals[int n = 0] : ;
                         catch [int amount] {amount++} finally {amount=1}
mode Remainder;
	lexer_stuff : ;
mode SkipThis;
mode YetAnother;
	fragment more_lexer_stuff : ;
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
			plain => {
				type    => Any,
				throw   => Any,
				return  => Any,
				action  => Any,
				local   => Any,
				option  => Any,
				catch   => Any,
				finally => Any,
				content => Any
			},
			test_catch_locals => {
				type    => 'public',
				throw   => Any,
				return  => Any,
				action  => Any,
				local   => '[int n = 0]',
				option  => Any,
				catch   => [ {
					argument => '[int amount]',
					action   => '{amount++}'
				} ],
				finally => '{amount=1}',
				content => Any
			},
			parametrized => {
				type    => 'fragment',
				throw   => {
					XFoo => Any
				},
				return  => '[int amount]',
				action  => '[String name, int total]',
				local   => Any,
				option  => {
					I => '1'
				},
				catch   => Any,
				finally => Any,
				content => Any
			},
		},
		mode      => {
			Remainder => {
				lexer_stuff => {
					type    => Any,
					throw   => Any,
					return  => Any,
					action  => Any,
					local   => Any,
					option  => Any,
					catch   => Any,
					finally => Any,
					content => Any
				}
			},
			# Skip SkipThis because it contains no rules, and
			# without rules it'd just be a comment.
			#
			YetAnother => {
				more_lexer_stuff => {
					type    => 'fragment',
					throw   => Any,
					return  => Any,
					action  => Any,
					local   => Any,
					option  => Any,
					catch   => Any,
					finally => Any,
					content => Any
				}
			}
		}
	}, Q{single import, no rule bodies};

	done-testing;
}, Q{rule-level settings};

subtest {
	$parsed = $g.parse(
		Q:to{END},
grammar Christmas;
plain : 'literal' ;
END
		:actions($a)
	);

	is-deeply $parsed.ast, {
		type     => Any,
		name     => Q{Christmas},
		option   => { },
		import   => { },
		token    => { },
		action   => { },
		rule     => {
			plain => {
				type    => Any,
				throw   => Any,
				return  => Any,
				action  => Any,
				local   => Any,
				option  => Any,
				catch   => Any,
				finally => Any,
				content => [ {
					type => 'terminal',
					name => 'literal'
				} ]
			},
		},
		mode      => { }
	}, Q{single literal};

	done-testing;
}, Q{single literal};

subtest {
	$parsed = $g.parse(
		Q:to{END},
grammar Christmas;
plain : 'literal' | 'another literal' ;
END
		:actions($a)
	);

	is-deeply $parsed.ast, {
		type     => Any,
		name     => Q{Christmas},
		option   => { },
		import   => { },
		token    => { },
		action   => { },
		rule     => {
			plain => {
				type    => Any,
				throw   => Any,
				return  => Any,
				action  => Any,
				local   => Any,
				option  => Any,
				catch   => Any,
				finally => Any,
				content => [ {
					type    => 'alternation',
					content => [ {
						type => 'terminal',
						name => 'literal'
					}, {
						type => 'terminal',
						name => 'another literal'
					} ]
				} ]
			},
		},
		mode      => { }
	}, Q{single alternation};

	done-testing;
}, Q{single alternation};

# vim: ft=perl6
