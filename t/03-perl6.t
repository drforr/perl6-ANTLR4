use v6;
use ANTLR4::Actions::Perl6;
use Test;

plan 7;

sub parse( $str ) {
	return ANTLR4::Grammar.parse(
		$str, 
		:actions( ANTLR4::Actions::Perl6.new )
	).ast.to-string;
}

# It's most important to test things that can easily translate into Perl 6.
#
# Parametrize types, return types, options, and exceptions won't make sense
# until the C/Java types get translated to Perl 6.

is parse( Q:to[END] ), Q:to[END], 'empty grammar';
grammar Empty;
END
grammar Empty {
}
END

# These will generate errors in Perl because null regexes are illegal.
#
subtest 'empty rule, fragment', {
	# No way to generate an empty token, otherwise it'd be here.
	#
	is parse( Q:to[END] ), Q:to[END], 'empty rule';
	grammar Empty;
	empty : ;
	END
	grammar Empty {
		rule empty {
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'multiple empty rules';
	grammar Empty;
	empty : ;
	emptier : ;
	END
	grammar Empty {
		rule empty {
		}
		rule emptier {
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'empty fragment';
	grammar Empty;
	fragment empty : ;
	END
	grammar Empty {
		rule empty {
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'multiple empty fragments';
	grammar Empty;
	fragment empty : ;
	fragment emptier : ;
	END
	grammar Empty {
		rule empty {
		}
		rule emptier {
		}
	}
	END

	done-testing;
};

# Tokens in ANTLR can't get complex, they're simple strings.
#
subtest 'token', {
	is parse( Q:to[END] ), Q:to[END], 'single token';
	grammar Empty;
	tokens { INDENT }
	END
	grammar Empty {
		token INDENT {
			||	'indent'
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'multiple tokens';
	grammar Empty;
	tokens { INDENT, DEDENT }
	END
	grammar Empty {
		token INDENT {
			||	'indent'
		}
		token DEDENT {
			||	'dedent'
		}
	}
	END

	done-testing;
};

subtest 'rule', {

	subtest 'terminal', {
		is parse( Q:to[END] ), Q:to[END], 'bare';
		grammar Lexer;
		plain : 'terminal' ;
		END
		grammar Lexer {
			rule plain {
				||	terminal
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'multiple terms, letters only';
		grammar Lexer;
		plain : 'terminal' 'station' ;
		END
		grammar Lexer {
			rule plain {
				||	terminal
					station
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'quoted terminal';
		grammar Lexer;
		sign : '-' ;
		END
		grammar Lexer {
			rule sign {
				||	'-'
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'escaped terminal';
		grammar Lexer;
		sign : '\t' ;
		END
		grammar Lexer {
			rule sign {
				||	'\t'
			}
		}
		END

		# Even though ~'t' is valid, 't' in this context isn't a
		# terminal but a (degenerate) character set, I think.
		#
		subtest 'modifiers', {
			is parse( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : 'terminal'? ;
			END
			grammar Lexer {
				rule plain {
					||	terminal?
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : 'terminal'* ;
			END
			grammar Lexer {
				rule plain {
					||	terminal*
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : 'terminal'+ ;
			END
			grammar Lexer {
				rule plain {
					||	terminal+
				}
			}
			END

			done-testing;
		};

		subtest 'greedy modifiers', {
			is parse( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : 'terminal'?? ;
			END
			grammar Lexer {
				rule plain {
					||	terminal??
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : 'terminal'*? ;
			END
			grammar Lexer {
				rule plain {
					||	terminal*?
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : 'terminal'+? ;
			END
			grammar Lexer {
				rule plain {
					||	terminal+?
				}
			}
			END

			done-testing;
		};

		done-testing;
	};

	subtest 'character range', {
		is parse( Q:to[END] ), Q:to[END], 'bare';
		grammar Lexer;
		plain : 'a'..'z' ;
		END
		grammar Lexer {
			rule plain {
				||	<[ a .. z ]>
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'Unicode escape';
		grammar Lexer;
		plain : '\u0300'..'\u036F' ;
		END
		grammar Lexer {
			rule plain {
				||	<[ \x[0300] .. \x[036F] ]>
			}
		}
		END

		subtest 'modifiers', {
			is parse( Q:to[END] ), Q:to[END], 'negation';
			grammar Lexer;
			plain : ~'a'..'z' ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ a .. z ]>
				}
			}
			END

			subtest 'negated modifiers', {
				is parse( Q:to[END] ), Q:to[END], 'question';
				grammar Lexer;
				plain : ~'a'..'z'? ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ a .. z ]>?
					}
				}
				END

				is parse( Q:to[END] ), Q:to[END], 'star';
				grammar Lexer;
				plain : ~'a'..'z'* ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ a .. z ]>*
					}
				}
				END

				is parse( Q:to[END] ), Q:to[END], 'plus';
				grammar Lexer;
				plain : ~'a'..'z'+ ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ a .. z ]>+
					}
				}
				END

				done-testing;
			};

			is parse( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : 'a'..'z'? ;
			END
			grammar Lexer {
				rule plain {
					||	<[ a .. z ]>?
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : 'a'..'z'* ;
			END
			grammar Lexer {
				rule plain {
					||	<[ a .. z ]>*
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : 'a'..'z'+ ;
			END
			grammar Lexer {
				rule plain {
					||	<[ a .. z ]>+
				}
			}
			END

			done-testing;
		};

		subtest 'greedy modifiers', {
			subtest 'negated modifiers', {
				is parse( Q:to[END] ), Q:to[END], 'question';
				grammar Lexer;
				plain : ~'a'..'z'?? ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ a .. z ]>??
					}
				}
				END

				is parse( Q:to[END] ), Q:to[END], 'star';
				grammar Lexer;
				plain : ~'a'..'z'*? ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ a .. z ]>*?
					}
				}
				END

				is parse( Q:to[END] ), Q:to[END], 'plus';
				grammar Lexer;
				plain : ~'a'..'z'+? ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ a .. z ]>+?
					}
				}
				END

				done-testing;
			};

			is parse( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : 'a'..'z'?? ;
			END
			grammar Lexer {
				rule plain {
					||	<[ a .. z ]>??
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : 'a'..'z'*? ;
			END
			grammar Lexer {
				rule plain {
					||	<[ a .. z ]>*?
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : 'a'..'z'+? ;
			END
			grammar Lexer {
				rule plain {
					||	<[ a .. z ]>+?
				}
			}
			END

			done-testing;
		};

		done-testing;
	};

	subtest 'character set', {
		is parse( Q:to[END] ), Q:to[END], 'single character';
		grammar Lexer;
		plain : [c] ;
		END
		grammar Lexer {
			rule plain {
				||	<[ c ]>
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'multiple characters';
		grammar Lexer;
		plain : [char set] ;
		END
		grammar Lexer {
			rule plain {
				||	<[ c h a r   s e t ]>
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'range in charaset';
		grammar Lexer;
		plain : [a-c] ;
		END
		grammar Lexer {
			rule plain {
				||	<[ a .. c ]>
			}
		}
		END

		subtest 'modifiers', {
			is parse( Q:to[END] ), Q:to[END], 'negated';
			grammar Lexer;
			plain : ~[c] ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ c ]>
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'negated multiple chars';
			grammar Lexer;
			plain : ~[cd] ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ c d ]>
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'negated alternate form';
			grammar Lexer;
			plain : ~'c' ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ c ]>
				}
			}
			END

			subtest 'negated modifiers', {
				is parse( Q:to[END] ), Q:to[END], 'question';
				grammar Lexer;
				plain : ~[c]? ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ c ]>?
					}
				}
				END

				is parse( Q:to[END] ), Q:to[END], 'star';
				grammar Lexer;
				plain : ~[c]* ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ c ]>*
					}
				}
				END

				is parse( Q:to[END] ), Q:to[END], 'plus';
				grammar Lexer;
				plain : ~[c]+ ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ c ]>+
					}
				}
				END

				done-testing;
			};

			is parse( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : [c]? ;
			END
			grammar Lexer {
				rule plain {
					||	<[ c ]>?
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : [c]* ;
			END
			grammar Lexer {
				rule plain {
					||	<[ c ]>*
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : [c]+ ;
			END
			grammar Lexer {
				rule plain {
					||	<[ c ]>+
				}
			}
			END

			done-testing;
		};

		subtest 'greedy modifiers', {
			subtest 'negated modifiers', {
				is parse( Q:to[END] ), Q:to[END], 'question';
				grammar Lexer;
				plain : ~[c]?? ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ c ]>??
					}
				}
				END

				is parse( Q:to[END] ), Q:to[END], 'star';
				grammar Lexer;
				plain : ~[c]*? ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ c ]>*?
					}
				}
				END

				is parse( Q:to[END] ), Q:to[END], 'plus';
				grammar Lexer;
				plain : ~[c]+? ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ c ]>+?
					}
				}
				END

				done-testing;
			};

			is parse( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : [c]?? ;
			END
			grammar Lexer {
				rule plain {
					||	<[ c ]>??
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : [c]*? ;
			END
			grammar Lexer {
				rule plain {
					||	<[ c ]>*?
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : [c]+? ;
			END
			grammar Lexer {
				rule plain {
					||	<[ c ]>+?
				}
			}
			END

			done-testing;
		};

		subtest 'alternate form', {
			is parse( Q:to[END] ), Q:to[END], 'negated';
			grammar Lexer;
			plain : ~'c' ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ c ]>
				}
			}
			END

			subtest 'modifiers', {
				is parse( Q:to[END] ), Q:to[END], 'question';
				grammar Lexer;
				plain : ~'c'? ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ c ]>?
					}
				}
				END

				is parse( Q:to[END] ), Q:to[END], 'star';
				grammar Lexer;
				plain : ~'c'* ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ c ]>*
					}
				}
				END

				is parse( Q:to[END] ), Q:to[END], 'plus';
				grammar Lexer;
				plain : ~'c'+ ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ c ]>+
					}
				}
				END

				done-testing;
			};

			subtest 'greedy modifiers', {
				is parse( Q:to[END] ), Q:to[END], 'question';
				grammar Lexer;
				plain : ~'c'?? ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ c ]>??
					}
				}
				END

				is parse( Q:to[END] ), Q:to[END], 'star';
				grammar Lexer;
				plain : ~'c'*? ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ c ]>*?
					}
				}
				END

				is parse( Q:to[END] ), Q:to[END], 'plus';
				grammar Lexer;
				plain : ~'c'+? ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ c ]>+?
					}
				}
				END

				done-testing;
			};

			done-testing;
		};

		done-testing;
	};

	# Again, a little quirk of ANTLR4.
	#
	# Negating a group of things actually means you're negating a character
	# set composed of the alternatives.
	# 
	subtest 'negated character set, subrule form', {
		is parse( Q:to[END] ), Q:to[END], 'single character';
		grammar Lexer;
		plain : ~( 'W' ) ;
		END
		grammar Lexer {
			rule plain {
				||	<-[ W ]>
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'multiple characters';
		grammar Lexer;
		plain : ~( 'W' | 'Y' ) ;
		END
		grammar Lexer {
			rule plain {
				||	<-[ W Y ]>
			}
		}
		END

		subtest 'modifiers', {
			is parse( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : ~( 'W' )? ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ W ]>?
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : ~( 'W' )* ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ W ]>*
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : ~( 'W' )+ ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ W ]>+
				}
			}
			END

			done-testing;
		};

		subtest 'greedy modifiers', {
			is parse( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : ~( 'W' )?? ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ W ]>??
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : ~( 'W' )*? ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ W ]>*?
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : ~( 'W' )+? ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ W ]>+?
				}
			}
			END

			done-testing;
		};

		done-testing;
	};

	# XXX Make sure that wildcard semantics match ANTLR?
	#
	subtest 'wildcard', {
		is parse( Q:to[END] ), Q:to[END], 'bare';
		grammar Lexer;
		plain : . ;
		END
		grammar Lexer {
			rule plain {
				||	.
			}
		}
		END

		subtest 'modifiers', {
			# Negated wildcard is illegal.
			# Good thing too, no idea what it would mean.

			is parse( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : .? ;
			END
			grammar Lexer {
				rule plain {
					||	.?
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : .* ;
			END
			grammar Lexer {
				rule plain {
					||	.*
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : .+ ;
			END
			grammar Lexer {
				rule plain {
					||	.+
				}
			}
			END

			done-testing;
		};

		subtest 'greedy modifiers', {
			# Negated wildcard is illegal.
			# Good thing too, no idea what it would mean.

			is parse( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : .?? ;
			END
			grammar Lexer {
				rule plain {
					||	.??
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : .*? ;
			END
			grammar Lexer {
				rule plain {
					||	.*?
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : .+? ;
			END
			grammar Lexer {
				rule plain {
					||	.+?
				}
			}
			END

			done-testing;
		};

		done-testing;
	};

	subtest 'rule with nonterminal', {
		is parse( Q:to[END] ), Q:to[END], 'bare';
		grammar Lexer;
		plain : Str ;
		END
		grammar Lexer {
			rule plain {
				||	<Str>
			}
		}
		END

		subtest 'modifiers', {

			# Negation is allowed in the grammar but is illegal
			# in the actual language, apparently.

			is parse( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : Str? ;
			END
			grammar Lexer {
				rule plain {
					||	<Str>?
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : Str* ;
			END
			grammar Lexer {
				rule plain {
					||	<Str>*
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : Str+ ;
			END
			grammar Lexer {
				rule plain {
					||	<Str>+
				}
			}
			END

			done-testing;
		};

		subtest 'greedy modifiers', {

			# Negation is allowed in the grammar but is illegal
			# in the actual language, apparently.

			is parse( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : Str?? ;
			END
			grammar Lexer {
				rule plain {
					||	<Str>??
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : Str*? ;
			END
			grammar Lexer {
				rule plain {
					||	<Str>*?
				}
			}
			END

			is parse( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : Str+? ;
			END
			grammar Lexer {
				rule plain {
					||	<Str>+?
				}
			}
			END

			done-testing;
		};

		done-testing;
	};

	done-testing;
};

# No, I'm not going to go through all the permutations of the possible stuff
# inside character ranges, just the basic types outline above.
#
# And I'll bravely assume that other permutations such as C<Str Str> will
# work if these do.
#
subtest 'concatenation, all basic permutations', {
	is parse( Q:to[END] ), Q:to[END], 'terminal,terminal';
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

	is parse( Q:to[END] ), Q:to[END], 'terminal,character range';
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

	is parse( Q:to[END] ), Q:to[END], 'terminal,character set';
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
		is parse( Q:to[END] ), Q:to[END], 'terminal,negated character set';
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

		is parse( Q:to[END] ), Q:to[END], 'terminal,character set with question';
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

		is parse( Q:to[END] ), Q:to[END], 'terminal,character set with star';
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

		is parse( Q:to[END] ), Q:to[END], 'terminal,character set with plus';
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

	is parse( Q:to[END] ), Q:to[END], 'terminal,negated subrule';
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

	is parse( Q:to[END] ), Q:to[END], 'terminal-wildcard';
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

	is parse( Q:to[END] ), Q:to[END], 'terminal-nonterminal';
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

	done-testing;
};

subtest 'alternation, all basic permutations', {
	is parse( Q:to[END] ), Q:to[END], 'terminal-terminal';
	grammar Lexer;
	plain : 'terminal' | 'other' ;
	END
	grammar Lexer {
		rule plain {
			||	terminal
			||	other
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'terminal-character range';
	grammar Lexer;
	plain : 'terminal' | 'a'..'z' ;
	END
	grammar Lexer {
		rule plain {
			||	terminal
			||	<[ a .. z ]>
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'terminal-character set';
	grammar Lexer;
	plain : 'terminal' | [by] ;
	END
	grammar Lexer {
		rule plain {
			||	terminal
			||	<[ b y ]>
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'terminal-negated subrule';
	grammar Lexer;
	plain : 'terminal' | ~('W') ;
	END
	grammar Lexer {
		rule plain {
			||	terminal
			||	<-[ W ]>
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'terminal-wildcard';
	grammar Lexer;
	plain : 'terminal' | . ;
	END
	grammar Lexer {
		rule plain {
			||	terminal
			||	.
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'terminal-nonterminal';
	grammar Lexer;
	plain : 'terminal' | Str ;
	END
	grammar Lexer {
		rule plain {
			||	terminal
			||	<Str>
		}
	}
	END

	done-testing;
};

subtest 'grouping', {
	# No way to generate an empty token, otherwise it'd be here.
	#
	is parse( Q:to[END] ), Q:to[END], 'empty rule';
	grammar Empty;
	empty : ( ) ;
	END
	grammar Empty {
		rule empty {
			||	(
				)
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'empty fragment';
	grammar Empty;
	fragment empty : ( ) ;
	END
	grammar Empty {
		rule empty {
			||	(
				)
		}
	}
	END

	subtest 'modifiers', {
		# a negated group is actually a negated character class, which
		# we checked earlier.
		#
		is parse( Q:to[END] ), Q:to[END], 'question';
		grammar Empty;
		empty : ( )? ;
		END
		grammar Empty {
			rule empty {
				||	(
					)?
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'star';
		grammar Empty;
		empty : ( )* ;
		END
		grammar Empty {
			rule empty {
				||	(
					)*
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'plus';
		grammar Empty;
		empty : ( )+ ;
		END
		grammar Empty {
			rule empty {
				||	(
					)+
			}
		}
		END

		done-testing;
	};

	subtest 'grouped thing', {
		is parse( Q:to[END] ), Q:to[END], 'terminal';
		grammar Empty;
		stuff : ( 'foo' ) ;
		END
		grammar Empty {
			rule stuff {
				||	(	||	foo
					)
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'character range';
		grammar Empty;
		stuff : ( 'a'..'z' ) ;
		END
		grammar Empty {
			rule stuff {
				||	(	||	<[ a .. z ]>
					)
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'character set';
		grammar Empty;
		stuff : ( [c] ) ;
		END
		grammar Empty {
			rule stuff {
				||	(	||	<[ c ]>
					)
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'alternate character set';
		grammar Empty;
		stuff : ( ~'c' ) ;
		END
		grammar Empty {
			rule stuff {
				||	(	||	<-[ c ]>
					)
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'negated character set subrule';
		grammar Empty;
		stuff : ( ~( 'c' ) ) ;
		END
		grammar Empty {
			rule stuff {
				||	(	||	<-[ c ]>
					)
			}
		}
		END

		is parse( Q:to[END] ), Q:to[END], 'wildcard';
		grammar Empty;
		stuff : ( . ) ;
		END
		grammar Empty {
			rule stuff {
				||	(	||	.
					)
			}
		}
		END


		is parse( Q:to[END] ), Q:to[END], 'nonterminal';
		grammar Empty;
		stuff : ( Str ) ;
		END
		grammar Empty {
			rule stuff {
				||	(	||	<Str>
					)
			}
		}
		END

		done-testing;
	};

	is parse( Q:to[END] ), Q:to[END], 'concatenation';
	grammar Empty;
	stuff : ( Str 'testing' ) ;
	END
	grammar Empty {
		rule stuff {
			||	(	||	<Str>
						testing
				)
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'alternation';
	grammar Empty;
	stuff : ( Str | 'testing' ) ;
	END
	grammar Empty {
		rule stuff {
			||	(	||	<Str>
					||	testing
				)
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'nesting';
	grammar Empty;
	stuff : ( ( Str | 'testing' ) ) ;
	END
	grammar Empty {
		rule stuff {
			||	(	||	(	||	<Str>
							||	testing
						)
				)
		}
	}
	END

	is parse( Q:to[END] ), Q:to[END], 'terminal + nesting';
	grammar Empty;
	stuff : ( ( Str | 'testing' ) 'foo' ) ;
	END
	grammar Empty {
		rule stuff {
			||	(	||	(	||	<Str>
							||	testing
						)
						foo
				)
		}
	}
	END

	done-testing;
};

#`(

# The double comment blocks are around bits of the grammar that don't
# necessarily translate into Perl 6.
#
# Taking a much more pragmatic approach this time 'round.

subtest 'grammar basics', {
#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'lexer grammar';
	lexer grammar Empty;
	END
	#|{ "type" : "lexer" }
	grammar Empty {
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'parser grammar';
	parser grammar Empty;
	END
	#|{ "type" : "parser" }
	grammar Empty {
	}
	END
)
)

	done-testing;
};

subtest 'outer options', {
#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'empty options';
	grammar Empty;
	options { }
	END
	#|{ "options" : { } }
	grammar Empty {
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'single option';
	grammar Empty;
	options { tokenVocab=Antlr; }
	END
	#|{ "options" : { "tokenVocab" : "Antlr" } }
	grammar Empty {
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'import';
	grammar Empty;
	import ChristmasParser;
	END
	#|{ "import" : { "ChristmasParser" : null } }
	grammar Empty {
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'import with alias';
	grammar Empty;
	import ChristmasParser=Christmas;
	END
	#|{ "import" : { "ChristmasParser" : "Christmas" } }
	grammar Empty {
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'import with alias';
	grammar Empty;
	@members {
		/** Track whether we are inside of a rule and whether it is lexical parser.
		 */
		public void setCurrentRuleType(int ruleType) {
			this._currentRuleType = ruleType;
		}
	}
	END
	#|{ "actions" : "/** Track whether we are inside of a rule and whether it is lexical parser.
		 */
		public void setCurrentRuleType(int ruleType) {
			this._currentRuleType = ruleType;
		}" }
	grammar Empty {
	}
	END
)
)

	done-testing;
};

subtest 'rule options', {
#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'single rule with options';
	grammar Empty;
	fragment parametrized[String name, int total]
		 returns [int amount] throws XFoo options{I=1;} : ;
	END
	grammar Empty {
		#|{ "type" : "fragment", "parameters" : [ { "type" : "String", "name" : "name" }, { "type" : "int", "name" : "total" } ], "returns" : { "type" : "int", "name" : "amount" }, "throws" : "XFoo", "options" : [ { "key" : "I", "vaue" : "1" } ] }
		rule parametrized {
			||
		}
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'single rule with options';
	grammar Empty;
	public test_catch_locals locals[int n = 0] : ;
		 catch [int amount] {amount++} finally {amount=1}
	END
	grammar Empty {
		#|{ "visibility" : "public", "locals" : "int n = 0", "catch" : { "type" : "int", "name" : "amount", "code" : "amount++" }, "finally" : "amount=1" }
		rule test_catch_locals {
			||
		}
	}
	END
)
)

	done-testing;
};

# '-> more' &c are per-alternative, not at the rule level.
# '<assoc=right> are also per-alternative.
#
subtest 'modes', {
#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'single rule with options';
	grammar Empty;
	plain : ;
	mode Remainder;
		lexer_stuff : ;
	mode SkipThis;
	mode YetAnother;
		parser_stuff : ;
	END
	grammar Empty {
		rule plain {
		}
		#|{ "mode" : "Remainder" }
		rule lexer_stuff {
			||
		}
		#|{ "mode" : "SkipThis" }
		#|{ "mode" : "YetAnother" }
		rule parser_stuff {
			||
		}
	}
	END
)
)

	done-testing;
};

subtest 'lexer rule with single term', {

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'action';
	grammar Lexer;
	plain : {System.out.println("Found end");} ;
	END
	grammar Lexer {
		#|{ "action" : "System.out.println(\"Found end\");" }
		rule plain {
			||	.
		}
	}
	END
)
)

	done-testing;
};

subtest 'actions', {
#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'skip';
	grammar Lexer;
	plain : 'X' -> skip ;
	END
	grammar Lexer {
		#|{ "skip" : true }
		rule plain {
			||	X
		}
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'pushMode';
	grammar Lexer;
	plain : 'X' -> pushMode(INSIDE) ;
	END
	grammar Lexer {
		#|{ "pushMode" : "INSIDE" }
		rule plain {
			||	X
		}
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'popMode';
	grammar Lexer;
	plain : 'X' -> popMode(INSIDE) ;
	END
	grammar Lexer {
		#|{ "popMode" : "INSIDE" }
		rule plain {
			||	X
		}
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'more';
	grammar Lexer;
	plain : 'X' -> more ;
	END
	grammar Lexer {
		#|{ "more" : true }
		rule plain {
			||	X
		}
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'type';
	grammar Lexer;
	plain : 'X' -> type(STRING) ;
	END
	grammar Lexer {
		#|{ "type" : "STRING" }
		rule plain {
			||	X
		}
	}
	END
)
)

#`(
#`(
	is parse( Q:to[END] ), Q:to[END], 'channel';
	grammar Lexer;
	plain : 'X' -> channel(HIDDEN) ;
	END
	grammar Lexer {
		#|{ "channel" : "HIDDEN" }
		rule plain {
			||	X
		}
	}
	END
)
)

	done-testing;
};

)

done-testing;

# vim: ft=perl6
