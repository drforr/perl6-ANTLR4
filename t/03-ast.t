use v6;
use ANTLR4::Grammar;
use ANTLR4::Actions::AST;
use Test;

plan 13;

sub is-grammar-named( $parsed, $name, $type = Q{DEFAULT} ) {
	return False unless $parsed.<name> eq $name;
	return False unless $parsed.<type> eq $type;
	return True;
}

sub is-rule-named( $parsed, $name ) {
	return False unless $parsed.<name> eq $name;
	return False unless $parsed.<type> eq Q{rule};
	return True;
}

my $a = ANTLR4::Actions::AST.new;
my $g = ANTLR4::Grammar.new;

#
# A brief reminder is in order - Arrayref keys should all be plural, everything
#                                else should be singular.
#
is-deeply $g.parse(
	Q{grammar Minimal;},
	:actions($a)
).ast, {
	type => Q{DEFAULT},
	name => Q{Minimal},
	options => [ ],
	imports => [ ],
	tokens => [ ],
	actions => [ ],
	contents => [ ]
}, Q{Minimal grammar};

#
# When adding a new layer to the datastructure, do just one is-deeply() test.
#
# This way we can show the nested nature of the dataset, without having to
# continually repeat the huge data structures each time.
#
subtest {
	my $parsed;

	plan 5;

	$parsed = $g.parse(
		Q{lexer grammar Name;},
		:actions($a)
	).ast;
	ok is-grammar-named( $parsed, Q{Name}, Q{lexer} );

	subtest {
		subtest {
			$parsed = $g.parse(
				Q{grammar Name; options {a=2;}},
				:actions($a)
			).ast;
			is-deeply $parsed.<options>,
				[ a => 2 ],
				Q{Numeric option};

			$parsed = $g.parse(
				Q{grammar Name; options {a='foo';}},
				:actions($a)
			).ast;
			is-deeply $parsed.<options>,
				[ a => 'foo' ],
				Q{String option};

			$parsed = $g.parse(
				Q{grammar Name; options {a=b;}},
				:actions($a)
			).ast;
			is-deeply $parsed.<options>,
				[ a => [ Q{b} ] ],
				Q{Atomic option};

			done-testing;
		}, Q{Single option};

		$parsed = $g.parse(
			Q{grammar Name; options {a=2;} options {b=3;}},
			:actions($a)
		).ast;
		is-deeply $parsed.<options>,
			[ a => 2, b => 3 ],
			Q{Repeated single option};

		subtest {
			$parsed = $g.parse(
				Q{grammar Name; options {a=b,cde;}},
				:actions($a)
			).ast;
			is-deeply $parsed.<options>, [
				a => [
					Q{b},
					Q{cde}
				]
			], Q{Multiple atomic options};

			$parsed = $g.parse(
				Q{grammar Name; options {a=b,cde;f='foo';}},
				:actions($a)
			).ast;
			is-deeply $parsed.<options>, [
				a => [
					Q{b},
					Q{cde}
				],
				f => Q{foo}
			], Q{Multiple mixed options};

			done-testing;
		}, Q{Multiple options};

		done-testing;
	}, Q{Options};

	subtest {
		$parsed = $g.parse(
			Q{grammar Name; options {a=2;} import Foo;},
			:actions($a)
		).ast;
		is-deeply $parsed.<imports>, [
			Foo => Nil
		], Q{Single import};

		subtest {
			$parsed = $g.parse(
				Q{grammar Name; options {a=2;} import Foo,Bar;},
				:actions($a)
			).ast;
			is-deeply $parsed.<imports>, [
				Foo => Nil,
				Bar => Nil
			], Q{Two grammars};

			$parsed = $g.parse(
				Q{grammar Name; options {a=2;} import Foo,Bar=Test;},
				:actions($a)
			).ast;
			is-deeply $parsed.<imports>, [
				Foo => Nil,
				Bar => Q{Test}
			], Q{Two grammars, last aliased};

			done-testing;
		}, Q{Multiple imports};

		done-testing;
	}, Q{Import};

	subtest {
		$parsed = $g.parse(
			q{grammar Name; tokens { INDENT }},
			:actions($a)
		).ast;
		is-deeply $parsed.<tokens>, [
			Q{INDENT}
		], Q{Single token};

		$parsed = $g.parse(
			Q{grammar Name; tokens { INDENT, DEDENT }},
			:actions($a)
		).ast;
		is-deeply $parsed.<tokens>, [
			Q{INDENT},
			Q{DEDENT}
		], Q{Multiple tokens};

		done-testing;
	}, Q{Tokens};

	subtest {
		$parsed = $g.parse(
			q{grammar Name; @members { protected int curlies = 0; }},

			:actions($a)
		).ast;
		is-deeply $parsed.<actions>, [
			Q{@members} => '{ protected int curlies = 0; }' ],
			Q{Single action};

		$parsed = $g.parse(
			Q{grammar Name;
				@members { protected int curlies = 0; }
				@sample::stuff { 1; }},
			:actions($a)
		).ast;
		is-deeply $parsed.<actions>, [
			Q{@members} => Q[{ protected int curlies = 0; }],
			Q{@sample::stuff} => Q[{ 1; }]
		], Q{Multiple tokens};

		done-testing;
	}, Q{Actions};
}, Q{Top-level keys};

