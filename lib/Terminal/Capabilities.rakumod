# ABSTRACT: Terminal capability and font repertoire data

=begin pod

=head1 NAME

Terminal::Capabilities - Container for terminal capabilities, with useful defaults


=head1 SYNOPSIS

=begin code :lang<raku>

use Terminal::Capabilities;

# Create a terminal capabilities object with default settings based on the most
# commonly well-supported capabilities, as determined by submissions to the
# Terminal::Tests project.
my Terminal::Capabilities $caps .= new;

# Examine individual capabilities
say $caps.symbol-set;   # ASCII by default, as it is the most compatible
say $caps.vt100-boxes;  # False by default, because ASCII does not require it
say $caps.color8bit;    # True  by default, since most terminals support it

# Override default symbol set
my $symbol-set = Terminal::Capabilities::SymbolSet::Uni1;
my $caps       = Terminal::Capabilities.new(:$symbol-set);

# Symbol set affects default for other features
say $caps.vt100-boxes;  # True, because WGL4R and all larger sets require it

# Determine best available symbol set supported by terminal out of a list
say $caps.best-symbol-set(< ASCII WGL4 MES2 Uni7 >);  # MES2, best <= Uni1

# Select from a list of options keyed by required symbol set
my %arrows = ASCII  => « < > »,
             Latin1 => < « » >,
             WGL4   => < ◄ ► >,
             Uni1   => < ◀ ▶ >,
             Uni7   => < ⯇ ⯈ >;
say $caps.best-symbol-choice(%arrows);  # ◀ ▶ , the Uni1 option

# Map a possibly mis-cased string to a SymbolSet enumerant (for processing
# user symbol set config requests)
my $symbol-set = symbol-set('cp1252');  # Terminal::Capabilities::SymbolSet::CP1252

=end code


=head1 DESCRIPTION

Terminal::Capabilities is a relatively simple module that collects information
about the capabilities of I<modern> terminals (it assumes I<at least> the ASCII
character set, and ANSI/DEC VT style control sequence emulation).

This module does B<NOT> do any auto-detection, merely serving as a standard for
collecting capabilities detected or configured through other means.  That said,
there are reasonable defaults for each of the capability flags based on the
collected submissions to the C<Terminal::Tests> project.  The default values
represent the capabilities that are universally supported (or nearly so --
there are a few truly deeply broken terminals for which nearly I<nothing>
works properly which are considered out of scope for the defaults).

One quirk of this method of determining defaults is that 8-bit color is more
uniformly supported by modern terminals than various color and style attributes
that were "standardized" decades earlier.  Thus C<color8bit> is by default
C<True>, while C<colorbright> and C<italic> are by default C<False>.

=head2 Known Symbol Sets

In superset order, from smallest to largest:

    ASCII    7-bit ASCII printables only (most compatible)
    Latin1   Latin-1 / ISO-8859-1
    CP1252   CP1252 / Windows-1252
    W1G      W1G-compatible subset of WGL4R
    WGL4R    Required (non-optional) WGL4 glyphs
    WGL4     Full WGL4 / Windows Glyph List 4
    MES2     MES-2 / Multilingual European Subset No. 2
    Uni1     Unicode 1.1
    Uni7     Unicode 7.0 + Emoji 0.7
    Full     Full modern Unicode support (most features)

The difference between C<WGL4R> and full C<WGL4> is that the latter includes 18
additional symbol and drawing glyphs needed for full compatibility with CP437,
the code page (glyph set) used in IBM PC-compatible video ROMs and thus all DOS
programs.  As these 18 are considered optional in the WGL4 spec, C<WGL4R>
allows specifying only the symbols I<required> by WGL4, and thus guaranteed to
work in any terminal font with at least minimal WGL4 compatibility.

=end pod


#| A container for the available capabilities of a particular terminal
unit class Terminal::Capabilities;


# Known symbol sets in superset order
enum SymbolSet < ASCII Latin1 CP1252 W1G WGL4R WGL4 MES2 Uni1 Uni7 Full >;


#| Determine the correct SymbolSet enumerant for a possibly mis-cased string
sub symbol-set(Str:D $set = 'Full' --> SymbolSet:D) is export {
    constant %sets = SymbolSet.^enum_value_list.map({ .Str.fc => $_ });
    %sets{$set.fc} // ASCII
}


#| Largest supported symbol repertoire
has SymbolSet:D $.symbol-set = ASCII;

#| Supports VT100 box drawing glyphs (nearly universal, but only *required* by WGL4R)
has Bool $.vt100-boxes = $!symbol-set >= WGL4R;

# Feature flags, with defaults based on majority of Terminal::Tests
# screenshot submissions (True iff universally supported or nearly so)
has Bool $.bold        = True;   #= Supports bold attribute
has Bool $.italic      = False;  #= Supports italic attribute
has Bool $.inverse     = True;   #= Supports inverse attribute
has Bool $.underline   = True;   #= Supports underline attribute

has Bool $.color3bit   = True;   #= Supports original paletted 3-bit color
has Bool $.colorbright = False;  #= Supports bright foregrounds for 3-bit palette
has Bool $.color8bit   = True;   #= Supports 6x6x6 color cube + 24-value grayscale
has Bool $.color24bit  = False;  #= Supports 24-bit RGB color

has Bool $.emoji-text  = False;  #= Supports text outline emoji (VS15)
has Bool $.emoji-color = False;  #= Supports color emoji (VS16)
has Bool $.emoji-skin  = False;  #= Supports skin tones for faces and people
has Bool $.emoji-iso   = False;  #= Supports emoji flags for ISO country codes
has Bool $.emoji-reg   = False;  #= Supports emoji flags for region codes
has Bool $.emoji-zwj   = False;  #= Supports combined emoji via joining (ZWJ)


#| Find best symbol set supported by this terminal from a list of choices
method best-symbol-set(@sets --> SymbolSet:D) {
    @sets.map({ SymbolSet::{$_} // ASCII })
         .grep(* <= $.symbol-set).max
}

#| Choose the best choice out of options keyed by required symbol set
method best-symbol-choice(%options) {
    %options{self.best-symbol-set(%options.keys)}
}


=begin pod

=head1 AUTHOR

Geoffrey Broadwell <gjb@sonic.net>


=head1 COPYRIGHT AND LICENSE

Copyright 2023,2025 Geoffrey Broadwell

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod
