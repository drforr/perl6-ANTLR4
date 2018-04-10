=begin pod

=head1 ANTLR4::Grammar

C<ANTLR4::Grammar> generates a perl6 representation of an ANTLR4 AST.

=head1 Synopsis

    use ANTLR4::Grammar;
    my $ag = ANTLR4::Grammar.new;

    say $ag.to-string('grammar Minimal { identifier : [A-Z][A-Za-z]+ ; }');
    say $ag.file-to-string('ECMAScript.g4');

=head1 Documentation

In its simplest form, just use the .to-string method on an existing grammar
text to get back its closest Perl 6 representation.

=head1 Extension

Suppose you don't like how the module formats the ANTLR grammar. Subclass this
module and override the C<to-lines> methods I've provided, or go all the way
back to the top level and replace the C<to-lines( Grammar $g )> with your own
inheritance hierarchy.

Maybe you want to add a way to create a bare-bones action class to go along
with your resulting grammar - override the C<to-string> method, you've got the
C<$grammar> value that you can walk through, and do your own thing.

=end pod

use v6;
use JSON::Tiny;
use ANTLR4::Grammar::Parser;
use ANTLR4::Actions::Perl6;

my role Indenting {
	method indent-line( $line ) {
		if $line {
			return "\t" ~ $line
		}
		return ''
	}

	method indent( *@lines ) {
		map { self.indent-line( $_ ) }, grep { /\S/ }, @lines
	}
}

my role Formatting {
	also does Indenting;

	sub greed-to-string( $a ) {
		$a.greed ?? '?' !! ''
	}

	sub modifier-to-string( $a ) {
		( $a.modifier // '' ) ~ greed-to-string( $a )
	}

	multi method to-lines( Any $a ) {
		die "Unknown type, this should not get triggred"
	}

	multi method to-lines( Action $a ) {
		return (
			q{#|} ~
				$a.name ~
				greed-to-string( $a )
		)
	}

	multi method to-lines( Token $t ) {
		my $lc-name = lc( $t.name );
		return (
			"token {$t.name} \{",
			self.indent-line(
				'||' ~ self.indent-line( "'$lc-name'" )
			),
			"\}"
		)
	}

	multi method to-lines( Terminal $t ) {
		my $name =
			$t.name ~~ / <-[ a ..z A .. Z ]> / ??
				q{'} ~ $t.name ~ q{'} !!
				$t.name;
		return (
			$name ~
				modifier-to-string( $t )
		)
	}

	multi method to-lines( Wildcard $w ) {
		return (
			"." ~
				modifier-to-string( $w )
		)
	}

	multi method to-lines( Grouping $g ) {
		my @child;
		for $g.child {
			@child.append( self.to-lines( $_ ) );
		}
		return (
			"\(" ~ self.indent-line( @child.shift ),
			self.indent( @child ),
			"\)" ~
				modifier-to-string( $g )
		).flat
	}

	multi method to-lines( EOF $e ) {
		return (
			'$' ~
				modifier-to-string( $e )
		)
	}

	multi method to-lines( Nonterminal $n ) {
		return (
			q{<} ~
				( $n.negated ?? '!' !! '' ) ~
				( $n.alias ?? ( $n.alias ~ '=' ) !! '' ) ~
				$n.name ~
			q{>} ~
			modifier-to-string( $n )
		)
	}

	multi method to-lines( CharacterRange $r ) {
		return (
			"{$r.from} .. {$r.to}"
		)
	}

	multi method to-lines( Character $c ) {
		return '\]' if $c.name eq ']';
		return $c.name
	}

	multi method to-lines( CharacterSet $c ) {
		my $negated = $c.negated ?? '-' !! '';
		my @child;
		for $c.child {
			@child.append( self.to-lines( $_ ) )
		}
		return (
			"<{$negated}[ {@child} ]>" ~
				modifier-to-string( $c )
		)
	}

	multi method to-lines( Concatenation $c ) {
		my @child;
		for $c.child {
			@child.append( self.to-lines( $_ ) )
		}
		@child
	}

	multi method to-lines( Alternation $a ) {
		my @child;
		for $a.child {
			# XXX These should always be objects...
			next unless $_;
			my @lines = self.indent( self.to-lines( $_ ) );
			if @lines {
				@lines[0] = '||' ~ @lines[0];
				@child.append( @lines );
			}
		}
		@child
	}

	multi method to-lines( Rule $r ) {
		my @child;
		for $r.child {
			@child.append( self.to-lines( $_ ) );
		}
		return (
			"rule {$r.name} \{",
			self.indent( @child ),
			"\}"
		).flat
	}

	multi method to-lines( Grammar $g ) {
		my @token;
		my @rule;
		my $json-str;
		my %json;

		@token.append( self.to-lines( $_ ) ) for $g.token;
		@rule.append( self.to-lines( $_ ) ) for $g.rule;
		%json<type> = $g.type if $g.type;
		%json<option> = $g.option if keys $g.option;
		%json<import> = $g.import if keys $g.import;
		%json<action> = $g.action if keys $g.action;

		$json-str = q{#|} ~ to-json( %json ) if keys %json;
		return (
			$json-str // (),
			"grammar {$g.name} \{",
				self.indent( @token ),
				self.indent( @rule ),
			"\}"
		).flat
	}
}

class ANTLR4::Grammar:ver<0.6.0> {
	also does Formatting;

	method to-string( Str $string ) {
		my $p = ANTLR4::Grammar::Parser.new;
		my $a = ANTLR4::Actions::Perl6.new;

		my $ast = $p.parse( $string, :actions( $a ) ).ast;
		return self.to-lines( $ast ).join( "\n" ) ~ "\n";
	}

	method file-to-string( Str $filename ) {
		my $p = ANTLR4::Grammar::Parser.new;
		my $a = ANTLR4::Actions::Perl6.new;

		my $ast = $p.parsefile( $filename, :actions( $a ) ).ast;
		return self.to-lines( $ast ).join( "\n" ) ~ "\n";
	}
}

# vim: ft=perl6