# Concern ourselves with the next layer down now, dive into the <contents>.
#
my $parsed = $g.parse(
	Q{grammar Name; number : '1' ;},
	:actions($a)
).ast;
ok is-grammar-named( $parsed, Q{Name} );
ok is-rule-named( $parsed.<contents>[0], Q{number} );
is-deeply $parsed.<contents>[0]<contents>, [ ${
	type     => Q{alternation},
	label    => Nil,
	options  => [ ],
	commands => [ ],
	contents => [${
		type     => Q{concatenation},
		label    => Nil,
		options  => [ ],
		commands => [ ],
		contents => [${
			type         => Q{terminal},
			content      => Q{1},
			alias        => Nil,
			modifier     => Nil,
			greedy       => False,
			complemented => False
		}]
	}]
}], Q{Single rule};

subtest {
	my $parsed;

	$parsed = $g.parse(
		Q{grammar Name; number [int x] : '1' ;},
		:actions($a)
	).ast;
	ok is-grammar-named( $parsed, Q{Name} );
	ok is-rule-named( $parsed.<contents>[0], Q{number} );
	is-deeply $parsed.<contents>[0]<action>,
		Q{[int x]},
		Q{Action};

	$parsed = $g.parse(
		Q{grammar Name; protected number : '1' ;},
		:actions($a)
	).ast;
	ok is-grammar-named( $parsed, Q{Name} );
	ok is-rule-named( $parsed.<contents>[0], Q{number} );
	is-deeply $parsed.<contents>[0]<attribute>,
		Q{protected},
		Q{Attribute};

	$parsed = $g.parse(
		Q{grammar Name; number returns [int x] : '1' ;},
		:actions($a)
	).ast;
	ok is-grammar-named( $parsed, Q{Name} );
	ok is-rule-named( $parsed.<contents>[0], Q{number} );
	is-deeply $parsed.<contents>[0]<return>,
		Q{[int x]},
		Q{Returns};

	subtest {
		my $parsed;

		$parsed = $g.parse(
			Q{grammar Name; number throws XFoo : '1' ;},
			:actions($a)
		).ast;
		ok is-grammar-named( $parsed, Q{Name} );
		ok is-rule-named( $parsed.<contents>[0], Q{number} );
		is-deeply $parsed.<contents>[0]<throws>, [
			Q{XFoo}
		], Q{Single exception};

		$parsed = $g.parse(
			Q{grammar Name; number throws XFoo, XBar : '1' ;},
			:actions($a)
		).ast;
		ok is-grammar-named( $parsed, Q{Name} );
		ok is-rule-named( $parsed.<contents>[0], Q{number} );
		is-deeply $parsed.<contents>[0]<throws>, [
			Q{XFoo},
			Q{XBar}
		], Q{Multiple exceptions};

		done-testing;
	}, Q{Throws};

	$parsed = $g.parse(
		Q{grammar Name; number locals [int x] : '1' ;},
		:actions($a)
	).ast;
	ok is-grammar-named( $parsed, Q{Name} );
	ok is-rule-named( $parsed.<contents>[0], Q{number} );
	is-deeply $parsed.<contents>[0]<local>,
		Q{[int x]},
		Q{Locals};

	$parsed = $g.parse(
		Q{grammar Name; number options{a=2;} : '1' ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<options>, [
		a => 2
	], Q{Options};

	done-testing;
}, Q{Rule-level keys};

# Nothing at the second layer, apparently

subtest {
	my $parsed;

	plan 3;

	$parsed = $g.parse(
		Q{grammar Name; number : '1' ;},
		:actions($a)
	).ast;
	is $parsed.<contents>[0]<contents>[0]<contents>[0]<type>,
		Q{concatenation},
		Q{Type};

	$parsed = $g.parse(
		Q{grammar Name; number : '1' # One ;},
		:actions($a)
	).ast;
	is $parsed.<contents>[0]<contents>[0]<contents>[0]<label>,
		Q{One},
		Q{Label};

	$parsed = $g.parse(
		Q{grammar Name; number : <assoc=right> '1' ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<options>, [
		assoc => Q{right}
	], Q{Options};

	# Testing the command actually changes top-level stuff

}, Q{Third layer of rule};

# Skip over the outer <contents> portion.
#
$parsed = $g.parse(
	Q{grammar Name; number : '1' -> channel(HIDDEN) ;},
	:actions($a)
).ast;
is-rule-named( $parsed.<contents>[0], Q{number} );
is-deeply $parsed.<contents>, [ ${
	type      => Q{rule},
	name      => Q{number},
	attribute => Nil,
	action    => Nil,
	return    => Nil,
	throws    => [ ],
	local     => Nil,
	options   => [ ],
	contents  => [${
		type     => Q{alternation},
		label    => Nil,
		options  => [ ],
		commands => [ ],
		contents => [${
			type     => Q{concatenation},
			label    => Nil,
			options  => [ ],
			commands => [
				channel => Q{HIDDEN}
			],
			contents => [${
				type         => Q{terminal},
				content      => Q{1},
				alias        => Nil,
				modifier     => Nil,
				greedy       => False,
				complemented => False
			}]
		}]
	}]
}], Q{Single lexer rule};

#`(
# Skip over the outer <contents> portion
#
$parsed = $g.parse(
	q{grammar Name; number : '1' {action++;} ;},
	:actions($a)
).ast;
is-deeply $parsed.<contents>, [ ${
	type      => 'rule',
	name      => 'number',
	attribute => Nil,
	action    => Nil,
	return    => Nil,
	throws    => [ ],
	local     => Nil,
	options   => [ ],
	contents  => [${
		type     => 'alternation',
		label    => Nil,
		options  => [ ],
		commands => [ ],
		contents => [${
			type     => 'concatenation',
			label    => Nil,
			options  => [ ],
			commands => [ ],
			contents => [{
				type         => Q{terminal},
				content      => Q{1},
				alias        => Nil,
				modifier     => Nil,
				greedy       => False,
				complemented => False
			}, {
				type         => Q{action},
				content      => Q[{action++;}],
				alias        => Nil,
				modifier     => Nil,
				greedy       => False,
				complemented => False
			}]
		}]
	}]
}], Q{Single rule with associated action};
)

subtest {
	my $parsed;

#`(
	# Skip over the outer <contents> portion
	#
	is-deeply $g.parse(
		Q{grammar Name; number : ( '1' ) ;},
		:actions($a)
	).ast.<contents>, [ ${
		type      => 'rule',
		name      => 'number',
		attribute => [ ],
		action    => Nil,
		return    => Nil,
		throws    => [ ],
		local     => Nil,
		options   => [ ],
		contents  => [${
			type     => 'alternation',
			label    => Nil,
			options  => [ ],
			commands => [ ],
			contents => [${
				type      => 'concatenation',
				label    => Nil,
				options  => [ ],
				commands => [ ],
				contents => [${
					type         => 'capturing group',
					alias        => Nil,
					modifier     => Nil,
					greedy       => False,
					complemented => False,
					content => [{
						type     => 'concatenation',
						label    => Nil,
						options  => [ ],
						commands => [ ],
						content  => [${
							type         => 'terminal',
							 content      => '1',
							 alias        => Nil,
							 modifier     => Nil,
							 greedy       => False,
							 complemented => False
						}]
					}]
				}]
			}]
		}]
	}], Q{Single rule with options and capturing group};
)

#`(
	# Skip over the outer <contents> portion
	#
	is-deeply $g.parse(
		Q{grammar Name; number : ( '1' '2' ) -> skip ;},
		:actions($a)
	).ast.<contents>, [ ${
		type      => 'rule',
		name      => 'number',
		attribute => [ ],
		action    => Nil,
		return    => Nil,
		throws    => [ ],
		local     => Nil,
		options   => [ ],
		contents  => [{
			type     => 'alternation',
			label    => Nil,
			options  => [ ],
			commands => [ ],
			contents => [{
				type      => 'concatenation',
				label    => Nil,
				options  => [ ],
				commands => [ skip => Nil ],
				contents => [{
					type         => 'capturing group',
					alias        => Nil,
					modifier     => Nil,
					greedy       => False,
					complemented => False,
					content => [{
						type    => 'alternation',
						label   => Nil,
						options => [ ],
						command => [ ],
						contents => [{
							type     => 'concatenation',
							label    => Nil,
							options  => [ ],
							commands => [ ],
							contents => [{
								type         => 'terminal',
								content      => '1',
								alias        => Nil,
								modifier     => Nil,
								greedy       => False,
								complemented => False
									},
{ type         => 'terminal',
content      => '2',
alias        => Nil,
modifier     => Nil,
greedy       => False,
complemented => False }] }] }] }] }] }]
	}], Q{Single rule with options and skipped capturing group};
)

#`(
	# Skip over the <contents> portion
	#
	is-deeply $g.parse(
	    Q{grammar Name; number : ( '1' | '2' ) -> skip ;},
	    :actions($a)
	).ast.<contents>, [ ${
		type      => 'rule',
		name      => 'number',
		attribute => [ ],
		action    => Nil,
		return    => Nil,
		throws    => [ ],
		local     => Nil,
		options   => [ ],
		contents  => [{
			 type     => 'alternation',
			label    => Nil,
			options  => [ ],
			commands => [ ],
			contents => [{
				type      => 'concatenation',
				label    => Nil,
				options  => [ ],
				commands => $[ skip => Nil ],
				contents => [{
					type         => 'capturing group',
					alias        => Nil,
					modifier     => Nil,
					greedy       => False,
					complemented => False,
					contents     => [{
						type    => 'alternation',
						label   => Nil,
						options => [ ],
						command => [ ],
						contents => [{
							type     => 'concatenation',
							label    => Nil,
							options  => [ ],
							commands => [ ],
							contents => [{
								type         => 'terminal',
								content      => '1',
								alias        => Nil,
								modifier     => Nil,
								greedy       => False,
								complemented => False
							}]
						}, {
							type     => 'concatenation',
							label    => Nil,
							options  => [ ],
							commands => [ ],
							contents => [{
								type         => 'terminal',
								content      => '2',
								alias        => Nil,
								modifier     => Nil,
								greedy       => False,
								complemented => False
							}]
						}]
					}]
				}]
			}]
		}]
	}], Q{grammar with options and skipped capturing group};
)

#`(
	# Skip over the <contents> portion
	#
	is-deeply $g.parse(
		Q{grammar Name; number : ( '1' ) -> skip ;},
		:actions($a)
	).ast.<contents>, [{
		type      => 'rule',
		name      => 'number',
		attribute => [ ],
		action    => Nil,
		return    => Nil,
		throws    => [ ],
		local     => Nil,
		options   => [ ],
		contents  => [{
			type     => 'alternation',
			label    => Nil,
			options  => [ ],
			commands => [ ],
			contents => [${
				type    => 'concatenation',
				label    => Nil,
				options  => [ ],
				commands => [ skip => Nil ],
				contents => [{
					type         => 'capturing group',
					alias        => Nil,
					modifier     => Nil,
					greedy       => False,
					complemented => False,
					contents => [{
						type    => 'alternation',
						label   => Nil,
						options => [ ],
						command => [ ],
						contents => [{
							type     => 'concatenation',
							label    => Nil,
							options  => [ ],
							commands => [ ],
							contents => [{
								type         => 'terminal',
								content      => '1',
								alias        => Nil,
								modifier     => Nil,
								greedy       => False,
								complemented => False
							}]
						}]
					}]
				}]
			}]
		}]
	}], Q{grammar with options and skipped capturing group};
)

#`(
	# Skip over the outer <contents> portion
	#
	is-deeply $g.parse(
		Q{grammar Name; number : ( '1' )+? ;},
		:actions($a)
	).ast.<contents>, [ ${
		type      => 'rule',
		name      => 'number',
		attribute => [ ],
		action    => Nil,
		return    => Nil,
		throws    => [ ],
		local     => Nil,
		options   => [ ],
		contents  => [${
			type     => 'alternation',
			label    => Nil,
			options  => [ ],
			commands => [ ],
			contents => [${
				type     => 'concatenation',
				label    => Nil,
				options  => [ ],
				commands => [ ],
				contents => [${
					type         => 'capturing group',
					alias        => Nil,
					modifier     => '+',
					greedy       => True,
					complemented => False,
					contents     => [{
						type     => 'concatenation',
						label    => Nil,
						options  => [ ],
						commands => [ ],
						contents => [${
							type         => 'terminal',
							content      => '1',
							alias        => Nil,
							modifier     => Nil,
							greedy       => False,
							complemented => False
						}]
					}]
				}]
			}]
		}]
	}], Q{grammar with options and single simple rule};
)

	done-testing;
}, Q{single rule with capture};

