class Grammar::ANTLR::Actions;

#method TOP($/) {
#    make $/.values.[0].ast;
#};
#method object($/) {
#    make $<pairlist>.ast.hash.item;
#}
#
#method pairlist($/) {
#    make $<pair>>>.ast.flat;
#}
#
#method pair($/) {
#    make $<string>.ast => $<value>.ast;
#}
#
#method array($/) {
#    make $<arraylist>.ast.item;
#}
#
#method arraylist($/) {
#    make [$<value>>>.ast];
#}
#
#method string($/) {
#    make +@$<str> == 1
#        ?? $<str>[0].ast
#        !! $<str>>>.ast.join;
#}
#method value:sym<number>($/) { make +$/.Str }
#method value:sym<string>($/) { make $<string>.ast }
#method value:sym<true>($/)   { make Bool::True  }
#method value:sym<false>($/)  { make Bool::False }
#method value:sym<null>($/)   { make Any }
#method value:sym<object>($/) { make $<object>.ast }
#method value:sym<array>($/)  { make $<array>.ast }
#
#method str($/)               { make ~$/ }
#
#my %h = '\\' => "\\",
#        '/'  => "/",
#        'b'  => "\b",
#        'n'  => "\n",
#        't'  => "\t",
#        'f'  => "\f",
#        'r'  => "\r",
#        '"'  => "\"";
#method str_escape($/) {
#    if $<utf16_codepoint> {
#        make utf16.new( $<utf16_codepoint>.map({:16(~$_)}) ).decode();
#    } else {
#        make %h{~$/};
#    }
#}


# vim: ft=perl6
