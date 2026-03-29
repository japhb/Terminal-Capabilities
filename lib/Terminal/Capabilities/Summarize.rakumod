# ABSTRACT: Create one-line (very terse!) summary of autodetected terminal info

use Terminal::ANSIColor;
use Terminal::Capabilities::Autodetect;


#| Autodetect terminal capabilities and summarize results
multi sub summarize-autodetection() is export {
    summarize-autodetection(|terminal-env-detect)
}


#| Summarize previously-detected terminal capabilities
multi sub summarize-autodetection($caps, $terminal, $version) is export {
    my $draw    = (('V' if $caps.vt100-boxes),
                   ('H' if $caps.half-blocks),
                   ('Q' if $caps.quadrants),
                   ('S' if $caps.sextants),
                   ('O' if $caps.octants),
                   ('q' if $caps.sep-quadrants),
                   ('s' if $caps.sep-sextants),
                   ('o' if $caps.braille)).join;

    my $rgb     = colored('R', '255,0,0')
                ~ colored('G', '0,255,0')
                ~ colored('B', '100,100,255');
    my $color   = $caps.color24bit ??  $rgb  !!
                  $caps.color8bit  ??  '256' !!
                  $caps.color3bit  ??  'VT'  !! '';
    $color      = colored('B', 'bold white') ~ $color if $caps.colorbright;

    my $attrs   = ((colored('B', 'bold')       if $caps.bold),
                   (colored('F', 'faint')      if $caps.faint),
                   (colored('I', 'italic')     if $caps.italic),
                   (colored('I', 'inverse')    if $caps.inverse),
                   (colored('O', 'overline')   if $caps.overline),
                   (colored('S', 'strike')     if $caps.strike),
                   (colored('U', 'underline')  if $caps.underline),
                   (colored('D', 'dunderline') if $caps.dunderline)).join;

    my $un-flag = 'UN'.comb.map({ chr(ord($_) + 0x1F1A5) }).join;
    my $dragon  = '🏴' ~ 'gbwls'.comb.map({ chr(ord($_) + 0xE0000) }).join ~ "\xE007F";
    my $emoji   = (("😑\x[FE0E]"   if $caps.emoji-text),
                   ("😍\x[FE0F]"   if $caps.emoji-color),
                   ("🧓\x[1F3FF]"  if $caps.emoji-skin),
                   ($un-flag       if $caps.emoji-iso),
                   ($dragon        if $caps.emoji-reg),
                   ("👨\x[200D]🌾" if $caps.emoji-zwj)).join;

    my $quirks  = (('S' if $caps.narrow-emoji-needs-space),
                   ).join;

    my $summary = $version && !$terminal.contains('/')
                  ?? "$terminal/$version" !! $terminal;
    $summary ~= ' S:' ~ $caps.symbol-set;
    $summary ~= " A:$attrs"  if $attrs;
    $summary ~= " C:$color"  if $color;
    $summary ~= " D:$draw"   if $draw;
    $summary ~= " E:$emoji"  if $emoji;
    $summary ~= " Q:$quirks" if $quirks;

    ($caps, $terminal, $version, $summary)
}