subtest {
	my $parsed;

	$parsed = $g.parse(
		Q{grammar Name; number : '1' ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0], {
		type     => 'concatenation',
		label    => Nil, 
		options  => [ ],
		commands => [ ],
		contents => [${
			type         => 'terminal',
			content      => '1',
			alias        => Nil,
			modifier     => Nil,
			greedy       => False,
			complemented => False
		}]
	}, Q{terminal};

#`(
	$parsed = $g.parse(
		q{grammar Name; number : ~'1'+? ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0], {
		type     => Q{concatenation},
		label    => Nil, 
		options  => [ ],
		commands => [ ],
		contents => [${
			type         => Q{terminal},
			content      => Q{1},
			alias        => Nil,
			modifier     => Q{+},
			greedy       => True,
			complemented => True
		}]
	}, Q{terminal with options};
)

#`(
	$parsed = $g.parse(
		Q{grammar Name; number : digits ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0], {
		type         => Q{nonterminal},
		content      => Q{digits},
		alias        => Nil,
		modifier     => Nil,
		greedy       => False,
		complemented => False
	}, Q{nonterminal};
)

#`(
	$parsed = $g.parse(
		q{grammar Name; number : ~digits+? ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0], {
		type         => Q{nonterminal},
		content      => Q{digits},
		alias        => Nil,
		modifier     => Q{+},
		greedy       => True,
		complemented => True
	}, Q{nonterminal with all flags};
)

#`(
	$parsed = $g.parse(
		q{grammar Name; number : [0-9] ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0], {
		type         => Q{character class},
		contents     => [
			Q{0-9}
		],
		alias        => Nil,
		modifier     => Nil,
		greedy       => False,
		complemented => False
	}, Q{character class};
)

#`(
	$parsed = $g.parse(
		q{grammar Name; number : ~[0-9]+? ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0], {
		type         => Q{character class},
		contents     => [
			 Q{0-9}
		],
		alias        => Nil,
		modifier     => Q{+},
		greedy       => True,
		complemented => True
	}, Q{character class with all flags};
)

#`(
	$parsed = $g.parse(
		q{grammar Name; number : 'a'..'f' ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0], {
		type         => Q{range},
		contents     => [{
			from => Q{a},
			to   => Q{f}
		}],
		alias        => Nil,
		modifier     => Nil,
		greedy       => False,
		complemented => False
	}, Q{range};
)

#`(
	$parsed = $g.parse(
		q{grammar Name; number : . ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0], {
		type         => Q{regular expression},
		content      => Q{.},
		alias        => Nil,
		modifier     => Nil,
		greedy       => False,
		complemented => False
	}, Q{regular expression};
)

	done-testing;
}, Q{rule with single term, no options};

subtest {
	my $parsed;

#`(
	$parsed = $g.parse(
		q{grammar Name; number : ~'1'+? -> skip ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0], {
		type     => Q{concatenation},
		label    => Nil, 
		options  => [ ],
		commands => [
			skip => Nil
		],
		contents => [{
			type         => Q{terminal},
			content      => Q{1},
			alias        => Nil,
			modifier     => Q{+},
			greedy       => True,
			complemented => True
		}]
	}, Q{skip};
)

#`(
$parsed = $g.parse(
	q{grammar Name; number : ~'1'+? -> channel(HIDDEN) ;},
	:actions($a)
).ast;
is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0], {
	type         => 'terminal',
	content      => '1',
	alias        => Nil,
	modifier     => '+',
	greedy       => True,
	complemented => True
}, Q{channeled terminal};
)

