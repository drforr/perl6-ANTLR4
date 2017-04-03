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
class ANTLR4::Actions::AST
	{
	method grammarType($/)
		{
		make $/[0] ?? ~$/[0] !! 'DEFAULT'
		}

	method ID($/)
		{
		make ~$/
		}

	method ID_list($/)
		{
		make @<ID>>>.ast
		}

	method optionValue($/)
		{
		# XXX Should be able to be written cleaner.
		make $/<DIGITS>
			?? +$/<DIGITS>
			!! $/<STRING_LITERAL>
			?? ~$/<STRING_LITERAL>[0]
			!! $/<ID_list>.ast
		}

	method option($/)
		{
		make ~$/<key> => $/<optionValue>.ast
		}

	method optionsSpec($/)
		{
		make @<option>>>.ast
		}

	method delegateGrammar($/)
		{
		make ~$/<key> => $/<value>.ast
		}

	method delegateGrammars($/)
		{
		make @<delegateGrammar>>>.ast
		}

	method ID_list_trailing_comma($/)
		{
		make $<ID>>>.ast
		}

	method tokensSpec($/)
		{
		make $/<ID_list_trailing_comma>.ast
		}

	method action($/)
		{
		make ~$/<action_name> => ~$/<ACTION>
		}

	method terminal($/)
		{
		make
			[${ type         => 'terminal',
				content      => ~$/<scalar>[0],
				alias        => Nil,
				modifier     => Nil,
				greedy       => False,
				complemented => False }]
		}

	method atom($/)
		{
		make $/<terminal>.ast
		}

	method element($/)
		{
		make
			{
			type     => 'concatenation',
			label    => Nil,
			options  => [ ],
			commands => [ ],
			contents => $/<atom>.ast
			}
		}

	method elementOption($/)
		{
		make ~$/<key> => ~$/<value>
		}
 
	method elementOptions($/)
		{
		make @<elementOption>>>.ast
		}

	method parserElement($/)
		{
		my @element = @<element>>>.ast;

		# Add the options to the rule afterward, if there are any.
		#
		@element[0].<options> = $/<elementOptions>.ast
			if $/<elementOptions>;

		make @element;
		}

	method parserAlt($/)
		{
		my $ast =
			{
			type     => 'alternation',
			label    => Nil,
			options  => [ ],
			commands => [ ],
			contents => $/<parserElement>.ast
			};

		# Add the label to the rule afterward, if there is one.
		#
		$ast.<contents>[0]<label> = ~$/<label> if $/<label>;
		make $ast;
		}

	method parserAltList($/)
		{
		make @<parserAlt>>>.ast
		}

	method ruleReturns($/)
		{
		make ~$/<ARG_ACTION>
		}

	method throwsSpec($/)
		{
		make @<ID>>>.ast
		}

	method localsSpec($/)
		{
		make ~$/<ARG_ACTION>
		}

	method parserRuleSpec($/)
		{
		make 
			{
			type      => 'rule',
			name      => $/<name>.ast,
			attribute => $/<attribute> ?? ~$/<attribute>  !! Nil,
			action    => $/<action>    ?? ~$/<action>     !! Nil,
			return    => $/<returns>   ?? $/<returns>.ast !! Nil,
			throws    => $<throws>     ?? $/<throws>.ast  !! [ ],
			local     => $/<locals>    ?? $/<locals>.ast  !! Nil,
			options   => $<options>    ?? $/<options>.ast !! [ ],
			contents  => $/<parserAltList>.ast
			}
		}

	# And here's where we reuse the <terminal> ... er, term.
	#
	method lexerAtom($/)
		{
		make $/<terminal>.ast
		}

	method lexerElement($/) # 'channel' not in this term.
		{
		make
			{
			type     => 'concatenation',
			label    => Nil,
			options  => [ ],
			commands => [ ], # XXX Filled in by the next layer up
			contents => [ $<lexerAtom>.ast ]
			}
		}

	method lexerCommand($/)
		{
		make ~$/<lexerCommandName> => ~$/<lexerCommandExpr>[0]
		}

	method lexerCommands($/)
		{
		make @<lexerCommand>>>.ast
		}

	method lexerAlt($/)
		{
		my @lexerElement = @<lexerElement>>>.ast;

		# Add the command to the lexer element afterward, if any.
		#
		@lexerElement[0]<commands> = [ $/<lexerCommands>.ast ];
		make
			{
			type     => 'alternation',
			label    => Nil,
			options  => [ ],
			commands => [ ],
			contents => @lexerElement
			}
		}

	method lexerAltList($/)
		{
		make @<lexerAlt>>>.ast
		}

	method lexerRuleSpec($/)
		{
		make 
			{
			type      => 'rule',
			name      => $/<name>.ast,
			attribute => Nil,
			action    => Nil,
			return    => Nil,
			throws    => [ ],
			local     => Nil,
			options   => [ ],
			contents  => $/<lexerAltList>.ast
			}
		}

	method ruleSpec($/)
		{
		make $/<parserRuleSpec>.ast || $/<lexerRuleSpec>.ast
		}

	method TOP($/)
		{
		my ( @options, @imports, @tokens, @action );

		@options.append( $_.<options>.ast ) for $/<prequelConstruct>;

		@tokens.append( $_.<tokens>.ast ) for $/<prequelConstruct>;
		@action.append( $_.<actions>.ast ) for $/<prequelConstruct>;

		# XXX Apparently the way imports builds the list is mildly broken.
		for $/<prequelConstruct> -> $prequel
			{
			next unless $prequel.<imports>.ast;
			@imports = $prequel.<imports>.ast;
			last;
			}

		make
			{
			type     => $<grammarType>.ast,
			name     => ~$/<name>,
			options  => @options,
			imports  => @imports,
			tokens   => @tokens,
			actions  => @action,
			contents => @<ruleSpec>>>.ast
			}
		}

#`(
method lexerAlt($/)
	{
#`(
	make
		{
		type     => 'concatenation',
		contents => @<lexerElement>>>.ast,
		label    => Nil,
                options  => [ ],
		commands => $/<lexerCommands>.ast || [ ],
		}
)
	make
		{
		type    => 'concatenation',
		label   => Nil,
		options => [ ],
commands => [ skip => Nil ],
contents => [$<lexerElement>[0].ast],
		}
	}

