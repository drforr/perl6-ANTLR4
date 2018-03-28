use v6;
use ANTLR4::Grammar;
use Test;

plan 4;

sub compiled-match( $orig, $expected ) {
	ANTLR4::Grammar.to-string( $orig ) eq $expected
}

# It's most important to test things that can easily translate into Perl 6.
#
# Parametrize types, return types, options, and exceptions won't make sense
# until the C/Java types get translated to Perl 6.

ok compiled-match( Q:to[END], Q:to[END] ), 'empty grammar';
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
	ok compiled-match( Q:to[END], Q:to[END] ), 'empty rule';
	grammar Empty;
	empty : ;
	END
	grammar Empty {
		rule empty {
		}
	}
	END

	ok compiled-match( Q:to[END], Q:to[END] ), 'multiple empty rules';
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

	ok compiled-match( Q:to[END], Q:to[END] ), 'empty fragment';
	grammar Empty;
	fragment empty : ;
	END
	grammar Empty {
		rule empty {
		}
	}
	END

	ok compiled-match( Q:to[END], Q:to[END] ), 'multiple empty fragments';
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
	ok compiled-match( Q:to[END], Q:to[END] ), 'single token';
	grammar Empty;
	tokens { INDENT }
	END
	grammar Empty {
		token INDENT {
			||	'indent'
		}
	}
	END

	ok compiled-match( Q:to[END], Q:to[END] ), 'multiple tokens';
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
		ok compiled-match( Q:to[END], Q:to[END] ), 'bare';
		grammar Lexer;
		plain : 'terminal' ;
		END
		grammar Lexer {
			rule plain {
				||	terminal
			}
		}
		END

		ok compiled-match( Q:to[END], Q:to[END] ), 'multiple terms, letters only';
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

		ok compiled-match( Q:to[END], Q:to[END] ), 'quoted terminal';
		grammar Lexer;
		sign : '-' ;
		END
		grammar Lexer {
			rule sign {
				||	'-'
			}
		}
		END

		ok compiled-match( Q:to[END], Q:to[END] ), 'escaped terminal';
		grammar Lexer;
		sign : '\t' ;
		END
		grammar Lexer {
			rule sign {
				||	'\t'
			}
		}
		END

		ok compiled-match( Q:to[END], Q:to[END] ), 'Unicode terminal';
		grammar Lexer;
		sign : 'Hello\u236a' ;
		END
		grammar Lexer {
			rule sign {
				||	'Hello\x[236a]'
			}
		}
		END

		# Even though ~'t' is valid, 't' in this context isn't a
		# terminal but a (degenerate) character set, I think.
		#
		subtest 'modifiers', {
			ok compiled-match( Q:to[END], Q:to[END] ), 'question';
			grammar Lexer;
			plain : 'terminal'? ;
			END
			grammar Lexer {
				rule plain {
					||	terminal?
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'star';
			grammar Lexer;
			plain : 'terminal'* ;
			END
			grammar Lexer {
				rule plain {
					||	terminal*
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
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
			ok compiled-match( Q:to[END], Q:to[END] ), 'question';
			grammar Lexer;
			plain : 'terminal'?? ;
			END
			grammar Lexer {
				rule plain {
					||	terminal??
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'star';
			grammar Lexer;
			plain : 'terminal'*? ;
			END
			grammar Lexer {
				rule plain {
					||	terminal*?
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
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

	subtest 'negated terminal (character)', {
		ok compiled-match( Q:to[END], Q:to[END] ), 'negated alternate form';
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
			ok compiled-match( Q:to[END], Q:to[END] ), 'question';
			grammar Lexer;
			plain : ~'c'? ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ c ]>?
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'star';
			grammar Lexer;
			plain : ~'c'* ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ c ]>*
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
			grammar Lexer;
			plain : ~'c'+ ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ c ]>+
				}
			}
			END
		};

		subtest 'greedy modifiers', {
			ok compiled-match( Q:to[END], Q:to[END] ), 'question';
			grammar Lexer;
			plain : ~'c'?? ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ c ]>??
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'star';
			grammar Lexer;
			plain : ~'c'*? ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ c ]>*?
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
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

	subtest 'dotted character range', {
		ok compiled-match( Q:to[END], Q:to[END] ), 'bare';
		grammar Lexer;
		plain : 'a'..'z' ;
		END
		grammar Lexer {
			rule plain {
				||	<[ a .. z ]>
			}
		}
		END

		ok compiled-match( Q:to[END], Q:to[END] ), 'bare';
		grammar Lexer;
		plain : 'a'..']' ;
		END
		grammar Lexer {
			rule plain {
				||	<[ a .. \] ]>
			}
		}
		END

		ok compiled-match( Q:to[END], Q:to[END] ), 'Unicode escape';
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
			ok compiled-match( Q:to[END], Q:to[END] ), 'negation';
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
				ok compiled-match( Q:to[END], Q:to[END] ), 'question';
				grammar Lexer;
				plain : ~'a'..'z'? ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ a .. z ]>?
					}
				}
				END

				ok compiled-match( Q:to[END], Q:to[END] ), 'star';
				grammar Lexer;
				plain : ~'a'..'z'* ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ a .. z ]>*
					}
				}
				END

				ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
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

			ok compiled-match( Q:to[END], Q:to[END] ), 'question';
			grammar Lexer;
			plain : 'a'..'z'? ;
			END
			grammar Lexer {
				rule plain {
					||	<[ a .. z ]>?
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'star';
			grammar Lexer;
			plain : 'a'..'z'* ;
			END
			grammar Lexer {
				rule plain {
					||	<[ a .. z ]>*
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
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
				ok compiled-match( Q:to[END], Q:to[END] ), 'question';
				grammar Lexer;
				plain : ~'a'..'z'?? ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ a .. z ]>??
					}
				}
				END

				ok compiled-match( Q:to[END], Q:to[END] ), 'star';
				grammar Lexer;
				plain : ~'a'..'z'*? ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ a .. z ]>*?
					}
				}
				END

				ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
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

			ok compiled-match( Q:to[END], Q:to[END] ), 'question';
			grammar Lexer;
			plain : 'a'..'z'?? ;
			END
			grammar Lexer {
				rule plain {
					||	<[ a .. z ]>??
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'star';
			grammar Lexer;
			plain : 'a'..'z'*? ;
			END
			grammar Lexer {
				rule plain {
					||	<[ a .. z ]>*?
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
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

	subtest 'bracketed character set', {
		ok compiled-match( Q:to[END], Q:to[END] ), 'single character';
		grammar Lexer;
		plain : [c] ;
		END
		grammar Lexer {
			rule plain {
				||	<[ c ]>
			}
		}
		END

		ok compiled-match( Q:to[END], Q:to[END] ), 'Unicode character';
		grammar Lexer;
		plain : [\u000C] ;
		END
		grammar Lexer {
			rule plain {
				||	<[ \x[000C] ]>
			}
		}
		END

		ok compiled-match( Q:to[END], Q:to[END] ), 'close-bracket';
		grammar Lexer;
		plain : [\]] ;
		END
		grammar Lexer {
			rule plain {
				||	<[ \] ]>
			}
		}
		END

		subtest 'modifiers', {
			ok compiled-match( Q:to[END], Q:to[END] ), 'negated';
			grammar Lexer;
			plain : ~[c] ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ c ]>
				}
			}
			END

			subtest 'negated modifiers', {
				ok compiled-match( Q:to[END], Q:to[END] ), 'question';
				grammar Lexer;
				plain : ~[c]? ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ c ]>?
					}
				}
				END

				ok compiled-match( Q:to[END], Q:to[END] ), 'star';
				grammar Lexer;
				plain : ~[c]* ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ c ]>*
					}
				}
				END

				ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
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

			ok compiled-match( Q:to[END], Q:to[END] ), 'question';
			grammar Lexer;
			plain : [c]? ;
			END
			grammar Lexer {
				rule plain {
					||	<[ c ]>?
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'star';
			grammar Lexer;
			plain : [c]* ;
			END
			grammar Lexer {
				rule plain {
					||	<[ c ]>*
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
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
				ok compiled-match( Q:to[END], Q:to[END] ), 'question';
				grammar Lexer;
				plain : ~[c]?? ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ c ]>??
					}
				}
				END

				ok compiled-match( Q:to[END], Q:to[END] ), 'star';
				grammar Lexer;
				plain : ~[c]*? ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ c ]>*?
					}
				}
				END

				ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
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

			ok compiled-match( Q:to[END], Q:to[END] ), 'question';
			grammar Lexer;
			plain : [c]?? ;
			END
			grammar Lexer {
				rule plain {
					||	<[ c ]>??
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'star';
			grammar Lexer;
			plain : [c]*? ;
			END
			grammar Lexer {
				rule plain {
					||	<[ c ]>*?
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
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

		done-testing;
	};

	subtest 'multiple-character set', {
		ok compiled-match( Q:to[END], Q:to[END] ), 'normal';
		grammar Lexer;
		plain : [abc] ;
		END
		grammar Lexer {
			rule plain {
				||	<[ a b c ]>
			}
		}
		END

		subtest 'modifiers', {
			ok compiled-match( Q:to[END], Q:to[END] ), 'negated';
			grammar Lexer;
			plain : ~[abc] ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ a b c ]>
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'question';
			grammar Lexer;
			plain : [abc]? ;
			END
			grammar Lexer {
				rule plain {
					||	<[ a b c ]>?
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'star';
			grammar Lexer;
			plain : [abc]* ;
			END
			grammar Lexer {
				rule plain {
					||	<[ a b c ]>*
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
			grammar Lexer;
			plain : [abc]+ ;
			END
			grammar Lexer {
				rule plain {
					||	<[ a b c ]>+
				}
			}
			END

			done-testing;
		};

		done-testing;
	};

	subtest 'ranged character set', {
		ok compiled-match( Q:to[END], Q:to[END] ), 'normal';
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
#`(
			ok compiled-match( Q:to[END], Q:to[END] ), 'negated';
			grammar Lexer;
			plain : ~[a-c] ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ a .. c ]>
				}
			}
			END
)

			subtest 'negated modifiers', {
#`(
				ok compiled-match( Q:to[END], Q:to[END] ), 'question';
				grammar Lexer;
				plain : ~[a-c]? ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ a .. c ]>?
					}
				}
				END
)

