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
	method ACTION( $/ ) { make $/.Str }
	method ID( $/ ) { make $/.Str }
	method optionValue( $/ ) { make $/.Str }
	method tokenName( $/ ) { make $/.Str }
	method grammarType( $/ ) { make $/[0] ?? $/[0].Str !! Any }
	method value( $/ ) { make $/ ?? $/.Str !! Any }
	method option( $/ ) {
		make {
			name    => $/<ID>.ast,
			content => $/<optionValue>.ast
		}
	}

	method delegateGrammar( $/ ) {
		make {
			name    => $/<key>.ast,
			content => $/<value>.ast
		}
	}

	method action( $/ ) {
		make {
			name    => $/<action_name><ID>.ast,
			content => $/<ACTION>.ast
		}
	}

	method TOP( $/ ) {
		my (
			%option, %import, %token, %action,
			%rule, %mode
		);
		for $/<prequelConstruct> {
			when $_<optionsSpec><option> {
				for $_<optionsSpec><option> {
					%option{$_.ast.<name>} =
						$_.ast.<content>;
				}
			}
			when $_<delegateGrammars><delegateGrammar> {
				for $_<delegateGrammars><delegateGrammar> {
					%import{$_.ast.<name>} =
						$_.ast.<content>;
				}
			}
			when $_<tokensSpec> {
				for $_<tokensSpec><token_list_trailing_comma><tokenName>>>.ast {
					%token{$_.Str} = Any;
				}
			}
			when $_<action> {
				%action =
					name    => $_<action>.ast.<name>,
					content => $_<action>.ast.<content>
				;
				
			}
		}
		for $/<ruleSpec> {
			when $_<parserRuleSpec> {
				%rule{$_<parserRuleSpec><ID>.Str} = {
				}
			}
			when $_<lexerRuleSpec> {
				%rule{$_<lexerRuleSpec><ID>.Str} = {
				}
			}
		}
		for $/<modeSpec> {
			my $curMode = $_<ID>.Str;
			for $_<lexerRuleSpec> {
				%mode{$curMode}{$_<ID>.Str} = {
				}
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
