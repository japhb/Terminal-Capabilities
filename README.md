[![Actions Status](https://github.com/japhb/Terminal-Capabilities/actions/workflows/test.yml/badge.svg)](https://github.com/japhb/Terminal-Capabilities/actions)

NAME
====

Terminal::Capabilities - Container for terminal capabilities, with useful defaults

SYNOPSIS
========

```raku
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
```

DESCRIPTION
===========

Terminal::Capabilities is a relatively simple module that collects information about the capabilities of *modern* terminals (it assumes *at least* the ASCII character set, and ANSI/DEC VT style control sequence emulation).

This module does **NOT** do any auto-detection, merely serving as a standard for collecting capabilities detected or configured through other means. That said, there are reasonable defaults for each of the capability flags based on the collected submissions to the `Terminal::Tests` project. The default values represent the capabilities that are universally supported (or nearly so -- there are a few truly deeply broken terminals for which nearly *nothing* works properly which are considered out of scope for the defaults).

One quirk of this method of determining defaults is that 8-bit color is more uniformly supported by modern terminals than various color and style attributes that were "standardized" decades earlier. Thus `color8bit` is by default `True`, while `colorbright` and `italic` are by default `False`.

Known Symbol Sets
-----------------

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

The difference between `WGL4R` and full `WGL4` is that the latter includes 18 additional symbol and drawing glyphs needed for full compatibility with CP437, the code page (glyph set) used in IBM PC-compatible video ROMs and thus all DOS programs. As these 18 are considered optional in the WGL4 spec, `WGL4R` allows specifying only the symbols *required* by WGL4, and thus guaranteed to work in any terminal font with at least minimal WGL4 compatibility.

Known Feature Flags
-------------------

Several sets of flag (Bool) attributes indicate support for various features. There are sets for classic ANSI attributes, color support, and emoji handling:

<table class="pod-table">
<thead><tr>
<th>Attribute</th> <th>Supported Feature</th>
</tr></thead>
<tbody>
<tr> <td>.bold</td> <td>ANSI/VT100 bold attribute</td> </tr> <tr> <td>.italic</td> <td>ANSI/VT100 italic attribute</td> </tr> <tr> <td>.inverse</td> <td>ANSI/VT100 inverse attribute</td> </tr> <tr> <td>.underline</td> <td>ANSI/VT100 underline attribute</td> </tr> <tr> <td>.color3bit</td> <td>Original paletted 3-bit color</td> </tr> <tr> <td>.colorbright</td> <td>Bright variants of 3-bit palette</td> </tr> <tr> <td>.color8bit</td> <td>6x6x6 color cube and 24-value grayscale</td> </tr> <tr> <td>.color24bit</td> <td>24-bit RGB color</td> </tr> <tr> <td>.emoji-text</td> <td>Text outline emoji (VS15)</td> </tr> <tr> <td>.emoji-color</td> <td>Color emoji (VS16)</td> </tr> <tr> <td>.emoji-skin</td> <td>Skin tones for faces and people</td> </tr> <tr> <td>.emoji-iso</td> <td>Emoji flags for ISO country codes</td> </tr> <tr> <td>.emoji-reg</td> <td>Emoji flags for region codes</td> </tr> <tr> <td>.emoji-zwj</td> <td>Emoji combinations via joining (ZWJ)</td> </tr>
</tbody>
</table>

class Terminal::Capabilities
----------------------------

A container for the available capabilities of a particular terminal

### sub symbol-set

```raku
sub symbol-set(
    Str:D $set = "Full"
) returns SymbolSet:D
```

Determine the correct SymbolSet enumerant for a possibly mis-cased string

### has SymbolSet:D $.symbol-set

Largest supported symbol repertoire

### has Bool $.vt100-boxes

Supports VT100 box drawing glyphs (nearly universal, but only *required* by WGL4R)

### method best-symbol-set

```raku
method best-symbol-set(
    @sets
) returns SymbolSet:D
```

Find best symbol set supported by this terminal from a list of choices

### method best-symbol-choice

```raku
method best-symbol-choice(
    %options
) returns Mu
```

Choose the best choice out of options keyed by required symbol set

AUTHOR
======

Geoffrey Broadwell <gjb@sonic.net>

COPYRIGHT AND LICENSE
=====================

Copyright 2023,2025 Geoffrey Broadwell

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

