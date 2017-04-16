use v6;
use ANTLR4::Grammar;
use ANTLR4::Actions::AST;
use Test;

plan 1;

my $a = ANTLR4::Actions::AST.new;
my $g = ANTLR4::Grammar.new;
my $parsed;

#`(
subtest {
	$parsed = $g.parse(
		Q{grammar Minimal;},
		:actions($a)
	).ast;

	is-deeply $parsed, (
		grammarType => Any,
		name => Q{Minimal},
		prequelConstruct => [ ],
		ruleSpec => [ ],
		modeSpec => [ ]
	), Q{default};

	$parsed = $g.parse(
		Q{lexer grammar Minimal;},
		:actions($a)
	).ast;

	is-deeply $parsed, (
		grammarType => Q{lexer},
		name => Q{Minimal},
		prequelConstruct => [ ],
		ruleSpec => [ ],
		modeSpec => [ ]
	), Q{lexer};

	$parsed = $g.parse(
		Q{parser grammar Minimal;},
		:actions($a)
	).ast;

	is-deeply $parsed, (
		grammarType => Q{parser},
		name => Q{Minimal},
		prequelConstruct => [ ],
		ruleSpec => [ ],
		modeSpec => [ ]
	), Q{parser};

	done-testing;
}, Q{bare grammar};

subtest {
	$parsed = $g.parse(
		Q{grammar Minimal; options { }},
		:actions($a)
	).ast;

	is-deeply $parsed, (
		grammarType => Any,
		name => Q{Minimal},
		prequelConstruct => (
			optionsSpec => ( ),
			delegateGrammars => ( Nil, )
		),
		ruleSpec => ( ),
		modeSpec => [ ]
	), Q{default};

	done-testing;
}, Q{prequel constructs};
)

$parsed = $g.parse(
	Q:to{END},
grammar Christmas;
options {
	tokenVocab=Antlr;
}
import ChristmasParser, ChristmasLexer=Alias;
tokens {
	TOKEN_REF,
	RULE_REF,
	LEXER_CHAR_SET
}
@members {
	/** Track whether we are inside of a rule and whether it is lexical parser.
	 */
	public void setCurrentRuleType(int ruleType) {
		this._currentRuleType = ruleType;
	}
}
DOC_COMMENT : '/**' .*? ( '*/' | EOF )? ;

mode LexerCharSet;

fragment LEXER_CHAR_SET_BODY : ~( ~[\]\\] | '\\' . )+ -> more ;

END
	:actions($a)
).ast;

#say $parsed;

