use v6;
use ANTLR4::Grammar;
use Test;

plan 33;

sub compile( $name ) {
	return ANTLR4::Grammar.file-to-string( 'corpus/' ~ $name );
}

eval-lives-ok compile( 'Abnf.g4'                ), 'Abnf.g4';
eval-lives-ok compile( 'ANTLRv4Lexer.g4'        ), 'ANTLRv4Lexer.g4';
eval-lives-ok compile( 'ANTLRv4Parser.g4'       ), 'ANTLRv4Parser.g4';
eval-lives-ok compile( 'asm6502.g4'             ), 'asm6502.g4';
#eval-lives-ok compile( 'ATL.g4'                 ), 'ATL.g4'; # Impedance mismatch
eval-lives-ok compile( 'bnf.g4'                 ), 'bnf.g4';
eval-lives-ok compile( 'C.g4'                   ), 'C.g4';
#eval-lives-ok compile( 'Clojure.g4'             ), 'Clojure.g4'; # Impedance mismatch
eval-lives-ok compile( 'creole.g4'              ), 'creole.g4';
eval-lives-ok compile( 'CSharp4.g4'             ), 'CSharp4.g4';
#eval-lives-ok compile( 'CSharp4Lexer.g4'        ), 'CSharp4Lexer.g4'; # Impedance mismatch
#eval-lives-ok compile( 'CSharp4PreProcessor.g4' ), 'CSharp4PreProcessor.g4'; # Impedance mismatch
eval-lives-ok compile( 'CSV.g4'                 ), 'CSV.g4';
#eval-lives-ok compile( 'DOT.g4'                 ), 'DOT.g4'; # Impedance mismatch
#eval-lives-ok compile( 'ECMAScript.g4'          ), 'ECMAScript.g4'; # Impedance mismatch
#eval-lives-ok compile( 'Erlang.g4'              ), 'Erlang.g4'; # Impedance mismatch
eval-lives-ok compile( 'fasta.g4'               ), 'fasta.g4';
eval-lives-ok compile( 'gff3.g4'                ), 'gff3.g4';
eval-lives-ok compile( 'HTMLLexer.g4'           ), 'HTMLLexer.g4';
eval-lives-ok compile( 'HTMLParser.g4'          ), 'HTMLParser.g4';
#eval-lives-ok compile( 'ICalendar.g4'           ), 'ICalendar.g4'; # Impedance mismatch
eval-lives-ok compile( 'IDL.g4'                 ), 'IDL.g4';
#eval-lives-ok compile( 'IRI.g4'                 ), 'IRI.g4'; # Impedance mismatch
#eval-lives-ok compile( 'Java8.g4'               ), 'Java8.g4'; # Impedance mismatch
#eval-lives-ok compile( 'Java.g4'                ), 'Java.g4'; # Impedance mismatch
eval-lives-ok compile( 'JSON.g4'                ), 'JSON.g4';
eval-lives-ok compile( 'jvmBasic.g4'            ), 'jvmBasic.g4';
eval-lives-ok compile( 'LessLexer.g4'           ), 'LessLexer.g4';
eval-lives-ok compile( 'LessParser.g4'          ), 'LessParser.g4';
#eval-lives-ok compile( 'logo.g4'                ), 'logo.g4'; # Impedance mismatch?
#eval-lives-ok compile( 'Lua.g4'                 ), 'Lua.g4'; # Impedance mismatch
eval-lives-ok compile( 'MySQLBase.g4'           ), 'MySQLBase.g4';
eval-lives-ok compile( 'MySQL.g4'               ), 'MySQL.g4';
#eval-lives-ok compile( 'ObjC.g4'                ), 'ObjC.g4'; # Impedance mismatch
#eval-lives-ok compile( 'PCRE.g4'                ), 'PCRE.g4'; # Impedance mismatch
eval-lives-ok compile( 'PGN.g4'                 ), 'PGN.g4';
#eval-lives-ok compile( 'Python3.g4'             ), 'Python3.g4'; # Impedance mismatch
eval-lives-ok compile( 'redcode.g4'             ), 'redcode.g4';
eval-lives-ok compile( 'RFilter.g4'             ), 'RFilter.g4';
#eval-lives-ok compile( 'R.g4'                   ), 'R.g4'; # Impedance mismatch
eval-lives-ok compile( 'scala.g4'               ), 'scala.g4';
eval-lives-ok compile( 'ScssLexer.g4'           ), 'ScssLexer.g4';
eval-lives-ok compile( 'ScssParser.g4'          ), 'ScssParser.g4';
eval-lives-ok compile( 'Smalltalk.g4'           ), 'Smalltalk.g4';
#eval-lives-ok compile( 'SQLite.g4'              ), 'SQLite.g4';
#eval-lives-ok compile( 'Swift.g4'               ), 'Swift.g4'; # Impedance mismatch
eval-lives-ok compile( 'tnsnames.g4'            ), 'tnsnames.g4';
eval-lives-ok compile( 'tnt.g4'                 ), 'tnt.g4';
#eval-lives-ok compile( 'TURTLE.g4'              ), 'TURTLE.g4'; # Impednce mismatch
#eval-lives-ok compile( 'UCBLogo.g4'             ), 'UCBLogo.g4'; # Impedance mismatch
eval-lives-ok compile( 'Verilog2001.g4'         ), 'Verilog2001.g4';
eval-lives-ok compile( 'vhdl.g4'                ), 'vhdl.g4';
##eval-lives-ok compile( /VisualBasic6.g4'        ), 'VisualBasic6.g4';
#skip 'Need to fix UTF-8 issue', 1;
#eval-lives-ok compile( 'WebIDL.g4'              ), 'WebIDL.g4'; # Impedance mismatch
eval-lives-ok compile( 'XMLLexer.g4'            ), 'XMLLexer.g4';
eval-lives-ok compile( 'XMLParser.g4'           ), 'XMLParser.g4';

# vim: ft=perl6
