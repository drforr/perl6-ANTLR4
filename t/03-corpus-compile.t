use v6;
use ANTLR4::Grammar;
use Test;

plan 56;

my $p = ANTLR4::Grammar.new;

eval-lives-ok $p.file-to-string( 'corpus/Abnf.g4' ), 'Abnf.g4';
#`(eval-lives-ok $p.file-to-string( 'corpus/ANTLRv4Lexer.g4' ), 'ANTLRv4Lexer.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/ANTLRv4Parser.g4' ),
	'ANTLRv4Parser.g4';)
eval-lives-ok $p.file-to-string( 'corpus/asm6502.g4' ), 'asm6502.g4';
#`(eval-lives-ok $p.file-to-string( 'corpus/ATL.g4' ), 'ATL.g4';)
eval-lives-ok $p.file-to-string( 'corpus/bnf.g4' ), 'bnf.g4';
#`(eval-lives-ok $p.file-to-string( 'corpus/C.g4' ), 'C.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/Clojure.g4' ), 'Clojure.g4';)
eval-lives-ok $p.file-to-string( 'corpus/creole.g4' ), 'creole.g4';
#`(eval-lives-ok $p.file-to-string( 'corpus/CSharp4.g4' ), 'CSharp4.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/CSharp4Lexer.g4' ), 'CSharp4Lexer.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/CSharp4PreProcessor.g4' ),
	'CSharp4PreProcessor.g4';)
eval-lives-ok $p.file-to-string( 'corpus/CSV.g4' ), 'CSV.g4';
#`(eval-lives-ok $p.file-to-string( 'corpus/DOT.g4' ), 'DOT.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/ECMAScript.g4' ), 'ECMAScript.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/Erlang.g4' ), 'Erlang.g4';)
eval-lives-ok $p.file-to-string( 'corpus/fasta.g4' ), 'fasta.g4';
eval-lives-ok $p.file-to-string( 'corpus/gff3.g4' ), 'gff3.g4';
#`(eval-lives-ok $p.file-to-string( 'corpus/HTMLLexer.g4' ), 'HTMLLexer.g4';)
eval-lives-ok $p.file-to-string( 'corpus/HTMLParser.g4' ), 'HTMLParser.g4';
#`(eval-lives-ok $p.file-to-string( 'corpus/ICalendar.g4' ), 'ICalendar.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/IDL.g4' ), 'IDL.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/IRI.g4' ), 'IRI.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/Java8.g4' ), 'Java8.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/Java.g4' ), 'Java.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/JSON.g4' ), 'JSON.g4';)
eval-lives-ok $p.file-to-string( 'corpus/jvmBasic.g4' ), 'jvmBasic.g4';
#`(eval-lives-ok $p.file-to-string( 'corpus/LessLexer.g4' ), 'LessLexer.g4';)
eval-lives-ok $p.file-to-string( 'corpus/LessParser.g4' ), 'LessParser.g4';
#`(eval-lives-ok $p.file-to-string( 'corpus/logo.g4' ), 'logo.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/Lua.g4' ), 'Lua.g4';)
eval-lives-ok $p.file-to-string( 'corpus/MySQLBase.g4' ), 'MySQLBase.g4';
#`(eval-lives-ok $p.file-to-string( 'corpus/MySQL.g4' ), 'MySQL.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/ObjC.g4' ), 'ObjC.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/PCRE.g4' ), 'PCRE.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/PGN.g4' ), 'PGN.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/Python3.g4' ), 'Python3.g4';)
eval-lives-ok $p.file-to-string( 'corpus/redcode.g4' ), 'redcode.g4';
#`(eval-lives-ok $p.file-to-string( 'corpus/RFilter.g4' ), 'RFilter.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/R.g4' ), 'R.g4';)
eval-lives-ok $p.file-to-string( 'corpus/scala.g4' ), 'scala.g4';
#`(eval-lives-ok $p.file-to-string( 'corpus/ScssLexer.g4' ), 'ScssLexer.g4';)
eval-lives-ok $p.file-to-string( 'corpus/ScssParser.g4' ), 'ScssParser.g4';
eval-lives-ok $p.file-to-string( 'corpus/Smalltalk.g4' ), 'Smalltalk.g4';
#`(eval-lives-ok $p.file-to-string( 'corpus/SQLite.g4' ), 'SQLite.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/Swift.g4' ), 'Swift.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/tnsnames.g4' ), 'tnsnames.g4';)
eval-lives-ok $p.file-to-string( 'corpus/tnt.g4' ), 'tnt.g4';
#`(eval-lives-ok $p.file-to-string( 'corpus/TURTLE.g4' ), 'TURTLE.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/UCBLogo.g4' ), 'UCBLogo.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/Verilog2001.g4' ), 'Verilog2001.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/vhdl.g4' ), 'vhdl.g4';)
#eval-lives-ok $p.file-to-string( 'corpus/VisualBasic6.g4' ), 'VisualBasic6.g4';
#skip 'Need to fix UTF-8 issue', 1;
#`(eval-lives-ok $p.file-to-string( 'corpus/WebIDL.g4' ), 'WebIDL.g4';)
#`(eval-lives-ok $p.file-to-string( 'corpus/XMLLexer.g4' ), 'XMLLexer.g4';)
eval-lives-ok $p.file-to-string( 'corpus/XMLParser.g4' ), 'XMLParser.g4';

# vim: ft=perl6)
