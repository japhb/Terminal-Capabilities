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

    my Bool:D $vt100-boxes = $symbol-set >= Terminal::Capabilities::SymbolSet::WGL4R;
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

    my $xtermish = $term.starts-with('xterm');
    if $xtermish {
        $vt100-boxes = True;
        $color3bit   = True;

        if $term eq 'xterm-kitty' {
            $terminal     = 'kitty';
            $symbol-set   = symbol-set('Full') if $has-utf8;
            $italic       = True;
            $color24bit   = True;
            $color8bit    = True;
            $emoji-text   = True;
            $emoji-color  = True;
            $emoji-skin   = True;
            $emoji-iso    = True;
            $emoji-zwj    = True;
        }
        elsif %*ENV<VTE_VERSION> -> $v {
            $terminal     = 'VTE';
            $version      = $v;
            $symbol-set   = symbol-set('Uni7') if $has-utf8;
            $italic       = True;
            $emoji-text   = True;
            $emoji-color  = True;
            $emoji-reg    = True;

            # XXXX: Mixed among VTEs:
            #     True  for gnome-terminal, mate-terminal, tilix, xfce4-terminal
            #     False for others
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
        }
        elsif %*ENV<ZUTTY_VERSION> -> $v {
            $terminal    = 'Zutty';
            $version     = $v;
            $colorbright = True;
        }
        elsif %*ENV<TERM_PROGRAM> -> $prog {
            $terminal     = $prog;
            $version      = %*ENV<TERM_PROGRAM_VERSION>;

            if %*ENV<TERMINOLOGY> {
                $italic       = True;
                $colorbright  = True;
                $color8bit    = True;
                $emoji-text   = True;
            }
            elsif $prog eq 'ghostty' {
                # Ghostty sets COLORTERM=truecolor, detected above

                $italic       = True;
                $emoji-text   = True;
                $emoji-color  = True;
                $emoji-skin   = True;
                $emoji-iso    = True;
                $emoji-reg    = True;
                $emoji-zwj    = True;
            }
            elsif $prog eq 'iTerm.app' {
                $italic       = True;
                $color8bit    = True;
                $color24bit ||= ($version // '').split('.')[0] >= 3;
                $emoji-color  = True;
                $emoji-skin   = True;
                $emoji-iso    = True;
                $emoji-reg    = True;
                $emoji-zwj    = True;
            }
            elsif $prog eq 'Apple_Terminal' {
                $color8bit    = True;
            }
        }
        elsif %*ENV<ALACRITTY_WINDOW_ID> {
            $terminal     = 'Alacritty';
            $italic       = True;
            $emoji-text   = True;
        }
        elsif %*ENV<KONSOLE_DBUS_SERVICE> {
            $terminal     = 'Konsole';
            $italic       = True;
            $emoji-text   = True;
        }
        elsif %*ENV<COLORSCHEMES_DIR> {
            $terminal     = 'CRT';  # AKA QMLTermWidget
            $italic       = True;
            $emoji-text   = True;
        }
        elsif %*ENV<QT_SCALE_FACTOR_ROUNDING_POLICY> {
            $terminal     = 'Qt';  # Deepin, QTerminal
            $italic       = True;
            $emoji-text   = True;
        }
        else {
            $terminal = 'xtermish';

            # Known to hit this branch:
            #    pterm
        }
    }
    elsif $term eq 'mlterm' {
        $terminal    = $term;
        $version     = %*ENV<MLTERM>;
        $italic      = True;
        $color3bit   = True;
        $colorbright = True;
        $color8bit   = True;
        $color24bit  = True;
        $emoji-text  = True;
    }
    elsif $term eq 'Eterm' {
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
        $emoji-text  = True;
    }
    elsif ?$term.starts-with('rxvt') {
        $terminal    = 'rxvt';
        $italic      = True;
        $color3bit   = True;
        $colorbright = True;
        $color8bit   = True;
    }
    elsif ?$term.starts-with('tmux') {
        $terminal    = 'tmux';
        $version     = %*ENV<TERM_PROGRAM_VERSION>;

        # XXXX: Limited by symbol-set of underlying terminal emulator too
        $symbol-set  = symbol-set('Full') if $has-utf8;

        # XXXX: Detection of underlying terminal emulator to AND with these?
        $italic      = True;
        $emoji-text  = True;
        $emoji-color = True;
        $emoji-skin  = True;
        $emoji-iso   = True;
        $emoji-reg   = False;
        $emoji-zwj   = False;
    }
    elsif ?$term.starts-with('screen'|'vt220'|'vt420')
       || ?$term.lc.contains('color'|'ansi'|'cygwin'|'linux') {
        $terminal    = $term;
        $color3bit   = True;
    }

    my $caps = Terminal::Capabilities.new:
        :$symbol-set, :$vt100-boxes, :$italic,
        :$color3bit,  :$colorbright, :$color8bit, :$color24bit,
        :$emoji-text, :$emoji-color, :$emoji-skin,
        :$emoji-iso,  :$emoji-reg,   :$emoji-zwj;

    ($caps, $terminal, $version)
}