method lexerElement($/)
	{
	make
		{
		type         => $/<ACTION>
			     ?? 'action'
			     !! $/<lexerAtom>
			     ?? $/<lexerAtom>.ast.<type>
			     !! $/<lexerBlock>.ast.<type>,
		alias        => $/<labeledElement>
			     ?? $/<labeledElement><ID>
			     !! Nil,
		modifier     => $/<ebnfSuffix>.ast.<modifier>,
		greedy       => $/<ebnf><ebnfSuffix>.ast.<greedy>
			     || $/<ebnfSuffix>.ast.<greedy>
			     || False,
		complemented => $/<lexerAtom>
			     ?? $/<lexerAtom>.ast.<complemented>
			     !! $/<lexerBlock>.ast.<complemented>,
		content      => $/<ACTION>
			     ?? $/<ACTION>.ast
			     !! $/<lexerAtom>
			     ?? $/<lexerAtom>.ast.<content>
			     !! $/<lexerBlock>.ast.<content>,
		}
	}

method lexerBlock($/)
	{
#`(
	make
		{
		type         => 'capturing group',
		contents     => @<lexeAltList>>>.ast,
		complemented => $/[0] || False,
		commands     => [ ]
		}
)

	make
		{
		type         => 'capturing group',
#		contents     => @<lexeAltList>>>.ast,
contents =>
  [{ type     => 'alternation',
     label    => Nil,
     options  => [ ],
     commands => [ ],
     contents =>
       [{ type     => 'concatenation',
          label    => Nil,
          options  => [ ],
          commands => [ ],
          contents  =>
            [{ type         => 'terminal',
               content      => '1',
               alias        => Nil,
               modifier     => Nil,
               greedy       => False,
               complemented => False }] },
        { type     => 'concatenation',
          label    => Nil,
          options  => [ ],
          commands => [ ],
          contents  =>
             [{ type         => 'terminal',
                content      => '2',
                alias        => Nil,
                modifier     => Nil,
                greedy       => False,
                complemented => False }] }] }],
complemented => $/[0] || False,
command      => [ ]
}
	}


