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
	method option( $/ ) {
		make {
			type         => Q{option},
			name         => $/<key>.ast,
			mode         => Any,
			variant      => Any,
			modifier     => Any,
			lexerCommand => Any,
			content      => $/<optionValue>.ast
		}
	}

	method delegateGrammar( $/ ) {
		make {
			type         => Q{import},
			name         => $/<key>.ast,
			mode         => Any,
			variant      => Any,
			modifier     => Any,
			lexerCommand => Any,
			content      => $/<value> ??
					$/<value>.ast !!
					Any
		}
	}

	method tokenName( $/ ) {
		make {
			type         => Q{token},
			mode         => Any,
			variant      => Any,
			name         => $/.Str,
			modifier     => Any,
			lexerCommand => Any,
			content      => Any
		}
	}

	# The top-level action can only occur once.
	#
	method action( $/ ) {
		make {
			type         => Q{action},
			mode         => Any,
			variant      => Any,
			name         => $/<action_name><ID>.ast,
			modifier     => Any,
			lexerCommand => Any,
			content      => $/<ACTION>.ast
		}
	}

	method make-literal( :$match ) { {
		type         => Q{literal},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => {
			intensifier  => Any,
			greedy       => False,
			complemented => False,
		},
		lexerCommand => Any,
		content      => $match<atom><terminal><scalar>[0].Str
	} }

	method make-lexer-literal( :$match ) { {
		type         => Q{literal},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => {
			intensifier  => Any,
			greedy       => False,
			complemented => False,
		},
		lexerCommand => Any,
		content      => $match.Str
	} }
	method make-EOF { {
		type         => Q{EOF},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => {
			intensifier  => Any,
			greedy       => False,
			complemented => False,
		},
		lexerCommand => Any,
		content      => Any
	} }
	method make-metacharacter( :$match ) { {
		type         => Q{metacharacter},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => {
			intensifier  => $match<ebnfSuffix><MODIFIER>.ast,
			greedy       => ?{$match<ebnfSuffix>:defined(<GREED>)},
			complemented => False,
		},
		lexerCommand => Any,
		content      => $match<atom><DOT>.Str
	} }
	# XXX sigh. The grammar has parser and lexer stuff that is completely
	# XXX separate yet completely parallel.
	#
	method make-lexer-metacharacter( :$match ) { {
		type         => Q{metacharacter},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => {
			intensifier  => Any,
			greedy       => False,
			complemented => False,
		},
		lexerCommand => Any,
		content      => $match<lexerAtom>[0].Str
	} }
	method make-imports( :$match ) { {
		type         => Q{imports},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => Any,
		lexerCommand => Any,
		content      => $match<delegateGrammar>>>.ast
	} }
	method make-options( :$match ) { {
		type         => Q{options},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => Any,
		lexerCommand => Any,
		content  => [
			$match<option>[0].ast
		]
	} }
	method make-tokens( :$match ) { {
		type         => Q{tokens},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => Any,
		lexerCommand => Any,
		content      => $match<tokenName>>>.ast
	} }
	method make-actions( :$match ) { {
		type         => Q{actions},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => Any,
		lexerCommand => Any,
		content  => [
			$match.ast
		]
	} }

	method make-lexer-concatenation( :$match ) { {
		type         => Q{concatenation},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => Any,
		lexerCommand => Any,
		content      => [
			self.make-lexer-literal(
				match => $match<lexerElement>[0]<lexerAtom><terminal><scalar>[0]
			),
			self.make-lexer-metacharacter(
				match => $match<lexerElement>[1]
			)
		]
	} }

	method make-lexer-character-class( :$match ) { {
		type         => Q{character class},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => {
			intensifier  => Any,
			greedy       => False,
			complemented => ?{$match<lexerBlock>:defined(<complement>)}
		},
		lexerCommand => Any,
		content      => [
			self.make-lexer-literal(
				match => $match<lexerBlock><lexerAltList><lexerAlt>[0]<lexerElement>[0]<lexerAtom><notSet><setElement><LEXER_CHAR_SET>[0][0]<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT>
			),
			self.make-lexer-literal(
				match => $match<lexerBlock><lexerAltList><lexerAlt>[0]<lexerElement>[0]<lexerAtom><notSet><setElement><LEXER_CHAR_SET>[0][1]<LEXER_CHAR_SET_RANGE><LEXER_CHAR_SET_ELEMENT>
			)
		]
	} }

	method make-lexer-capturing-group( :$match ) { {
		type         => Q{capturing group},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => {
			intensifier => $match<ebnfSuffix><MODIFIER>.ast,
			greedy       => False,
			complemented => ?$match<lexerBlock><lexerAltList><lexerAlt>[0]<lexerElement>[0]<lexerAtom><notSet>
		},
		lexerCommand => Any,
		content      => [
			self.make-lexer-character-class(
				match => $match
			)
		]
	} }

	method make-lexer-alternation( :$match ) { {
		type         => Q{alternation},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => Any,
		lexerCommand => Any,
		content      => [
			self.make-lexer-capturing-group(
				match => $match<lexerElement>[0]
			),
			self.make-lexer-concatenation(
				match => $match<lexerElement>[0]<lexerBlock><lexerAltList><lexerAlt>[1]
			)
		]
	} }

	method make-alternation( :$match ) { {
		type         => Q{alternation},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => Any,
		lexerCommand => Any,
		content      => [
			self.make-literal(
				match => $match<element>[2]<ebnf><block><blockAltList><parserElement>[0]<element>[0]
			),
			self.make-EOF(
				match => $match<element>[2]<ebnf><block><blockAltList><parserElement>[1]
			)
		]
	} }

	method make-capturing-group( :$match ) { {
		type         => Q{capturing group},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => {
			intensifier  => Any,
			greedy       => ?{$match<parserElement><element>[2]<ebnf><ebnfSuffix>:defined(<GREED>)},
			complemented => False,
		},
		lexerCommand => Any,
		content      => [
			self.make-alternation(
				match => $match<parserElement>
			)
		]
	} }
	method make-concatenation( :$match ) { {
		type         => Q{concatenation},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => Any,
		content      => [
			self.make-literal(
				match => $match<parserElement><element>[0]
			),
			self.make-metacharacter(
				match => $match<parserElement><element>[1],
			),
			self.make-capturing-group(
				match => $match
			)
		]
	} }

	method make-lexer-rule( :$match, :$mode ) { {
		type         => Q{rule},
		mode         => $mode.ast,
		variant      => $match<FRAGMENT>.Str,
		name         => $match<ID>.ast,
		modifier     => Any,
		lexerCommand => $match<lexerAltList><lexerAlt>[0]<lexerCommands><lexerCommand>[0]<ID>.ast,
		content      => [
			self.make-lexer-alternation(
				match => $match<lexerAltList><lexerAlt>[0]
			)
		]
	} }

	method optionValue( $/ ) { make $/.Str }
	method key( $/ ) { make $/.Str }
	method value( $/ ) { make $/.Str }
	method ID( $/ ) { make $/.Str }
	method MODIFIER( $/ ) { make $/.Str }
	method ACTION( $/ ) { make $/.Str }

	method TOP( $/ ) {
#say '[' ~ $/<modeSpec>[0]<lexerRuleSpec>[0]<lexerAltList><lexerAlt>[0]<lexerElement>[1] ~ ']';
#say '[' ~ $/<ruleSpec>[0]<parserRuleSpec><parserAltList><parserAlt>[0]<parserElement><element>[2]<ebnf><block><blockAltList><parserElement>[1] ~ ']';
#say '[' ~ $/<modeSpec>[0]<lexerRuleSpec>[0]<lexerAltList><lexerAlt>[0]<lexerElement>[0]<lexerBlock><lexerAltList><lexerAlt>[1]<lexerElement>[1].keys ~ ']';
#say '[' ~ $/<ruleSpec>[0]<parserRuleSpec><parserAltList><parserAlt>[0]<parserElement><element>[2]<ebnf><block><blockAltList><parserElement>[0]<element>[0]<ebnfSuffix><MODIFIER> ~ ']';

my $made = [ {
	type         => Q{grammar},
	mode         => Any,
	variant      => Any,
	name         => $/<ID>.ast,
	modifier     => Any,
	lexerCommand => Any,
	content      => [
		self.make-options(
			match => $/<prequelConstruct>[0]<optionsSpec>
		),
		self.make-imports(
			match => $/<prequelConstruct>[1]<delegateGrammars>
		),
		self.make-tokens(
			match => $/<prequelConstruct>[2]<tokensSpec><token_list_trailing_comma>
		),
		self.make-actions(
			match => $/<prequelConstruct>[3]<action>
		),
	{
		type         => Q{rules},
		mode         => Any,
		variant      => Any,
		name         => Any,
		modifier     => Any,
		lexerCommand => Any,
		content      => [ {
			type         => Q{rule},
			mode         => Any,
			variant      => Any,
			name         => $/<ruleSpec>[0]<parserRuleSpec><ID>.ast,
			modifier     => Any,
			lexerCommand => Any,
			content => [ {
				type         => Q{alternation},
				mode         => Any,
				variant      => Any,
				name         => Any,
				modifier     => Any,
				lexerCommand => Any,
				content      => [
					self.make-concatenation(
						match => $/<ruleSpec>[0]<parserRuleSpec><parserAltList><parserAlt>[0]
					)
				]
			} ]
		},
			self.make-lexer-rule(
				mode => $/<modeSpec>[0]<ID>,
				match => $/<modeSpec>[0]<lexerRuleSpec>[0]
			)
		]
	} ]
} ];
		make $made;
	}
}

# vim: ft=perl6