#`(
$parsed = $g.parse(
	q{grammar Name; number : digits -> channel(HIDDEN) ;},
	:actions($a)
).ast;
is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0], {
	type         => Q{nonterminal},
	content      => Q{digits},
	alias        => Nil,
	modifier     => Nil,
	greedy       => False,
	complemented => False
}, Q{Channeled rule with nonterminal};
)

#`(
$parsed = $g.parse(
	q{grammar Name; number : ~digits+? -> channel(HIDDEN) ;},
	:actions($a)
).ast;
is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0], {
	type         => Q{nonterminal},
	content      => Q{digits},
	alias        => Nil,
	modifier     => Q{+},
	greedy       => True,
	complemented => True
}, Q{Channeled rule with nonterminal};
)

#`(
$parsed = $g.parse(
	q{grammar Name; number : [0-9] -> channel(HIDDEN) ;},
	:actions($a)
).ast;
is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0], {
	type         => Q{character class},
	contents     => [
		Q{0-9}
	],
	alias        => Nil,
	modifier     => Nil,
	greedy       => False,
	complemented => False
}, Q{Channeled rule with character class};
)

#`(
$parsed = $g.parse(
	Q{grammar Name; number : ~[0-9]+? -> channel(HIDDEN) ;},
	:actions($a)
).ast;
is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0], {
	type         => Q{character class},
	contents     => [
		Q{0-9}
	],
	alias        => Nil,
	modifier     => Q{+},
	greedy       => True,
	complemented => True
}, Q{Channeled rule with character class};
)

