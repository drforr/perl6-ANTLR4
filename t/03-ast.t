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
grammar Minimal;
options {
	Type=Foo;
}
import MinimalParser, MinimalLexer=Lexer;
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

LEXER_CHAR_SET_BODY : (	~[\]\\] | '\\' . )+ -> more ;

LEXER_CHAR_SET : ']' -> popMode ;

UNTERMINATED_CHAR_SET :	EOF -> popMode ;

END
	:actions($a)
).ast;

#say $parsed;

is-deeply $parsed, [ (
	type         => Q{grammar},
	variant      => Any,
	name         => Q{Minimal},
	modifier     => Any,
	greedy       => Any,
	lexerCommand => Any,
	content      => [ (
		type         => Q{options},
		variant      => Any,
		name         => Any,
		modifier     => Any,
		greedy       => Any,
		lexerCommand => Any,
		content  => [ (
			type         => Q{option},
			variant      => Any,
			name         => Q{Type},
			modifier     => Any,
			greedy       => Any,
			lexerCommand => Any,
			content      => Q{Foo}
		) ]
	), (
		type         => Q{imports},
		variant      => Any,
		name         => Any,
		modifier     => Any,
		greedy       => Any,
		lexerCommand => Any,
		content  => [ (
			type         => Q{import},
			variant      => Any,
			name         => Q{MinimalParser},
			modifier     => Any,
			greedy       => Any,
			lexerCommand => Any,
			content      => Any,
		), (
			type         => Q{import},
			variant      => Any,
			name         => Q{MinimalLexer},
			modifier     => Any,
			greedy       => Any,
			lexerCommand => Any,
			content      => Q{Lexer}
		) ]
	), (
		type         => Q{tokens},
		variant      => Any,
		name         => Any,
		modifier     => Any,
		greedy       => Any,
		lexerCommand => Any,
		content      => [ (
			type         => Q{token},
			variant      => Any,
			name         => Q{TOKEN_REF},
			modifier     => Any,
			greedy       => Any,
			lexerCommand => Any,
			content      => Any
		), (
			type         => Q{token},
			variant      => Any,
			name         => Q{RULE_REF},
			modifier     => Any,
			greedy       => Any,
			lexerCommand => Any,
			content      => Any
		), (
			type         => Q{token},
			variant      => Any,
			name         => Q{LEXER_CHAR_SET},
			modifier     => Any,
			greedy       => Any,
			lexerCommand => Any,
			content      => Any
		) ]
	), (
		type         => Q{actions},
		variant      => Any,
		name         => Any,
		modifier     => Any,
		greedy       => Any,
		lexerCommand => Any,
		content  => [ (
			type         => Q{action},
			variant      => Any,
			name         => Q{members},
			modifier     => Any,
			greedy       => Any,
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
		) ]
	), (
		type         => Q{rules},
		variant      => Any,
		name         => Any,
		modifier     => Any,
		greedy       => Any,
		lexerCommand => Any,
		content      => [ (
			type         => Q{rule},
			variant      => Any,
			name         => Q{DOC_COMMENT},
			modifier     => Any,
			greedy       => Any,
			lexerCommand => Any,
			content => [ (
				type         => Q{alternation},
				variant      => Any,
				name         => Any,
				modifier     => Any,
				greedy       => Any,
				lexerCommand => Any,
				content  => [ (
					type         => Q{concatenation},
					variant      => Any,
					name         => Any,
					modifier     => Any,
					greedy       => Any,
					content      => [ (
						type         => Q{literal},
						variant      => Any,
						name         => Any,
						modifier     => Any,
						greedy       => Any,
						lexerCommand => Any,
						content => Q{/**}
					), (
						type         => Q{metachar},
						variant      => Any,
						name         => Any,
						modifier     => Q{*},
						greedy       => True,
						lexerCommand => Any,
						content      => Q{.}
					), (
						type         => Q{capturing group},
						variant      => Any,
						name         => Any,
						modifier     => Any,
						greedy       => True,
						lexerCommand => Any,
						content      => [ (
							type => Q{alternation},
							variant => Any,
							name => Any,
							modifier => Any,
							greedy => Any,
							lexerCommand => Any,
							content => [ (
								type         => Q{literal},
								variant      => Any,
								name         => Any,
								modifier     => Any,
								greedy       => Any,
								lexerCommand => Any,
								content      => Q{*/}
							), (
								type         => Q{EOF},
								variant      => Any,
								name         => Any,
								modifier     => Any,
								greedy       => Any,
								lexerCommand => Any,
								content      => Any
							) ]
						) ]
					) ]
				) ]
			) ]
		), (
			type         => Q{rule},
			variant      => Q{LexerCharSet},
			name         => Q{LEXER_CHAR_SET_BODY},
			modifier     => Q{*},
			greedy       => True,
			lexerCommand => Q{more},
			content      => Any # ...
		) ]
	) ]
) ], Q{christmas};

# vim: ft=perl6
