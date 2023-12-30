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

Copyright 2023 Geoffrey Broadwell

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

