use v6;
use Test;
use ANTLR4::Grammar;
use ANTLR4::Actions::AST;

plan 6;

my $a = ANTLR4::Actions::AST.new;
my $g = ANTLR4::Grammar.new;
my $parsed;

# Reminder to those adding tests - I'd like for the first test of a subtest
# to check the data structure as a whole, in order to let people visualize
# how it looks. The rest of the tests can focus on just the individual keys.
#
subtest {
	$parsed = $g.parse(
		Q:to{END},
		grammar Christmas;
		END
		:actions($a)
	);

	is-deeply $parsed.ast, {
		name   => Q{Christmas},
		type   => Any,
		option => { },
		import => { },
		token  => { },
		action => { },
		rule   => { },
		mode   => { }
	}, Q{default grammar};

	$parsed = $g.parse(
		Q:to{END},
		lexer grammar Christmas;
		END
		:actions($a)
	);

	is $parsed.ast.<type>, Q{lexer}, Q{lexer type};
	is $parsed.ast.<name>, Q{Christmas}, Q{lexer name};

	$parsed = $g.parse(
		Q:to{END},
		parser grammar Christmas;
		END
		:actions($a)
	);

	is $parsed.ast.<type>, Q{parser}, Q{parser type};
	is $parsed.ast.<name>, Q{Christmas}, Q{parser name};

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
			type   => Q{parser},
			name   => Q{Christmas},
			option => { },
			import => { },
			token  => { },
			action => { },
			rule   => { },
			mode   => { }
		}, Q{empty options};

		$parsed = $g.parse(
			Q:to{END},
			parser grammar Christmas;
			options { tokenVocab=Antlr; }
			END
			:actions($a)
		);

		is-deeply $parsed.ast.<option>, {
			tokenVocab => Q{Antlr}
		}, Q{single option};

		done-testing;
	}, Q{options};

	$parsed = $g.parse(
		Q:to{END},
		parser grammar Christmas;
		tokens { INDENT }
		END
		:actions($a)
	);

	is-deeply $parsed.ast.<token>, {
		INDENT => Any
	}, Q{single token};

	$parsed = $g.parse(
		Q:to{END},
		parser grammar Christmas;
		import ChristmasParser, ChristmasLexer=Alias;
		END
		:actions($a)
	);

	is-deeply $parsed.ast.<import>, {
		ChristmasParser => Any,
		ChristmasLexer  => 'Alias'
	}, Q{single import};

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

	is-deeply $parsed.ast.<action>, {
		name => '@members',
		body => Q:to{END}.chomp
{
	/** Track whether we are inside of a rule and whether it is lexical parser.
	 */
	public void setCurrentRuleType(int ruleType) {
		this._currentRuleType = ruleType;
	}
}
END
	}, Q{action};

	done-testing;
}, Q{grammar-level settings};

#Literal : 'term' -> more, channel(HIDDEN) ;

# '-> more' &c are per-alternative, not at the rule level.
# '<assoc=right> are also per-alternative.
subtest {
#`(
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
		type   => Q{parser},
		name   => Q{Christmas},
		option => { },
		import => { },
		token  => { },
		action => { },
		rule   => {
			plain => {
				type    => Any,
				throw   => Any,
				return  => Any,
				action  => Any,
				local   => Any,
				option  => Any,
				catch   => Any,
				finally => Any,
				term    => Any
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
				term    => Any
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
				term    => Any
			},
		},
		mode    => {
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
					term    => Any
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
					term    => Any
				}
			}
		}
	}, Q{single import, no rule bodies};
)

	done-testing;
}, Q{rule-level settings};

$parsed = $g.parse(
	Q:to{END},
	grammar Christmas;
	plain : 'SELECT' ;
	END
	:actions($a)
);

is-deeply $parsed.ast.<rule><plain><term>, {
	type => 'concatenation',
	term => [ {
		name => 'SELECT',
		type => 'terminal'
	}, ]
}, Q{single literal};

$parsed = $g.parse(
	Q:to{END},
	grammar Christmas;
	plain : 'SELECT' '*' ;
	END
	:actions($a)
);

is-deeply $parsed.ast.<rule><plain><term>, {
	type => 'concatenation',
	term => [ {
		name => 'SELECT',
		type => 'terminal'
	}, {
		name => '*',
		type => 'terminal'
	} ]
}, Q{two literals};

$parsed = $g.parse(
	Q:to{END},
	grammar Christmas;
	plain : 'SELECT' | 'UPDATE' ;
	END
	:actions($a)
);

is-deeply $parsed.ast.<rule><plain><term>, {
	type => 'alternation',
	term => [ {
		name => 'SELECT',
		type => 'terminal'
	}, {
		type => 'terminal',
		name => 'UPDATE'
	} ]
}, Q{two alternatives};

# vim: ft=perl6