#`(
$parsed = $g.parse(
	Q{grammar Name; number : 'a'..'f' -> channel(HIDDEN) ;},
	:actions($a)
).ast;
is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0]<contents>[0], {
	type         => Q{range},
	contents     => [{
		from => Q{a},
		to   => Q{f}
	}],
	alias        => Nil,
	modifier     => Nil,
	greedy       => False,
	complemented => False
}, Q{Channeled rule with range};
)

	done-testing;
}, Q{command};

subtest {
	my $parsed;

#`(
	$parsed = $g.parse(
		q{grammar Name; number : ~'1'+? # One ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0], {
		type     => Q{concatenation},
		label    => Q{One},
		options  => [ ],
		commands => [ ],
		contents => [${
			type         => Q{terminal},
			content      => Q{1},
			alias        => Nil,
			alias        => Nil,
			modifier     => Q{+},
			greedy       => True,
			complemented => True
			}]
	}, Q{rule with flags};
)

#`(
	$parsed = $g.parse(
		q{grammar Name; number : ~[]+? # One ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0], {
		type     => Q{concatenation},
		label    => Q{One},
		options  => [ ],
		commands => [ ],
		contents => [${
			type         => Q{character class},
			contents     => [ ],
			alias        => Nil,
			modifier     => Q{+},
			greedy       => True,
			complemented => True
		}]
	},
	Q{character class with flags};
)

#`(
	$parsed = $g.parse(
		q{grammar Name; number : ~[0]+? # One ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0], {
		type     => Q{concatenation},
		label    => Q{One},
		options  => [ ],
		commands => [ ],
		contents => [${
			type         => Q{character class},
			contents     => [
				Q{0}
			],
			alias        => Nil,
			modifier     => Q{+},
			greedy       => True,
			complemented => True
		}]
	},
	Q{character class with flags};
)

#`(
	$parsed = $g.parse(
		q{grammar Name; number : ~[0-9]+? # One ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0], {
		type     => Q{concatenation},
		label    => Q{One},
		options  => [ ],
		commands => [ ],
		contents => [${
			type         => Q{character class},
			contents     => [
				Q{0-9}
			],
			alias        => Nil,
			modifier     => Q{+},
			greedy       => True,
			complemented => True
		}]
	},
	Q{character class with flags};
)

#`(
	$parsed = $g.parse(
		q{grammar Name; number : ~[-0-9]+? # One ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0], {
		type     => Q{concatenation},
		label    => Q{One},
		options  => [ ],
		commands => [ ],
		contents => [${
			type         => Q{character class},
			contents     => [
				Q{-},
				Q{0-9}
			],
			alias        => Nil,
			modifier     => Q{+},
			greedy       => True,
			complemented => True
		}]
	}, Q{character class with lone hyphen and flags};
)

#`(
	$parsed = $g.parse(
		q{grammar Name; number : ~[-0-9\f\u000d]+? # One ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0], {
		type     => Q{concatenation},
		label    => Q{One},
		options  => [ ],
		commands => [ ],
		contents => [${
			type         => Q{character class},
			contents     => [
				Q{-},
				Q{0-9},
				Q{\\f},
				Q{\\u000d}
			],
			alias        => Nil,
			modifier     => Q{+},
			greedy       => True,
			complemented => True
		}]
	}, Q{character class with lone hyphen and flags};
)

#`(
	$parsed = $g.parse(
		q{grammar Name; number : ~non_digits+? # One ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0], {
		type     => Q{concatenation},
		label    => Q{One},
		options  => [ ],
		commands => [ ],
		contents => [${
			type         => Q{nonterminal},
			content      => Q{non_digits},
			alias        => Nil,
			modifier     => Q{+},
			greedy       => True,
			complemented => True
		}]
	}, Q{character class with lone hyphen and flags};
)

#`(
	$parsed = $g.parse(
		q{grammar Name; number : 'a'..'z' # One ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0], {
		type     => Q{concatenation},
		label    => Q{One},
		options  => [ ],
		commands => [ ],
		contents => [${
			type         => Q{range},
			contents     => [{
				from => Q{a},
				to   => Q{z}
			}],
			alias        => Nil,
			modifier     => Nil,
			greedy       => False,
			complemented => False
		}]
	}, Q{range};
)

#`(
	$parsed = $g.parse(
		Q{grammar Name; number : 'a'..'z'+? # One ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0]<contents>[0], {
		type     => Q{concatenation},
		label    => Q{One},
		options  => [ ],
		commands => [ ],
		contents => [${
			type         => Q{range},
			contents     => [{
				from => Q{a},
				to   => Q{z}
			}],
			alias        => Nil,
			modifier     => Q{+},
			greedy       => True,
			complemented => False
		}]
	}, Q{range with greed};
)

	done-testing;
}, q{labeled rule};

