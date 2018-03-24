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

	multi method to-lines( Token $t ) {
		my $lc-name = lc( $t.name );
		return (
			"token {$t.name} \{",
			self.indent-line(
				'||' ~ self.indent-line( "'$lc-name'" )
			),
			"\}"
		).flat
	}

	multi method to-lines( Terminal $t ) {
		my $name = $t.name ~~ / <-[ a ..z A .. Z ]> / ??
			q{'} ~ $t.name ~ q{'} !!
			$t.name;	
		return $name ~ $t.modifier ~ $t.greed
	}

	multi method to-lines( Wildcard $w ) {
		return "." ~ $w.modifier ~ $w.greed
	}

	multi method to-lines( Grouping $g ) {
		my @content;
		for $g.content {
			@content.append( self.to-lines( $_ ) );
		}
		return (
			"\(" ~ self.indent-line( @content.shift ),
			self.indent( @content ),
			"\)" ~ $g.modifier ~ $g.greed
		).flat
	}

	multi method to-lines( EOF $e ) {
		return '$' ~ $e.modifier ~ $e.greed
	}

	multi method to-lines( Nonterminal $n ) {
		return q{<} ~ $n.name ~ q{>} ~ $n.modifier ~ $n.greed
	}

	multi method to-lines( Range $r ) {
		my $negated = $r.negated ?? '-' !! '';
		"<{$negated}[ {$r.from} .. {$r.to} ]>" ~ $r.modifier ~ $r.greed
	}

	multi method to-lines( CharacterSet $c ) {
		my $negated = $c.negated ?? '-' !! '';
		my @content;
		for $c.content {
			if /(.)\-(.)/ {
				@content.append( qq{$0 .. $1} );
			}
			else {
				@content.append( $_ );
			}
		}
		"<{$negated}[ {@content} ]>" ~ $c.modifier ~ $c.greed
	}

	multi method to-lines( Concatenation $c ) {
		my @content;
		for $c.content {
			@content.append( self.to-lines( $_ ) )
		}
		@content
	}

	multi method to-lines( Alternation $a ) {
		my @content;
		for $a.content {
			# XXX These should always be objects...
			next unless $_;
			my @lines = self.indent( self.to-lines( $_ ) );
			if @lines {
				@lines[0] = '||' ~ @lines[0];
				@content.append( @lines );
			}
		}
		@content.flat
	}

	multi method to-lines( Rule $r ) {
		my @content;
		for $r.content {
			@content.append( self.to-lines( $_ ) );
		}
		return (
			"{$r.type} {$r.name} \{",
			self.indent( @content ),
			"\}"
		).flat
	}

	multi method to-lines( Notes $n ) {
#`(
		my $json;
		for @key -> $key {
			$json.{$key} = $ast.{$key} if $ast.{$key};
		}
		if $json {
			my $json-str = to-json( $json );
			return qq<#|$json-str>;
		}
		return '';
)
	}

	multi method to-lines( Grammar $g ) {
		my @content;
		for $g.content {
			@content.append( self.to-lines( $_ ) )
		}
		return (
			"grammar {$g.name} \{",
			self.indent( @content ),
			"\}"
		).flat
	}
}

class ANTLR4::Grammar:ver<0.2.0> {
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
