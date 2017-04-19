=begin pod

=head1 ANTLR4::Actions::AST

C<ANTLR4::Actions::AST> encompasses the grammar actions needed to create a
perl6 AST from an ANTLR4 parser specification.

=head1 Synopsis

    use ANTLR4::Actions::AST;
    use ANTLR4::Grammar;
    my $a = ANTLR4::Actions::AST.new;
    my $g = ANTLR4::Grammar.new;

    say $g.parsefile('ECMAScript.g4', :actions($a) ).ast;

=head1 Documentation

The action in this file will return a completely unblessed abstract syntax
tree (AST) of the ANTLR4 grammar perl6 has been asked to parse. Other variants
may return an object or even the nearest perl6 equivalent grammar, but this
just returns a hash reference with nested array references.

If you're unfamiliar with ASTs, please check out the test suites, specifically
L<t/03-actions.t> in order to see what this particular action generates.

Broadly speaking you'll get back a hash reference containing data gleaned from
the ANTLR4 grammar, minus the comments and unimportant syntax. Where order is
important (and generally, even where it isn't) data will be kept in line in
an array reference, and usually these array references will have hash
references inside them.

The top-level keys are listed below, and contain the important stuff that can
be gleaned from a quick perusal of the grammar file. The C<content> key is the
most complex, and is described in detail at the appropriate place.

  =item name

  The name of the grammar, derived from 'grammar ECMAScript;'

  =item type

  The type of the grammar, either 'lexer' or 'parser' as specified in the text,
  or 'DEFAULT' if no type is specified.

  =item options

  An array reference of options specified in the grammar file.  The most common
  option is 'tokenVocab', which would appear as
  C<options => [ tokenVocab => 'ECMAScriptLexer' ]>.

  =item imports

  An array reference of grammar files the current file imports, and their
  optional aliases. This action doesn't load imported files, but feel free
  to do so on your own.

  =item tokens

  An array reference of token names predefined in other grammar files, such as
  the files in the C<imports> key. While tokens may be defined in other files,
  they're beyond the scope of this action.

  =item actions

  An array reference consisting of the actions performed by the top level of the
  grammar. It's just a reference to a single pair, even though the grammar
  doesn't seem to support multiple actions at the top level. Again, an array
  reference just for consistency's sake.

  The action text itself will remain unparsed, mostly because it's a
  monolithic block of Java code. If you're converting a grammar from ANTLR4 to
  Perl6 you'll need to take note of this behavior, but it's currently beyond
  the scope of this action to parse the text here.

  =item contents

  To preserve ordering in case we want to round-trip ANTLR-Perl6-ANTLR, this
  is also an array reference. It's also the most complex of the data
  structures in the module.

  At this juncture you may want to keep L<t/03-actions.t> open in order to
  follow along with the story.

  The C<contents> key is an arrayref of hashrefs. Each of these hashrefs
  contains a full rule, laid out in a more or less conistent fashion. All of
  these hashrefs contain a fixed set of keys, only two of them important to
  Perl6 users in general.

  The C<name> and C<contents> are the most important items, C<name> is the
  rule's name (go figure) and C<contents> being the actual meat of the rule.
  C<attribute>, C<action>, C<return> and C<throws> are useful for the Java
  author to restrict visibiity of the rule, and add additional arguments to the
  Java method that is called by the generated parser.
  
  The real fun begins inside the C<contents> key. Even a simple ANTLR4 rule
  such as C<number : digits ;> will have several layers of what looks like
  redundant nesting. This is mostly for consistency's sake, and might change
  later on, especially for single-term rules where you wouldn't expect the
  complexities of nesting.

  The ANTLR4 grammar assumes that rules always start with a list of
  alternatives, even if there's only one alternative. These alternatives
  can themselves be a list of concatenations, even if there's only one
  term to be "concatenated", thus appearing redundant.

  ANTLR4 has two general kinds of groups - Implicit groups and explicit.
  Implicit groups are those inferred from their surroundings, such as the
  concatenation implicit in C<number : sign? digits ;>. Explicit groups are
  those that override ANTLR4's assumptions, such as C<number : sign? (a b)?>.

  Groups will always be a hashref, with a C<type> and C<contents> key. The type
  is one of C<alternation>, C<concatenation> or C<capturing>. The contents
  will always be an arrayref of either groups or terms.

  Terms are the basics of the grammar, such as C<'foo'>, C<[0-9]+> or
  C<digits>. Each term has a C<type>, C<contents>, C<modifier>, C<greedy> and
  C<complemented> key.

  The C<type> is one of C<terminal>, C<nonterminal> or C<character class>. 
  The contents is the actual text of the term (such as C<foo> if the term is
  C<'foo'>, or the individual "characters" of the character class.

  The C<modifier> is the C<+>, C<*> or C<?> modifier at the end of the term,
  or C<Nil> if no modifier is present. Just like in Perl6, terms can have
  greedy quantifiers, and that's set by the C<greedy> flag. The
  C<complemented> flag acts similarly, since terms can be complemented like
  C<~'foo'> meaning "No 'foo' occurs here".

=end pod

use v6;

class ANTLR4::Actions::AST {
	method ACTION( $/ ) {
		make $/.Str
	}
	method ID( $/ ) {
		make $/.Str
	}
	method optionValue( $/ ) {
		make $/.Str
	}
	method tokenName( $/ ) {
		make $/.Str
	}
	method action_name( $/ ) {
		make $/.Str
	}
	method ruleAttribute( $/ ) {
		make $/.Str
	}
	method FRAGMENT( $/ ) {
		make $/.Str
	}
	method ARG_ACTION( $/ ) {
		make $/.Str
	}
	method grammarType( $/ ) {
		make $/[0] ?? $/[0].Str !! Any
	}
	method ruleReturns( $/ ) {
		make $/<ARG_ACTION>.Str
	}
	method localsSpec( $/ ) {
		make $/<ARG_ACTION>.Str
	}
	method finallyClause( $/ ) {
		make $/<ACTION>.ast;
	}

	# Return just the content, let the upper layer figure out what key
	# to use.
	#
	method delegateGrammar( $/ ) {
		make $/<value>.ast;
	}
	method delegateGrammars( $/ ) {
		my %import;
		for $/<delegateGrammar> {
			%import{$_.<key>.ast} = $_.ast;
		}
		make %import;
	}

	method tokensSpec( $/ ) {
		my %token;
		for $/<token_list_trailing_comma><tokenName> {
			%token{$_.ast} = Any;
		}
		make %token;
	}
	method throwsSpec( $/ ) {
		my %throw;
		for $/<ID> {
			%throw{$_.ast} = Any;
		}
		make %throw;
	}

	# Return just the content, let the upper layer figure out what key
	# to use.
	#
	method option( $/ ) {
		make $/<optionValue>.ast;
	}
	method optionsSpec( $/ ) {
		my %option;
		for $/<option> {
			%option{$_.<ID>.ast} = $_.ast;
		}
		make %option;
	}

	# Although like optionsSpec, it's a name/value pair that we don't really
	# need the <name> as part of the body, I'll just leave it this way
	# because there's only ever going to be one of these...
	#
	method action( $/ ) {
		make {
			name    => $/<action_name>.ast,
			content => $/<ACTION>.ast
		}
	}

	method exceptionHandler( $/ ) {
		make {
			argument => $/<ARG_ACTION>.Str,
			action   => $/<ACTION>.ast
		};
	}

	# <name> isn't really necessary at this point.
	#
	method parserRuleSpec( $/ ) {
		my @catch;
		for $/<exceptionGroup><exceptionHandler> -> $exception {
			@catch.append( $exception.ast );
		}
		make {
			type    => $/<ruleAttribute>.ast,
			throw   => $/<throwsSpec>.ast,
			return  => $/<ruleReturns>.ast,
			action  => $/<ARG_ACTION>.ast,
			local   => $/<localsSpec>.ast,
			throw   => $/<throwsSpec>.ast,
			option  => $/<optionsSpec>.ast,
			catch   => @catch.elems ?? @catch !! Any,
			finally => $/<exceptionGroup><finallyClause>.ast
		}
	}

	# <name> isn't really necessary at this point.
	#
	method lexerRuleSpec( $/ ) {
		make {
			type    => $/<FRAGMENT>.ast,
			throw   => Any,
			return  => Any,
			action  => Any,
			local   => Any,
			option  => Any,
			catch   => Any,
			finally => Any
		}
	}

	method TOP( $/ ) {
		my (
			%option, %import, %token, %action,
			%rule, %mode
		);
		for $/<prequelConstruct> -> $prequel {
			when $prequel.<optionsSpec> {
				%option =
					%option,
					$prequel.<optionsSpec>.ast;
			}
			when $prequel.<delegateGrammars> {
				# Don't forget, imports can happen anywhere.
				# They really don't have an effect on Perl, but
				# I'm collecting them for the sake of form.
				#
				%import =
					%import,
					$prequel.<delegateGrammars>.ast;
			}
			when $prequel.<tokensSpec> {
				%token = %token, $prequel.<tokensSpec>.ast;
			}
			when $prequel.<action> {
				%action = $prequel.<action>.ast;
			}
		}
		for $/<ruleSpec> -> $ruleSpec {
			when $ruleSpec.<parserRuleSpec> {
				%rule{$ruleSpec.<parserRuleSpec><ID>.ast} = 
					$ruleSpec.<parserRuleSpec>.ast;
			}
			when $ruleSpec.<lexerRuleSpec> {
				%rule{$ruleSpec.<lexerRuleSpec><ID>.ast} = 
					$ruleSpec.<lexerRuleSpec>.ast;
			}
		}
		for $/<modeSpec> -> $modeSpec {
			my $curMode = $modeSpec<ID>.ast;
			for $modeSpec<lexerRuleSpec> -> $rule {
				%mode{$curMode}{$rule.<ID>.ast} = $rule.ast;
			}
		}
		make {
			type      => $/<grammarType>.ast,
			name      => $/<ID>.ast,
			option    => %option,
			import    => %import,
			token     => %token,
			action    => %action,
			rule      => %rule,
			mode      => %mode
		}
	}
}

# vim: ft=perl6