subtest {
	my $parsed;

#`(
	$parsed = $g.parse(
		Q{grammar Name; number : ~non_digits+? ~[-0-9\f\u000d]+? # One ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0], {
		type     => Q{alternation},
		label    => Nil,
		options  => [ ],
		commands => [ ],
		contents => [${
			type     => Q{concatenation},
			label    => Q{One},
			options  => [ ],
			commands => [ ],
			contents => [{
				type         => Q{nonterminal},
				content      => Q{non_digits},
				alias        => Nil,
				modifier     => '+',
				greedy       => True,
				complemented => True
			}, {
				type         => Q{character class},
				contents     => [
					Q{-},
					Q{0-9},
					Q{\\f},
					Q{\\u000d}
				],
				alias        => Nil,
				modifier     => Q{+},
				greedy       => True,
				complemented => True
			}]
		}]
	}, Q{rule with multiple concatenated terms};
)

#`(
	$parsed = $g.parse(
		Q{grammar Name; number : ~non_digits+? | ~[-0-9\f\u000d]+? # One ;},
		:actions($a)
	).ast;
	is-deeply $parsed.<contents>[0]<contents>[0], {
	type     => 'alternation',
	label    => Nil,
	options  => [ ],
	commands => [ ],
	contents => [{
		type     => Q{concatenation},
		label    => Nil,
		options  => [ ],
		commands => [ ],
		contents => [${
			type         => Q{nonterminal},
			content      => Q{non_digits},
			alias        => Nil,
			modifier     => Q{+},
			greedy       => True,
			complemented => True
			}]
		}, {
			type     => Q{concatenation},
			label    => Q{One},
			options  => [ ],
			commands => [ ],
			contents => [${
				type         => Q{character class},
				contents     => [
					Q{-},
					Q{0-9},
					Q{\\f},
					Q{\\u000d}
				],
				alias        => Nil,
				modifier     => Q{+},
				greedy       => True,
				complemented => True
			}]
		}]
	}, Q{rule with multiple alternating terms};
)

	done-testing;
}, q{multiple terms};

# vim: ft=perl6
