use v6;
use ANTLR4::Grammar;
use Test;

plan 1;

is ANTLR4::Grammar.to-string( Q:to[END] ), Q:to[END], 'alternating action';
grammar Lexer;
plain : 'X' {doStuff();} ;
END
grammar Lexer {
	token plain {
		||	'X'
			#|{doStuff();}
	}
}
END

done-testing;

# vim: ft=perl6
