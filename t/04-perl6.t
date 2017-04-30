use v6;
use ANTLR4::Actions::Perl6;
use Test;

plan 5;

my $p = ANTLR4::Actions::Perl6.new;
my $parsed;

subtest {
	$parsed = $p.parse( q{grammar Minimal;} );

	is $parsed.perl6, Q:to{END}.chomp, Q{minimal grammar};
	grammar Minimal {
	}
	END

	$parsed = $p.parse( q{lexer grammar Minimal;} );

	is $parsed.perl6, Q:to{END}.chomp, Q{lexer type};
	#|{ "type" : "lexer" }
	grammar Minimal {
	}
	END

	$parsed = $p.parse( q{grammar Minimal; options {a=2;}} );

	is $parsed.perl6, Q:to{END}.chomp, Q{option};
	#|{ "option" : { "a" : "2" } }
	grammar Minimal {
	}
	END

	$parsed = $p.parse( q{grammar Minimal; import Foo;} );

	is $parsed.perl6, Q:to{END}.chomp, Q{import};
	#|{ "import" : { "Foo" : null } }
	grammar Minimal {
	}
	END

	$parsed = $p.parse( q{grammar Minimal; tokens { INDENT, DEDENT }} );

	is $parsed.perl6, Q:to{END}.chomp, Q{token};
	grammar Minimal {
		token DEDENT {
			'dedent'
		}
		token INDENT {
			'indent'
		}
	}
	END

	$parsed = $p.parse( q{grammar Minimal; @members { int i = 0; }} );

	is $parsed.perl6, Q:to{END}.chomp, Q{action};
	#|{ "action" : { "name" : "@members", "body" : "{ int i = 0; }" } }
	grammar Minimal {
	}
	END

	done-testing;
}, 'Grammar and its top-level options';

subtest {
	$parsed = $p.parse( q{grammar Minimal; number : ;} );

	is $parsed.perl6, Q:to{END}.chomp, Q{basic rule};
	grammar Minimal {
		rule number {
		}
	}
	END

	$parsed = $p.parse( q{grammar Minimal; fragment number : ;} );

	is $parsed.perl6, Q:to{END}.chomp, Q{rule fragment};
	grammar Minimal {
		#|{ "type" : "fragment" }
		rule number {
		}
	}
	END

	$parsed = $p.parse( q{grammar Minimal; number throws XFoo : ;} );

	is $parsed.perl6, Q:to{END}.chomp, Q{throw};
	grammar Minimal {
		#|{ "throw" : { "XFoo" : null } }
		rule number {
		}
	}
	END

	$parsed = $p.parse(
		q{grammar Minimal; number returns [int amount] : ;}
	);

	is $parsed.perl6, Q:to{END}.chomp, Q{return};
	grammar Minimal {
		#|{ "return" : "[int amount]" }
		rule number {
		}
	}
	END

	$parsed = $p.parse(
		q{grammar Minimal; number[String name, int total] : ;}
	);

	is $parsed.perl6, Q:to{END}.chomp, Q{action};
	grammar Minimal {
		#|{ "action" : "[String name, int total]" }
		rule number {
		}
	}
	END

	$parsed = $p.parse( q{grammar Minimal; number locals[int n = 0] : ;} );

	is $parsed.perl6, Q:to{END}.chomp, Q{local};
	grammar Minimal {
		#|{ "local" : "[int n = 0]" }
		rule number {
		}
	}
	END

	$parsed = $p.parse( q{grammar Minimal; number options{I=1;} : ;} );

	is $parsed.perl6, Q:to{END}.chomp, Q{option};
	grammar Minimal {
		#|{ "option" : { "I" : "1" } }
		rule number {
		}
	}
	END

	$parsed = $p.parse(
		q{grammar Minimal; number : ; catch[int amount] {amount++} }
	);

	is $parsed.perl6, Q:to{END}.chomp, Q{catch};
	grammar Minimal {
		#|{ "catch" : [ { "argument" : "[int amount]" }, { "action" : "{amount++}" } ] }
		rule number {
		}
	}
	END

	$parsed = $p.parse(
		q{grammar Minimal; number : ; finally {amount=1} }
	);

	is $parsed.perl6, Q:to{END}.chomp, Q{finally};
	grammar Minimal {
		#|{ "finally" : "{amount=1}" }
		rule number {
		}
	}
	END

	done-testing;
}, 'Options surrounding single empty rule (legal in ANTLR)';

$parsed = $p.parse(
	q{grammar Minimal; statement : 'SELECT' ;}
);

is $parsed.perl6, Q:to{END}.chomp, Q{single statement};
grammar Minimal {
	rule statement {
		'SELECT'
	}
}
END

$parsed = $p.parse(
	q{grammar Minimal; statement : 'SELECT' '*' ;}
);

is $parsed.perl6, Q:to{END}.chomp, Q{compound statement};
grammar Minimal {
	rule statement {
		'SELECT'
		'*'
	}
}
END

$parsed = $p.parse(
	q{grammar Minimal; statement : 'SELECT' | 'UPDATE' ;}
);

is $parsed.perl6, Q:to{END}.chomp, Q{compound statement};
grammar Minimal {
	rule statement {
		| 'SELECT'
		| 'UPDATE'
	}
}
END

# vim: ft=perl6