method element($/)
	{
#`(
	make
		{ 
		type => $/<labeledElement>
			?? 'nonterminal'
			!! $/<ACTION>
			?? 'action'
			!! $/<ebnf><block><blockAltList>
			?? 'capturing group'
			!! $/<atom>.ast.<type>,
		alias => $/<labeledElement>
			?? $/<labeledElement><ID>
			!! Nil,
		content      => $/<labeledElement><atom>
			?? $/<labeledElement><atom>.ast.<content>
			!! $/<labeledElement><block>
			?? $/<labeledElement><block><blockAtList>.ast
			!! $/<ACTION>
			?? $/<ACTION>.ast
			!! $/<atom>
			?? $/<atom>.ast.<content>
			!! $/<ebnf><block>.ast,
		complemented => $/<atom><notSet>.defined,
		greedy       => $/<ebnf><ebnfSuffix>.ast.<greedy>
			|| $/<ebnfSuffix>.ast.<greedy>
			|| False,
		modifier     => $/<ebnf><ebnfSuffix>.ast.<modifier>
			|| $/<ebnfSuffix>.ast.<modifier>
		 }
)

	if $/<ebnf><block><blockAltList>
		{
		make
			{
			type         => $/<ebnf>.ast.<type>,
			alias        => $/<labeledElement><ID>,
			modifier     => $/<ebnf>.ast.<modifier>
				     || $/<ebnfSuffix>.ast.<modifier>,
			greedy       => $/<ebnf>.ast.<greedy>
				     || $/<ebnfSuffix>.ast.<greedy>
				     || False,
			complemented => $/<atom><notSet>.defined,
			content      => $/<ebnf>.ast.<content>,
			}
		}
	elsif $/<atom>
		{
		make
			{
			type         => $/<atom>.ast.<type>,
			alias        => $/<labeledElement><ID>,
			modifier     => $/<ebnf>.ast.<modifier>
					|| $/<ebnfSuffix>.ast.<modifier>,
			greedy       => $/<ebnf>.ast.<greedy>
					|| $/<ebnfSuffix>.ast.<greedy>
					|| False,
			complemented => $/<atom><notSet>.defined,
			content      => $/<atom>.ast.<content>,
			}
		}
	elsif $/<ACTION>
		{
		make
			{
			type         => 'action',
			alias        => $/<labeledElement><ID>,
			modifier     => $/<ebnf>.ast.<modifier>
					|| $/<ebnfSuffix>.ast.<modifier>,
			greedy       => $/<ebnf>.ast.<greedy>
					|| $/<ebnfSuffix>.ast.<greedy>
					|| False,
			complemented => $/<atom><notSet>.defined,
			content      => $/<ACTION>.ast,
			}
		}
	}
 
method ebnf($/)
	{
my @x = $/<block><blockAltList><parserElement>;
my @foo = @x>>.ast;
	make
		{
		type     => 'capturing group',
		modifier => $/<ebnfSuffix>.ast.<modifier>,
		greedy   => $/<ebnfSuffix>.ast.<greedy>,
		content  =>
			[
				{
				type     => 'concatenation',
				label    => Nil,
				options  => [ ],
				commands => [ ],
				content  => @foo[0], # XXX
				}
			]
		}
	}

method ebnfSuffix($/)
	{
	make
		{
		modifier => ~$/<MODIFIER>,
		greedy   => $/<GREED>.defined
		}
	}

method lexerAtom($/)
	{
#			!! $/<range>.ast
#			|| $/<LEXER_CHAR_SET>.ast
#			|| $/<terminal><scalar>.ast
			|| $/<notSet>.ast.<content>,
	make
		{
		type => ( $/.substr(0,1) eq '.' )
			?? 'regular expression'
			!! $/<range>
			?? 'range'
			!! $/<notSet><setElement><LEXER_CHAR_SET>
			?? 'character class'
			!! $/<notSet><setElement><terminal><STRING_LITERAL>
			?? 'terminal'
			!! $/<LEXER_CHAR_SET>
			?? 'character class'
			!! $/<terminal><STRING_LITERAL>
			?? 'terminal'
			!! $/<notSet><blockSet>
			?? 'capturing group'
			!! 'nonterminal',
		content => ( $/.substr(0,1) eq '.' )
			?? '.'
			!! $/<range>.ast
			|| $/<LEXER_CHAR_SET>.ast
			|| $/<terminal><scalar>.ast
			|| $/<notSet>.ast.<content>,
		complemented => $/<notSet>.defined
		}
	}

method atom($/)
	{
	make
		{
		type         => $/<notSet>.ast.<type>
		             ?? $/<notSet>.ast.<type>
		             !! $/<range>
		             ?? 'range'
		             !! $/<terminal><ID> # XXX work on this later.
		             ?? 'nonterminal'
		             !! $/<DOT>
		             ?? 'regular expression'
		             !! 'terminal',
		complemented => $/<notSet>.defined,
		content      => $/<notSet>
		             ?? $/<notSet>.ast.<content>
		             !! $/<range>
		             ?? $/<range>.ast
		             !! $/<DOT>
		             ?? ~$/<DOT>
		             !! $/<terminal><scalar>.ast
		}
	}

method notSet($/)
	{
	make
		{
		type    => $/<blockSet>
			?? 'capturing group'
			!! $/<setElement>.ast.<type>,
		content => $/<blockSet>
			?? $/<blockSet>.ast
			!! $/<setElement>.ast.<content>
		}
	}

method setElement($/)
	{
	make
		{
		type => $/<LEXER_CHAR_SET>
			?? 'character class'
			!! $/<terminal><ID>
			?? 'nonterminal'
			!! 'terminal',
		content => $/<LEXER_CHAR_SET>
			?? $/<LEXER_CHAR_SET>.ast
			!! $/<range>
			?? $/<range>.ast
			!! $/<terminal><scalar>.ast
		}
	}
)

	}

# vim: ft=perl6