#`(
				ok compiled-match( Q:to[END], Q:to[END] ), 'star';
				grammar Lexer;
				plain : ~[a-c]* ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ a .. c ]>*
					}
				}
				END
)

#`(
				ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
				grammar Lexer;
				plain : ~[a-c]+ ;
				END
				grammar Lexer {
					rule plain {
						||	<-[ a .. c ]>+
					}
				}
				END
)

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
		ok compiled-match( Q:to[END], Q:to[END] ), 'single character';
		grammar Lexer;
		plain : ~( 'W' ) ;
		END
		grammar Lexer {
			rule plain {
				||	<-[ W ]>
			}
		}
		END

		ok compiled-match( Q:to[END], Q:to[END] ), 'multiple characters';
		grammar Lexer;
		plain : ~( 'W' | 'Y' ) ;
		END
		grammar Lexer {
			rule plain {
				||	<-[ W Y ]>
			}
		}
		END

		ok compiled-match( Q:to[END], Q:to[END] ), 'character set';
		grammar Lexer;
		plain : ~( [ \n\r\t\,] ) ;
		END
		grammar Lexer {
			rule plain {
				||	<-[   \n \r \t \, ]>
			}
		}
		END

		ok compiled-match( Q:to[END], Q:to[END] ), 'multiple characters';
		grammar Lexer;
		plain : ~( 'W' .. 'X' | 'Y' ) ;
		END
		grammar Lexer {
			rule plain {
				||	<-[ W .. X Y ]>
			}
		}
		END

		subtest 'modifiers', {
			ok compiled-match( Q:to[END], Q:to[END] ), 'question';
			grammar Lexer;
			plain : ~( 'W' )? ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ W ]>?
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'star';
			grammar Lexer;
			plain : ~( 'W' )* ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ W ]>*
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
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
			ok compiled-match( Q:to[END], Q:to[END] ), 'question';
			grammar Lexer;
			plain : ~( 'W' )?? ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ W ]>??
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'star';
			grammar Lexer;
			plain : ~( 'W' )*? ;
			END
			grammar Lexer {
				rule plain {
					||	<-[ W ]>*?
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
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
		ok compiled-match( Q:to[END], Q:to[END] ), 'bare';
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

			ok compiled-match( Q:to[END], Q:to[END] ), 'question';
			grammar Lexer;
			plain : .? ;
			END
			grammar Lexer {
				rule plain {
					||	.?
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'star';
			grammar Lexer;
			plain : .* ;
			END
			grammar Lexer {
				rule plain {
					||	.*
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
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

			ok compiled-match( Q:to[END], Q:to[END] ), 'question';
			grammar Lexer;
			plain : .?? ;
			END
			grammar Lexer {
				rule plain {
					||	.??
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'star';
			grammar Lexer;
			plain : .*? ;
			END
			grammar Lexer {
				rule plain {
					||	.*?
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
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
		ok compiled-match( Q:to[END], Q:to[END] ), 'bare';
		grammar Lexer;
		plain : Str ;
		END
		grammar Lexer {
			rule plain {
				||	<Str>
			}
		}
		END

		ok compiled-match( Q:to[END], Q:to[END] ), 'aliased';
		grammar Lexer;
		plain : alias=Str ;
		END
		grammar Lexer {
			rule plain {
				||	<alias=Str>
			}
		}
		END

		ok compiled-match( Q:to[END], Q:to[END] ), 'special EOF nontermnal';
		grammar Lexer;
		plain : EOF ;
		END
		grammar Lexer {
			rule plain {
				||	$
			}
		}
		END

		subtest 'modifiers', {
			ok compiled-match( Q:to[END], Q:to[END] ), 'negation';
			grammar Lexer;
			plain : ~Str* ;
			END
			grammar Lexer {
				rule plain {
					||	<!Str>*
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'question';
			grammar Lexer;
			plain : Str? ;
			END
			grammar Lexer {
				rule plain {
					||	<Str>?
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'star';
			grammar Lexer;
			plain : Str* ;
			END
			grammar Lexer {
				rule plain {
					||	<Str>*
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
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

			ok compiled-match( Q:to[END], Q:to[END] ), 'question';
			grammar Lexer;
			plain : Str?? ;
			END
			grammar Lexer {
				rule plain {
					||	<Str>??
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'star';
			grammar Lexer;
			plain : Str*? ;
			END
			grammar Lexer {
				rule plain {
					||	<Str>*?
				}
			}
			END

			ok compiled-match( Q:to[END], Q:to[END] ), 'plus';
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

done-testing;

# vim: ft=perl6
