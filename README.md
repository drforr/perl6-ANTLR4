ANTLR4
=======

ANTLR4 proides an ANTLR4 to Perl6 Grammar converter.

The grammar, AST and Perl6 bindings are provided as separate modules, so you can view both the raw abstract syntax tree and the final Perl6 converted output.

Installation
============

* Using panda (a module management tool bundled with Rakudo Star):

```
    panda update && panda install ANTLR4
```

* Using ufo (a project Makefile creation script bundled with Rakudo Star) and make:

```
    ufo                    
    make
    make test
    make install
```

## Testing

To run tests:

```
    prove -e perl6
```

## Author

Jeffrey Goff, DrFOrr on #perl6, https://github.com/drforr/

## License

Artistic License 2.0