is-deeply $parsed, [ {
	type         => Q{grammar},
	mode         => Any,
	variant      => Any,
	name         => Q{Christmas},
	modifier     => Any,
	lexerCommand => Any,
	content      => [ {
		type         => Q{options},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => Any,
		lexerCommand => Any,
		content  => [ {
			type         => Q{option},
			mode         => Any,
			variant      => Any,
			name         => Q{tokenVocab},
			modifier     => Any,
			lexerCommand => Any,
			content      => Q{Antlr}
		} ]
	}, {
		type         => Q{imports},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => Any,
		lexerCommand => Any,
		content  => [ {
			type         => Q{import},
			mode         => Any,
			variant      => Any,
			name         => Q{ChristmasParser},
			modifier     => Any,
			lexerCommand => Any,
			content      => Any,
		}, {
			type         => Q{import},
			mode         => Any,
			variant      => Any,
			name         => Q{ChristmasLexer},
			modifier     => Any,
			lexerCommand => Any,
			content      => Q{Alias}
		} ]
	}, {
		type         => Q{tokens},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => Any,
		lexerCommand => Any,
		content      => [ {
			type         => Q{token},
			mode         => Any,
			variant      => Any,
			name         => Q{TOKEN_REF},
			modifier     => Any,
			lexerCommand => Any,
			content      => Any
		}, {
			type         => Q{token},
			mode         => Any,
			variant      => Any,
			name         => Q{RULE_REF},
			modifier     => Any,
			lexerCommand => Any,
			content      => Any
		}, {
			type         => Q{token},
			mode         => Any,
			variant      => Any,
			name         => Q{LEXER_CHAR_SET},
			modifier     => Any,
			lexerCommand => Any,
			content      => Any
		} ]
	}, {
		type         => Q{actions},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => Any,
		lexerCommand => Any,
		content  => [ {
			type         => Q{action},
			mode         => Any,
			variant      => Any,
			name         => Q{members},
			modifier     => Any,
			lexerCommand => Any,
			content      => Q:to{END}.chomp,
{
	/** Track whether we are inside of a rule and whether it is lexical parser.
	 */
	public void setCurrentRuleType(int ruleType) {
		this._currentRuleType = ruleType;
	}
}
END
		} ]
	}, {
		type         => Q{rules},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => Any,
		lexerCommand => Any,
		content      => [ { # DOC_COMMENT : '/**' .*? ( '*/' | EOF )? ;
			type         => Q{rule},
			mode         => Any,
			variant      => Any,
			name         => Q{DOC_COMMENT},
			modifier     => Any,
			lexerCommand => Any,
			content => [ {
				type         => Q{alternation},
				mode         => Any,
				variant      => Any,
				name         => Any,
				modifier     => Any,
				lexerCommand => Any,
				content  => [ {
					type         => Q{concatenation},
					mode         => Any,
					variant      => Any,
					name         => Any,
					modifier     => Any,
					content      => [ { # '/**'
						type         => Q{literal},
						mode         => Any,
						variant      => Any,
						name         => Any,
						modifier     => {
							intensifier  => Any,
							greedy       => False,
							complemented => False,
						},
						lexerCommand => Any,
						content      => Q{/**}
					}, { # .*?
						type         => Q{metacharacter},
						mode         => Any,
						variant      => Any,
						name         => Any,
						modifier     => {
							intensifier  => Q{*},
							greedy       => True,
							complemented => False,
						},
						lexerCommand => Any,
						content      => Q{.}
					}, { # ( '*/' | EOF )?
						type         => Q{capturing group},
						mode         => Any,
						variant      => Any,
						name         => Any,
						modifier     => {
							intensifier  => Any,
							greedy       => True,
							complemented => False,
						},
						lexerCommand => Any,
						content      => [ { # '*/'
							type         => Q{alternation},
							mode         => Any,
							variant      => Any,
							name         => Any,
							modifier     => Any,
							lexerCommand => Any,
							content      => [ {
								type         => Q{literal},
								mode         => Any,
								variant      => Any,
								name         => Any,
								modifier     => {
									intensifier  => Any,#Q{?},
									greedy       => False,
									complemented => False,
								},
								lexerCommand => Any,
								content      => Q{*/}
							}, { # EOF
								type         => Q{EOF},
								mode         => Any,
								variant      => Any,
								name         => Any,
								modifier     => {
									intensifier  => Any,
									greedy       => False,
									complemented => False,
								},
								lexerCommand => Any,
								content      => Any
							} ]
						} ]
					} ]
				} ]
			} ]
		}, { # fragment LEXER_CHAR_SET_BODY : ~( ~[\]\\] | '\\' . )+ -> more ;
			type         => Q{rule},
			mode         => Q{LexerCharSet},
			variant      => Q{fragment},
			name         => Q{LEXER_CHAR_SET_BODY},
			modifier     => Any,
			lexerCommand => Q{more},
			content      => [ { # ~( ~[\]\\] | '\\' . )+
				type         => Q{alternation},
				mode         => Any,
				variant      => Any,
				name         => Any,
				modifier     => Any,
				lexerCommand => Any,
				content      => [ { # ~( ~[\]\\] | '\\' . )+
					type         => Q{capturing group},
					mode         => Any,
					variant      => Any,
					name         => Any,
					modifier     => {
						intensifier  => Q{+},
						greedy       => False,
						complemented => True,
					},
					lexerCommand => Any,
					content      => [ { # ~[\]\\]
						type         => Q{character class},
						mode         => Any,
						variant      => Any,
						name         => Any,
						modifier     => {
							intensifier  => Any,
							greedy       => False,
							complemented => True,
						},
						lexerCommand => Any,
						content      => [ { # \]
							type         => Q{literal},
							mode         => Any,
							variant      => Any,
							name         => Any,
							modifier     => {
								intensifier  => Any,
								greedy       => False,
								complemented => False,
							},
							lexerCommand => Any,
							content      => Q{\]}
						}, { # \\
							type         => Q{literal},
							mode         => Any,
							variant      => Any,
							name         => Any,
							modifier     => {
								intensifier  => Any,
								greedy       => False,
								complemented => False,
							},
							lexerCommand => Any,
							content      => Q{\\}
						} ]
					} ]
				}, { # '\\' .
					type         => Q{concatenation},
					mode         => Any,
					variant      => Any,
					name         => Any,
					modifier     => Any,
					lexerCommand => Any,
					content      => [ { # '\\'
						type         => Q{literal},
						mode         => Any,
						variant      => Any,
						name         => Any,
						modifier     => {
							intensifier  => Any,
							greedy       => False,
							complemented => False,
						},
						lexerCommand => Any,
						content      => Q{\\}
					}, { # .
						type         => Q{metacharacter},
						mode         => Any,
						variant      => Any,
						name         => Any,
						modifier     => {
							intensifier  => Any,
							greedy       => False,
							complemented => False,
						},
						lexerCommand => Any,
						content      => Q{.}
					} ]
				} ]
			} ]
		} ]
	} ]
} ], Q{christmas};

# vim: ft=perl6
