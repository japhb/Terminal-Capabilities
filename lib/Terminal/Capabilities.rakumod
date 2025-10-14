# ABSTRACT: Terminal capability and font repertoire data

=begin pod

=head1 NAME

Terminal::Capabilities - Container for terminal capabilities, with useful defaults


=head1 SYNOPSIS

=begin code :lang<raku>

use Terminal::Capabilities;
use Terminal::Capabilities::Autodetect;

# Autodetect terminal and its capabilities via examination of terminal-related
# environment variables.  This does not touch the process table or run any
# subprocesses, so it should be quick and safe.
my ($autocaps, $terminal, $version) = terminal-env-detect;

# Create a terminal capabilities object with DEFAULT settings based on the most
# commonly well-supported capabilities, as determined by submissions to the
# Terminal::Tests project.  This method does NO AUTODECTION.
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

The C<Terminal::Capabilities::Autodetect> child module provides routines for
autodetecting the user's terminal and its capabilities.  The first such
routine I<only> examines environment variables, thus avoiding creating
subprocesses, performing asynchronous queries to the terminal emulator, or
mucking about in the user's process table.  Simply call the `terminal-env-detect`
routine to obtain a pre-populated C<Terminal::Capabilities> object with the
autodetection's best guesses, along with the terminal type detected and
terminal program version if available:

=begin code :lang<raku>

use Terminal::Capabilities::Autodetect;
my ($caps, $type, $version) = terminal-env-detect;

=end code

Conversely, the core C<Terminal::Capabilities> module does B<not> do any
autodetection, merely serving as a standard for collecting capabilities
detected or configured through other means.  That said, there are reasonable
defaults for each of the capability flags based on the collected submissions to
the C<Terminal::Tests> project.  The default values represent the capabilities
that are universally supported (or nearly so -- there are a few truly deeply
broken terminals for which nearly I<nothing> works properly which are
considered out of scope for the defaults).

One quirk of this method of determining defaults is that 8-bit color is more
uniformly supported by modern terminals than various color and style attributes
that were "standardized" decades earlier.  Thus C<color8bit> is by default
C<True>, while C<colorbright> and C<italic> are by default C<False>.

=head2 Known Symbol Sets

In superset order, from smallest to largest:

=begin table
    Symbol Set | Contents
    ===========|=========
    ASCII      | 7-bit ASCII printables only (most compatible)
    Latin1     | Latin-1 / ISO-8859-1
    CP1252     | CP1252 / Windows-1252
    W1G        | W1G-compatible subset of WGL4R
    WGL4R      | Required (non-optional) WGL4 glyphs
    WGL4       | Full WGL4 / Windows Glyph List 4
    MES2       | MES-2 / Multilingual European Subset No. 2
    Uni1       | Unicode 1.1
    Uni3       | Unicode 3.2
    Uni7       | Unicode 7.0 and Emoji 0.7
    Full       | Full modern Unicode support (most features)
=end table

The difference between C<WGL4R> and full C<WGL4> is that the latter includes 18
additional symbol and drawing glyphs needed for full compatibility with CP437,
the code page (glyph set) used in IBM PC-compatible video ROMs and thus all DOS
programs.  As these 18 are considered optional in the WGL4 spec, C<WGL4R>
allows specifying only the symbols I<required> by WGL4, and thus guaranteed to
work in any terminal font with at least minimal WGL4 compatibility.

=head2 Known Feature Flags

Several sets of flag (Bool) attributes indicate support for various features.
There are sets for classic ANSI attributes, color support, and emoji handling:

=begin table
    Attribute    | Supported Feature
    =============|========================================
    .bold        | ANSI/VT100 bold attribute
    .italic      | ANSI/VT100 italic attribute
    .inverse     | ANSI/VT100 inverse attribute
    .underline   | ANSI/VT100 underline attribute
    .color3bit   | Original paletted 3-bit color
    .colorbright | Bright variants of 3-bit palette
    .color8bit   | 6x6x6 color cube and 24-value grayscale
    .color24bit  | 24-bit RGB color
    .emoji-text  | Text outline emoji (VS15)
    .emoji-color | Color emoji (VS16)
    .emoji-skin  | Skin tones for faces and people
    .emoji-iso   | Emoji flags for ISO country codes
    .emoji-reg   | Emoji flags for region codes
    .emoji-zwj   | Emoji combinations via joining (ZWJ)
=end table

=end pod


#| A container for the available capabilities of a particular terminal
unit class Terminal::Capabilities;


# Known symbol sets in superset order, smallest to largest
# Note: Unicode 2.x intentionally skipped as only 4 general symbol codepoints
#       were added outside the Hangul, Tibetan, and Hebrew scripts (the 2.x focus)
enum SymbolSet < ASCII Latin1 CP1252 W1G WGL4R WGL4 MES2 Uni1 Uni3 Uni7 Full >;


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
