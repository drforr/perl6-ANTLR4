use v6;
use ANTLR4::Grammar;
use Test;

plan 4;

sub compile( $orig ) {
	return ANTLR4::Grammar.to-string( $orig )
}

# It's most important to test things that can easily translate into Perl 6.
#
# Parametrize types, return types, options, and exceptions won't make sense
# until the C/Java types get translated to Perl 6.

is compile( Q:to[END] ), Q:to[END], 'empty grammar';
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
	is compile( Q:to[END] ), Q:to[END], 'empty rule';
	grammar Empty;
	empty : ;
	END
	grammar Empty {
		token empty {
		}
	}
	END

	is compile( Q:to[END] ), Q:to[END], 'multiple empty rules';
	grammar Empty;
	empty : ;
	emptier : ;
	END
	grammar Empty {
		token empty {
		}
		token emptier {
		}
	}
	END

	is compile( Q:to[END] ), Q:to[END], 'empty fragment';
	grammar Empty;
	fragment empty : ;
	END
	grammar Empty {
		token empty {
		}
	}
	END

	is compile( Q:to[END] ), Q:to[END], 'multiple empty fragments';
	grammar Empty;
	fragment empty : ;
	fragment emptier : ;
	END
	grammar Empty {
		token empty {
		}
		token emptier {
		}
	}
	END

	done-testing;
};

# Tokens in ANTLR can't get complex, they're simple strings.
#
subtest 'token', {
	is compile( Q:to[END] ), Q:to[END], 'single token';
	grammar Empty;
	tokens { INDENT }
	END
	grammar Empty {
		token INDENT {
			||	'indent'
		}
	}
	END

	is compile( Q:to[END] ), Q:to[END], 'multiple tokens';
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
		is compile( Q:to[END] ), Q:to[END], 'bare';
		grammar Lexer;
		plain : 'terminal' ;
		END
		grammar Lexer {
			token plain {
				||	'terminal'
			}
		}
		END

		is compile( Q:to[END] ), Q:to[END], 'multiple terms, letters only';
		grammar Lexer;
		plain : 'terminal' 'station' ;
		END
		grammar Lexer {
			token plain {
				||	'terminal'
					'station'
			}
		}
		END

		is compile( Q:to[END] ), Q:to[END], 'quoted terminal';
		grammar Lexer;
		sign : '-' ;
		END
		grammar Lexer {
			token sign {
				||	'-'
			}
		}
		END

		is compile( Q:to[END] ), Q:to[END], 'escaped terminal';
		grammar Lexer;
		sign : '\t' ;
		END
		grammar Lexer {
			token sign {
				||	'\t'
			}
		}
		END

		is compile( Q:to[END] ), Q:to[END], 'Unicode terminal';
		grammar Lexer;
		sign : 'Hello\u236a' ;
		END
		grammar Lexer {
			token sign {
				||	'Hello\x[236a]'
			}
		}
		END

		# Even though ~'t' is valid, 't' in this context isn't a
		# terminal but a (degenerate) character set, I think.
		#
		subtest 'modifiers', {
			is compile( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : 'terminal'? ;
			END
			grammar Lexer {
				token plain {
					||	'terminal'?
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : 'terminal'* ;
			END
			grammar Lexer {
				token plain {
					||	'terminal'*
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : 'terminal'+ ;
			END
			grammar Lexer {
				token plain {
					||	'terminal'+
				}
			}
			END

			done-testing;
		};

		subtest 'greedy modifiers', {
			is compile( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : 'terminal'?? ;
			END
			grammar Lexer {
				token plain {
					||	'terminal'??
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : 'terminal'*? ;
			END
			grammar Lexer {
				token plain {
					||	'terminal'*?
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : 'terminal'+? ;
			END
			grammar Lexer {
				token plain {
					||	'terminal'+?
				}
			}
			END

			done-testing;
		};

		done-testing;
	};

	subtest 'negated terminal (character)', {
		is compile( Q:to[END] ), Q:to[END], 'negated alternate form';
		grammar Lexer;
		plain : ~'c' ;
		END
		grammar Lexer {
			token plain {
				||	<-[ c ]>
			}
		}
		END

		subtest 'modifiers', {
			is compile( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : ~'c'? ;
			END
			grammar Lexer {
				token plain {
					||	<-[ c ]>?
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : ~'c'* ;
			END
			grammar Lexer {
				token plain {
					||	<-[ c ]>*
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : ~'c'+ ;
			END
			grammar Lexer {
				token plain {
					||	<-[ c ]>+
				}
			}
			END
		};

		subtest 'greedy modifiers', {
			is compile( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : ~'c'?? ;
			END
			grammar Lexer {
				token plain {
					||	<-[ c ]>??
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : ~'c'*? ;
			END
			grammar Lexer {
				token plain {
					||	<-[ c ]>*?
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : ~'c'+? ;
			END
			grammar Lexer {
				token plain {
					||	<-[ c ]>+?
				}
			}
			END

			done-testing;
		};

		done-testing;
	};

	subtest 'dotted character range', {
		is compile( Q:to[END] ), Q:to[END], 'letters';
		grammar Lexer;
		plain : 'a'..'z' ;
		END
		grammar Lexer {
			token plain {
				||	<[ a .. z ]>
			}
		}
		END

		is compile( Q:to[END] ), Q:to[END], 'letter..non-letter';
		grammar Lexer;
		plain : 'a'..']' ;
		END
		grammar Lexer {
			token plain {
				||	<[ a .. \] ]>
			}
		}
		END

		is compile( Q:to[END] ), Q:to[END], 'Unicode escape';
		grammar Lexer;
		plain : '\u0300'..'\u036F' ;
		END
		grammar Lexer {
			token plain {
				||	<[ \x[0300] .. \x[036F] ]>
			}
		}
		END

		subtest 'modifiers', {
			is compile( Q:to[END] ), Q:to[END], 'negation';
			grammar Lexer;
			plain : ~'a'..'z' ;
			END
			grammar Lexer {
				token plain {
					||	<-[ a .. z ]>
				}
			}
			END

			subtest 'negated modifiers', {
				is compile( Q:to[END] ), Q:to[END], 'question';
				grammar Lexer;
				plain : ~'a'..'z'? ;
				END
				grammar Lexer {
					token plain {
						||	<-[ a .. z ]>?
					}
				}
				END

				is compile( Q:to[END] ), Q:to[END], 'star';
				grammar Lexer;
				plain : ~'a'..'z'* ;
				END
				grammar Lexer {
					token plain {
						||	<-[ a .. z ]>*
					}
				}
				END

				is compile( Q:to[END] ), Q:to[END], 'plus';
				grammar Lexer;
				plain : ~'a'..'z'+ ;
				END
				grammar Lexer {
					token plain {
						||	<-[ a .. z ]>+
					}
				}
				END

				done-testing;
			};

			is compile( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : 'a'..'z'? ;
			END
			grammar Lexer {
				token plain {
					||	<[ a .. z ]>?
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : 'a'..'z'* ;
			END
			grammar Lexer {
				token plain {
					||	<[ a .. z ]>*
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : 'a'..'z'+ ;
			END
			grammar Lexer {
				token plain {
					||	<[ a .. z ]>+
				}
			}
			END

			done-testing;
		};

		subtest 'greedy modifiers', {
			subtest 'negated modifiers', {
				is compile( Q:to[END] ), Q:to[END], 'question';
				grammar Lexer;
				plain : ~'a'..'z'?? ;
				END
				grammar Lexer {
					token plain {
						||	<-[ a .. z ]>??
					}
				}
				END

				is compile( Q:to[END] ), Q:to[END], 'star';
				grammar Lexer;
				plain : ~'a'..'z'*? ;
				END
				grammar Lexer {
					token plain {
						||	<-[ a .. z ]>*?
					}
				}
				END

				is compile( Q:to[END] ), Q:to[END], 'plus';
				grammar Lexer;
				plain : ~'a'..'z'+? ;
				END
				grammar Lexer {
					token plain {
						||	<-[ a .. z ]>+?
					}
				}
				END

				done-testing;
			};

			is compile( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : 'a'..'z'?? ;
			END
			grammar Lexer {
				token plain {
					||	<[ a .. z ]>??
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : 'a'..'z'*? ;
			END
			grammar Lexer {
				token plain {
					||	<[ a .. z ]>*?
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : 'a'..'z'+? ;
			END
			grammar Lexer {
				token plain {
					||	<[ a .. z ]>+?
				}
			}
			END

			done-testing;
		};

		done-testing;
	};

	subtest 'bracketed character set', {
		is compile( Q:to[END] ), Q:to[END], 'single character';
		grammar Lexer;
		plain : [c] ;
		END
		grammar Lexer {
			token plain {
				||	<[ c ]>
			}
		}
		END

		is compile( Q:to[END] ), Q:to[END], 'Unicode character';
		grammar Lexer;
		plain : [\u000C] ;
		END
		grammar Lexer {
			token plain {
				||	<[ \x[000C] ]>
			}
		}
		END

		is compile( Q:to[END] ), Q:to[END], 'close-bracket';
		grammar Lexer;
		plain : [\]] ;
		END
		grammar Lexer {
			token plain {
				||	<[ \] ]>
			}
		}
		END

		subtest 'modifiers', {
			is compile( Q:to[END] ), Q:to[END], 'negated';
			grammar Lexer;
			plain : ~[c] ;
			END
			grammar Lexer {
				token plain {
					||	<-[ c ]>
				}
			}
			END

			subtest 'negated modifiers', {
				is compile( Q:to[END] ), Q:to[END], 'question';
				grammar Lexer;
				plain : ~[c]? ;
				END
				grammar Lexer {
					token plain {
						||	<-[ c ]>?
					}
				}
				END

				is compile( Q:to[END] ), Q:to[END], 'star';
				grammar Lexer;
				plain : ~[c]* ;
				END
				grammar Lexer {
					token plain {
						||	<-[ c ]>*
					}
				}
				END

				is compile( Q:to[END] ), Q:to[END], 'plus';
				grammar Lexer;
				plain : ~[c]+ ;
				END
				grammar Lexer {
					token plain {
						||	<-[ c ]>+
					}
				}
				END

				done-testing;
			};

			is compile( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : [c]? ;
			END
			grammar Lexer {
				token plain {
					||	<[ c ]>?
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : [c]* ;
			END
			grammar Lexer {
				token plain {
					||	<[ c ]>*
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : [c]+ ;
			END
			grammar Lexer {
				token plain {
					||	<[ c ]>+
				}
			}
			END

			done-testing;
		};

		subtest 'greedy modifiers', {
			subtest 'negated modifiers', {
				is compile( Q:to[END] ), Q:to[END], 'question';
				grammar Lexer;
				plain : ~[c]?? ;
				END
				grammar Lexer {
					token plain {
						||	<-[ c ]>??
					}
				}
				END

				is compile( Q:to[END] ), Q:to[END], 'star';
				grammar Lexer;
				plain : ~[c]*? ;
				END
				grammar Lexer {
					token plain {
						||	<-[ c ]>*?
					}
				}
				END

				is compile( Q:to[END] ), Q:to[END], 'plus';
				grammar Lexer;
				plain : ~[c]+? ;
				END
				grammar Lexer {
					token plain {
						||	<-[ c ]>+?
					}
				}
				END

				done-testing;
			};

			is compile( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : [c]?? ;
			END
			grammar Lexer {
				token plain {
					||	<[ c ]>??
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : [c]*? ;
			END
			grammar Lexer {
				token plain {
					||	<[ c ]>*?
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : [c]+? ;
			END
			grammar Lexer {
				token plain {
					||	<[ c ]>+?
				}
			}
			END

			done-testing;
		};

		done-testing;
	};

	subtest 'multiple-character set', {
		is compile( Q:to[END] ), Q:to[END], 'normal';
		grammar Lexer;
		plain : [abc] ;
		END
		grammar Lexer {
			token plain {
				||	<[ a b c ]>
			}
		}
		END

		subtest 'modifiers', {
			is compile( Q:to[END] ), Q:to[END], 'negated';
			grammar Lexer;
			plain : ~[abc] ;
			END
			grammar Lexer {
				token plain {
					||	<-[ a b c ]>
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : [abc]? ;
			END
			grammar Lexer {
				token plain {
					||	<[ a b c ]>?
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : [abc]* ;
			END
			grammar Lexer {
				token plain {
					||	<[ a b c ]>*
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : [abc]+ ;
			END
			grammar Lexer {
				token plain {
					||	<[ a b c ]>+
				}
			}
			END

			done-testing;
		};

		done-testing;
	};

	subtest 'ranged character set', {
		is compile( Q:to[END] ), Q:to[END], 'normal';
		grammar Lexer;
		plain : [a-c] ;
		END
		grammar Lexer {
			token plain {
				||	<[ a .. c ]>
			}
		}
		END

		is compile( Q:to[END] ), Q:to[END], 'normal';
		grammar Lexer;
		plain : [\u000a-\u000c] ;
		END
		grammar Lexer {
			token plain {
				||	<[ \x[000a] .. \x[000c] ]>
			}
		}
		END

		subtest 'modifiers', {
			is compile( Q:to[END] ), Q:to[END], 'negated';
			grammar Lexer;
			plain : ~[a-c] ;
			END
			grammar Lexer {
				token plain {
					||	<-[ a .. c ]>
				}
			}
			END

			subtest 'negated modifiers', {
				is compile( Q:to[END] ), Q:to[END], 'question';
				grammar Lexer;
				plain : ~[a-c]? ;
				END
				grammar Lexer {
					token plain {
						||	<-[ a .. c ]>?
					}
				}
				END

				is compile( Q:to[END] ), Q:to[END], 'star';
				grammar Lexer;
				plain : ~[a-c]* ;
				END
				grammar Lexer {
					token plain {
						||	<-[ a .. c ]>*
					}
				}
				END

				is compile( Q:to[END] ), Q:to[END], 'plus';
				grammar Lexer;
				plain : ~[a-c]+ ;
				END
				grammar Lexer {
					token plain {
						||	<-[ a .. c ]>+
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
		is compile( Q:to[END] ), Q:to[END], 'single character';
		grammar Lexer;
		plain : ~( 'W' ) ;
		END
		grammar Lexer {
			token plain {
				||	<-[ W ]>
			}
		}
		END

		is compile( Q:to[END] ), Q:to[END], 'multiple characters';
		grammar Lexer;
		plain : ~( 'W' | 'Y' ) ;
		END
		grammar Lexer {
			token plain {
				||	<-[ W Y ]>
			}
		}
		END

		is compile( Q:to[END] ), Q:to[END], 'character set';
		grammar Lexer;
		plain : ~( [ \n\r\t\,] ) ;
		END
		grammar Lexer {
			token plain {
				||	<-[   \n \r \t \, ]>
			}
		}
		END

		is compile( Q:to[END] ), Q:to[END], 'multiple characters';
		grammar Lexer;
		plain : ~( 'W' .. 'X' | 'Y' ) ;
		END
		grammar Lexer {
			token plain {
				||	<-[ W .. X Y ]>
			}
		}
		END

		subtest 'modifiers', {
			is compile( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : ~( 'W' )? ;
			END
			grammar Lexer {
				token plain {
					||	<-[ W ]>?
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : ~( 'W' )* ;
			END
			grammar Lexer {
				token plain {
					||	<-[ W ]>*
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : ~( 'W' )+ ;
			END
			grammar Lexer {
				token plain {
					||	<-[ W ]>+
				}
			}
			END

			done-testing;
		};

		subtest 'greedy modifiers', {
			is compile( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : ~( 'W' )?? ;
			END
			grammar Lexer {
				token plain {
					||	<-[ W ]>??
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : ~( 'W' )*? ;
			END
			grammar Lexer {
				token plain {
					||	<-[ W ]>*?
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : ~( 'W' )+? ;
			END
			grammar Lexer {
				token plain {
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
		is compile( Q:to[END] ), Q:to[END], 'bare';
		grammar Lexer;
		plain : . ;
		END
		grammar Lexer {
			token plain {
				||	.
			}
		}
		END

		subtest 'modifiers', {
			# Negated wildcard is illegal.
			# Good thing , no idea what it would mean.

			is compile( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : .? ;
			END
			grammar Lexer {
				token plain {
					||	.?
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : .* ;
			END
			grammar Lexer {
				token plain {
					||	.*
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : .+ ;
			END
			grammar Lexer {
				token plain {
					||	.+
				}
			}
			END

			done-testing;
		};

		subtest 'greedy modifiers', {
			# Negated wildcard is illegal.
			# Good thing , no idea what it would mean.

			is compile( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : .?? ;
			END
			grammar Lexer {
				token plain {
					||	.??
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : .*? ;
			END
			grammar Lexer {
				token plain {
					||	.*?
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : .+? ;
			END
			grammar Lexer {
				token plain {
					||	.+?
				}
			}
			END

			done-testing;
		};

		done-testing;
	};

	subtest 'token with nonterminal', {
		is compile( Q:to[END] ), Q:to[END], 'bare';
		grammar Lexer;
		plain : Str ;
		END
		grammar Lexer {
			token plain {
				||	<Str>
			}
		}
		END

		is compile( Q:to[END] ), Q:to[END], 'aliased';
		grammar Lexer;
		plain : alias=Str ;
		END
		grammar Lexer {
			token plain {
				||	<alias=Str>
			}
		}
		END

		is compile( Q:to[END] ), Q:to[END], 'negated';
		grammar Lexer;
		plain : ~Str ;
		END
		grammar Lexer {
			token plain {
				||	<!Str>
			}
		}
		END

		is compile( Q:to[END] ), Q:to[END], 'special EOF nontermnal';
		grammar Lexer;
		plain : EOF ;
		END
		grammar Lexer {
			token plain {
				||	$
			}
		}
		END

		subtest 'modifiers', {
			is compile( Q:to[END] ), Q:to[END], 'negation';
			grammar Lexer;
			plain : ~Str* ;
			END
			grammar Lexer {
				token plain {
					||	<!Str>*
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : Str? ;
			END
			grammar Lexer {
				token plain {
					||	<Str>?
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : Str* ;
			END
			grammar Lexer {
				token plain {
					||	<Str>*
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : Str+ ;
			END
			grammar Lexer {
				token plain {
					||	<Str>+
				}
			}
			END

			done-testing;
		};

		subtest 'greedy modifiers', {

			# Negation is allowed in the grammar but is illegal
			# in the actual language, apparently.

			is compile( Q:to[END] ), Q:to[END], 'question';
			grammar Lexer;
			plain : Str?? ;
			END
			grammar Lexer {
				token plain {
					||	<Str>??
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'star';
			grammar Lexer;
			plain : Str*? ;
			END
			grammar Lexer {
				token plain {
					||	<Str>*?
				}
			}
			END

			is compile( Q:to[END] ), Q:to[END], 'plus';
			grammar Lexer;
			plain : Str+? ;
			END
			grammar Lexer {
				token plain {
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
