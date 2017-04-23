use v6;
use ANTLR4::Actions::Perl6;
use Test;

plan 2;

my $p = ANTLR4::Actions::Perl6.new;
my $parsed;

subtest {
	$parsed = $p.parse( q{grammar Minimal;} );

	is $parsed.perl6, Q:to{END}, Q{minimal grammar};
grammar Minimal {
}
END

	$parsed = $p.parse( q{lexer grammar Minimal;} );

	is $parsed.perl6, Q:to{END}, Q{lexer type};
grammar Minimal { #={ "type" : "lexer" }
}
END

	$parsed = $p.parse( q{grammar Minimal; options {a=2;}} );

	is $parsed.perl6, Q:to{END}, Q{option};
grammar Minimal { #={ "option" : { "a" : "2" } }
}
END

	$parsed = $p.parse( q{grammar Minimal; import Foo;} );

	is $parsed.perl6, Q:to{END}, Q{import};
grammar Minimal { #={ "import" : { "Foo" : null } }
}
END

	$parsed = $p.parse( q{grammar Minimal; tokens { INDENT, DEDENT }} );

	is $parsed.perl6, Q:to{END}, Q{token};
grammar Minimal {
	token DEDENT { 'dedent' }
	token INDENT { 'indent' }
}
END

	$parsed = $p.parse( q{grammar Minimal; @members { int i = 0; }} );

	is $parsed.perl6, Q:to{END}, Q{action};
grammar Minimal { #={ "action" : { "name" : "@members", "content" : "{ int i = 0; }" } }
}
END

	done-testing;

}, 'Grammar and its top-level options';

subtest {
	$parsed = $p.parse( q{grammar Minimal; fragment number : ;} );

	is $parsed.perl6, Q:to{END}, Q{type};
grammar Minimal {
	rule number { #={ "type" : "fragment" }
	}
}
END

	$parsed = $p.parse( q{grammar Minimal; number throws XFoo : ;} );

	is $parsed.perl6, Q:to{END}, Q{throw};
grammar Minimal {
	rule number { #={ "throw" : { "XFoo" : null } }
	}
}
END

	$parsed = $p.parse( q{grammar Minimal; number returns [int amount] : ;} );

	is $parsed.perl6, Q:to{END}, Q{return};
grammar Minimal {
	rule number { #={ "return" : "[int amount]" }
	}
}
END

	$parsed = $p.parse( q{grammar Minimal; number[String name, int total] : ;} );

	is $parsed.perl6, Q:to{END}, Q{action};
grammar Minimal {
	rule number { #={ "action" : "[String name, int total]" }
	}
}
END

	$parsed = $p.parse( q{grammar Minimal; number locals[int n = 0] : ;} );

	is $parsed.perl6, Q:to{END}, Q{local};
grammar Minimal {
	rule number { #={ "local" : "[int n = 0]" }
	}
}
END

	$parsed = $p.parse( q{grammar Minimal; number options{I=1;} : ;} );

	is $parsed.perl6, Q:to{END}, Q{option};
grammar Minimal {
	rule number { #={ "option" : { "I" : "1" } }
	}
}
END

	$parsed = $p.parse( q{grammar Minimal; number : ; catch[int amount] {amount++} } );

	is $parsed.perl6, Q:to{END}, Q{catch};
grammar Minimal {
	rule number { #={ "catch" : [ { "argument" : "[int amount]" }, { "action" : "{amount++}" } ] }
	}
}
END

	$parsed = $p.parse( q{grammar Minimal; number : ; finally {amount=1} } );

	is $parsed.perl6, Q:to{END}, Q{catch};
grammar Minimal {
	rule number { #={ "finally" : "{amount=1}" }
	}
}
END

	done-testing;
}, 'Options surrounding single empty rule (legal in ANTLR)';

# vim: ft=perl6
