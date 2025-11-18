# ABSTRACT: Use various techniques to autodetect terminal capabilities

use Terminal::Capabilities;

sub terminal-env-detect() is export {
    my $colorterm   = %*ENV<COLORTERM>;
    my $colorfgbg   = %*ENV<COLORFGBG> // '';
    my $term        = %*ENV<TERM> // '';
    my $lang        = %*ENV<LANG> // '';

    my $encoding    = $lang.split('.')[1] // '';
    my $has-utf8    = $encoding eq 'UTF-8';
    my $symbol-set  = symbol-set($has-utf8 ?? 'Uni1' !! 'ASCII');

    my Str    $terminal;
    my Str    $version;

    my Bool:D $vt100-boxes   = $symbol-set >= Terminal::Capabilities::SymbolSet::WGL4R;
    my Bool:D $half-blocks   = $symbol-set >= Terminal::Capabilities::SymbolSet::WGL4;
    my Bool:D $braille       = $symbol-set >= Terminal::Capabilities::SymbolSet::Uni3;
    my Bool:D $quadrants     = $symbol-set >= Terminal::Capabilities::SymbolSet::Uni3;
    my Bool:D $sextants      = False;
    my Bool:D $octants       = False;
    my Bool:D $sep-quadrants = False;
    my Bool:D $sep-sextants  = False;

    my Bool:D $italic      = False;

    my Bool:D $color24bit  = ?$term.contains('truecolor'|'24bit')
                           || so ($colorterm // '') eq 'truecolor'|'24bit';
    my Bool:D $color8bit   = ?$term.contains('256color'|'-256') || $color24bit;
    my Bool:D $color3bit   = $colorterm.defined || $color8bit;
    my Bool:D $colorbright = False;

    my Bool:D $emoji-text  = False;
    my Bool:D $emoji-color = False;
    my Bool:D $emoji-skin  = False;
    my Bool:D $emoji-iso   = False;
    my Bool:D $emoji-reg   = False;
    my Bool:D $emoji-zwj   = False;

    # Detect terminal multiplexers and recurse for underlying terminal
    if %*ENV<ZELLIJ>.defined {
        $terminal    = 'zellij';

        # Zellij breaks these, regardless of underlying terminal
        $emoji-text  = False;
        $emoji-reg   = False;
        $emoji-zwj   = False;

        # Try to recurse to detect underlying terminal's capabilities
        temp %*ENV;
        %*ENV<ZELLIJ>:delete;
        my ($under-caps, $under-terminal, $under-version) = terminal-env-detect;

        my $caps   = $under-caps.clone(:$emoji-text, :$emoji-reg, :$emoji-zwj);
        $terminal ~= '+' ~ $under-terminal;
        $terminal ~= '/' ~ $under-version if  $under-version
                                          && !$under-terminal.contains('/');

        return ($caps, $terminal, $version);
    }
    elsif ?$term.starts-with('tmux') {
        $terminal   = 'tmux';
        $version    = %*ENV<TERM_PROGRAM_VERSION>;

        # tmux breaks these, regardless of underlying terminal
        # XXXX: color24bit rarely *not* broken?
        $color24bit = False;
        $emoji-iso  = False;

        # Try to recurse to detect underlying terminal's capabilities
        # Note: tmux tramples several variables; flush or replace them all
        temp %*ENV<TERM> = $term eq 'tmux-256color' || $color8bit
                           ?? 'xterm-256color' !! 'xterm';
        temp %*ENV<TMUX> = '';
        temp %*ENV<TMUX_PANE> = '';
        temp %*ENV<TERM_PROGRAM> = 'unknown';
        temp %*ENV<TERM_PROGRAM_VERSION> = '';

        my ($under-caps, $under-terminal, $under-version) = terminal-env-detect;

        my $caps   = $under-caps.clone(:$color24bit, :$emoji-reg, :$emoji-zwj);
        $terminal ~= '/' ~ $version if $version;
        $terminal ~= '+' ~ $under-terminal;
        $terminal ~= '/' ~ $under-version if  $under-version
                                          && !$under-terminal.contains('/');

        return ($caps, $terminal, $version);
    }
    elsif ?$term.starts-with('screen') {
        $terminal   = 'screen';

        # Screen breaks these, regardless of underlying terminal
        # XXXX: 24-bit color is supposedly fixed in screen 5.0, but
        #       we don't have a way to detect screen's version yet
        # XXXX: Breaks color8bit for some terminals but not others;
        #       how to detect this?
        $italic     = False;
        $color24bit = False;

        # Try to recurse to detect underlying terminal's capabilities
        temp %*ENV<TERM> = $term ~~ /^ 'screen.' (.+) $/ ?? ~$0 !!
                           $color8bit ?? 'xterm-256color' !! 'xterm';
        my ($under-caps, $under-terminal, $under-version) = terminal-env-detect;

        my $caps   = $under-caps.clone(:$italic, :$color24bit);
        $terminal ~= '+' ~ $under-terminal;
        $terminal ~= '/' ~ $under-version if  $under-version
                                          && !$under-terminal.contains('/');

        return ($caps, $terminal, $version);
    }

    # Detect actual terminal emulators
    my $xtermish = $term.starts-with('xterm');
    if $xtermish {
        $vt100-boxes = True;
        $color3bit   = True;

        if $term eq 'xterm-kitty' || %*ENV<KITTY_WINDOW_ID> {
            $terminal   = 'kitty';
            $italic     = True;
            $color24bit = True;
            $color8bit  = True;

            if $has-utf8 {
                $symbol-set  = symbol-set('Full');
                $braille     = True;
                $quadrants   = True;
                $sextants    = True;
                $emoji-text  = True;
                $emoji-color = True;
                $emoji-skin  = True;
                $emoji-iso   = True;
                $emoji-zwj   = True;
            }
        }
        elsif %*ENV<VTE_VERSION> -> $v {
            $terminal = 'VTE';
            $version  = $v;
            $italic   = True;

            if $has-utf8 {
                $symbol-set  = symbol-set('Uni7');
                $braille     = True;
                $quadrants   = True;
                $sextants    = True;
                $emoji-text  = True;
                $emoji-color = True;
                $emoji-reg   = True;

                # Planned for VTE 0.84 AKA VTE/8400
                # See https://gitlab.gnome.org/GNOME/vte/-/issues/2909
                if $version >= 8400 {
                    $emoji-skin = True;
                    $emoji-iso  = True;
                    $emoji-zwj  = True;
                }
            }

            # Mixed among VTEs:
            #       True  for gnome-terminal, mate-terminal, tilix, xfce4-terminal
            #       False for others
            # XXXX: Better way to test?  mate-terminal is not detected
            $colorbright  =  ?%*ENV<GNOME_TERMINAL_SERVICE>
                          || ?%*ENV<TILIX_ID>;
        }
        elsif %*ENV<XTERM_VERSION> -> $v {
            # XTERM_VERSION was added in version 202 released in May 2005
            $terminal     = 'xterm';
            $version      = $v.comb(/\d+/)[0] || 0;

            $italic       = True;
            $colorbright  = True;
            $color8bit  ||= $version >= 331;  # When it became default
            $color24bit ||= $version >= 331;

            if $has-utf8 {
                $symbol-set = symbol-set('Uni3');
                $braille    = True;
                $quadrants  = True;
            }
        }
        elsif %*ENV<KONSOLE_VERSION> -> $v {
            # Konsole sets COLORTERM=truecolor, detected above
            $terminal = 'Konsole';
            $version  = $v;
            $italic   = True;

            if $has-utf8 {
                $symbol-set = symbol-set('Uni7');
                $braille    = True;
                $quadrants  = True;
                $sextants   = True;
                $emoji-text = True;
            }
        }
        elsif %*ENV<ZUTTY_VERSION> -> $v {
            # Zutty sets COLORTERM=truecolor, detected above
            $terminal    = 'Zutty';
            $version     = $v;
            $colorbright = True;

            if $has-utf8 {
                $symbol-set = symbol-set('Uni3');
                $braille    = True;
                $quadrants  = True;
            }
        }
        elsif %*ENV<ALACRITTY_WINDOW_ID> {
            # XXXX: Duplicated from non-xtermish case for multiplexer recursion

            # Alacritty sets COLORTERM=truecolor, detected above
            $terminal = 'Alacritty';
            $italic   = True;

            if $has-utf8 {
                $symbol-set = symbol-set('Uni7');
                $braille    = True;
                $quadrants  = True;
                $sextants   = True;
                $emoji-text = True;
            }
        }
        elsif %*ENV<WT_SESSION> {
            # XXXX: Duplicated from non-xtermish case for multiplexer recursion

            $terminal    = 'Windows Terminal';
            $italic      = True;
            $color3bit   = True;
            $color8bit   = True;
            $color24bit  = True;
            $colorbright = True;
            $vt100-boxes = True;
            $half-blocks = True;

            if $has-utf8 {
                $symbol-set  = symbol-set('Uni7');
                $braille     = True;
                $quadrants   = True;
                $emoji-color = True;
                $emoji-skin  = True;
                $emoji-zwj   = True;
            }
        }
        elsif %*ENV<COLORSCHEMES_DIR> {
            $terminal = 'CRT';  # AKA Cool Retro Term, QMLTermWidget
            $italic   = True;

            if $has-utf8 {
                # Note: Layout seems like a proportional font
                $symbol-set = symbol-set('Uni3');
                $braille    = True;
                $quadrants  = True;
                $sextants   = True;
                $emoji-text = True;
            }
        }
        elsif %*ENV<QT_SCALE_FACTOR_ROUNDING_POLICY> {
            # Qt sets COLORTERM=truecolor, detected above
            $terminal = 'Qt';  # AKA Deepin, QTerminal
            $italic   = True;

            if $has-utf8 {
                $symbol-set = symbol-set('Uni7');
                $braille    = True;
                $emoji-text = True;
            }
        }
        elsif %*ENV<TERM_PROGRAM> -> $prog {
            $terminal = $prog;
            $version  = %*ENV<TERM_PROGRAM_VERSION> // '';

            if %*ENV<TERMINOLOGY> {
                $italic      = True;
                $colorbright = True;
                $color8bit   = True;

                if $has-utf8 {
                    $symbol-set = symbol-set('Uni3');
                    $braille    = True;
                    $emoji-text = True;
                }
            }
            elsif $prog eq 'ghostty' || %*ENV<GHOSTTY_BIN_DIR> {
                # Ghostty sets COLORTERM=truecolor, detected above
                $terminal = 'ghostty';
                $italic   = True;

                if $has-utf8 {
                    $symbol-set    = symbol-set('Full');
                    $braille       = True;
                    $quadrants     = True;
                    $sextants      = True;
                    $octants       = True;
                    $sep-quadrants = True;
                    $sep-sextants  = True if Version($version) >= Version(1.2);

                    $emoji-text    = True;
                    $emoji-color   = True;
                    $emoji-skin    = True;
                    $emoji-iso     = True;
                    $emoji-reg     = True;
                    $emoji-zwj     = True;
                }
            }
            elsif $prog eq 'iTerm.app' {
                $italic       = True;
                $color8bit    = True;
                $color24bit ||= ($version // '').split('.')[0] >= 3;

                if $has-utf8 {
                    # XXXX: Need to update symbols using recent test

                    $emoji-color = True;
                    $emoji-skin  = True;
                    $emoji-iso   = True;
                    $emoji-reg   = True;
                    $emoji-zwj   = True;
                }
            }
            elsif $prog eq 'Apple_Terminal' {
                $color8bit = True;
                # XXXX: Need to update utf-8 symbols using recent test
            }
        }
        else {
            $terminal = 'xtermish';

            # Known to hit this branch:
            #    pterm (PuTTY terminal) -- Supports several useful features but
            #                              can't be detected as itself via env
            #
            #    tmux recursive check   -- tmux overwrites several env vars
            #                              needed to detect many terminals
            #
            #    screen recursive check -- screen *sometimes* overwrites TERM,
            #                              so non-xtermish may end up here
        }
    }
    elsif $term eq 'alacritty' || %*ENV<ALACRITTY_WINDOW_ID> {
        # XXXX: Duplicated above into xtermish case for multiplexer recursion

        # Alacritty sets COLORTERM=truecolor, detected above
        $terminal = 'Alacritty';
        $italic   = True;

        if $has-utf8 {
            $symbol-set = symbol-set('Uni7');
            $braille    = True;
            $quadrants  = True;
            $sextants   = True;
            $emoji-text = True;
        }
    }
    elsif %*ENV<WT_SESSION> {
        # XXXX: Duplicated above into xtermish case for multiplexer recursion

        $terminal    = 'Windows Terminal';
        $italic      = True;
        $color3bit   = True;
        $color8bit   = True;
        $color24bit  = True;
        $colorbright = True;
        $vt100-boxes = True;
        $half-blocks = True;

        if $has-utf8 {
            $symbol-set  = symbol-set('Uni7');
            $braille     = True;
            $quadrants   = True;
            $emoji-color = True;
            $emoji-skin  = True;
            $emoji-zwj   = True;
        }
    }
    elsif $term eq 'mlterm' {
        # mlterm sets COLORTERM=truecolor, detected above
        $terminal = $term;
        $version  = %*ENV<MLTERM>;
        $italic   = True;

        if $has-utf8 {
            $symbol-set = symbol-set('Uni3');
            $braille    = True;
            $quadrants  = True;
            $sextants   = True;
            $emoji-text = True;
        }
    }
    elsif $term eq 'Eterm' {
        # XXXX: TO UPDATE
        $terminal    = $term;
        $symbol-set  = symbol-set('ASCII');
        $vt100-boxes = False;
        $color3bit   = True;
        $colorbright = True;
        $color8bit   = True;
    }
    elsif $term eq 'st'|'st-256color' {
        $terminal    = 'st';
        $italic      = True;
        $color3bit   = True;
        $colorbright = True;
        $color8bit   = True;
        $color24bit  = True;

        if $has-utf8 {
            $symbol-set = symbol-set('Uni7');
            $braille    = True;
            $emoji-text = True;
        }
    }
    elsif ?$term.starts-with('rxvt'|'urxvt') {
        # rxvt maps colors back to its own 88- or 256-color palette, thus not
        # really supporting standard colors, even though rxvt parses and seems
        # to apply them.  We'll assume for now that rxvt will only add the
        # '-256color' suffix to TERM if it is *actually* using 256 colors.

        $terminal    = 'rxvt';
        $italic      = True;
        $color3bit   = True;
        $colorbright = True;

        if $has-utf8 {
            $symbol-set = symbol-set('Uni3');
            $quadrants  = True;
            $braille    = True;
        }
    }
    elsif ?$term.starts-with('vt220'|'vt420')
       || ?$term.lc.contains('color'|'ansi'|'cygwin'|'linux') {
        $terminal  = $term;
        $color3bit = True;
    }

    my $caps = Terminal::Capabilities.new:
        :$symbol-set,    :$italic,
        :$color3bit,     :$colorbright,  :$color8bit,  :$color24bit,
        :$emoji-text,    :$emoji-color,  :$emoji-skin,
        :$emoji-iso,     :$emoji-reg,    :$emoji-zwj,
        :$vt100-boxes,   :$half-blocks,  :$braille,
        :$quadrants,     :$sextants,     :$octants,
        :$sep-quadrants, :$sep-sextants;

    ($caps, $terminal, $version)
}
