#########################################################################
# Copyright (c) 1999 SuSE Gmbh Nuernberg, Germany.  All rights reserved.
#
# Author  : Uwe Gansert <ug@suse.de>
# License : GPL, see LICENSE File for further information
package Paw::Paw_text_entry;
use Curses;

@ISA = qw(Exporter Paw_base);
@EXPORT = qw(
);
$Paw::VERSION = "0.41";

=head1 Textentry Widget

B<$te=Paw::Paw_text_entry->new($width, [$color], [$name], [\&callback], [$text], [$side], [$echo], [$max_length]);>

B<Parameter>

     width      => width of the text-entry (in other words: columns)

     color      => the colorpair must be generated with
                   Curses::init_pair(pair_nr, COLOR_fg, COLOR_bg)
                   [optionally]

     name       => name of the widget [optionally]

     callback   => reference to the function that will be
                   executed each time you press a key in the entry.
                   [optionally]

     text       => default text for the entry [optionally]

     orientation=> "left"(default) or "right"
                   for left/right-justified text.

     echo       => 0, 1  oder 2 : 0=no echo of the entered text,
                   1=Stars instead of characters, 2=full echo (default)
                   (0 and 1 good for passwords) [optional]

     max_length=> maximum length of the entry (default = 1024)

B<Example>

     $te=Paw::Paw_text_entry->new(width=>15, text=>"PLEASE ENTER NAME",
                                  max_length=>25); 

B<Callback>

The callback function will be started each time you press a key in the text-entry.
The key value will be given to the callback too. This will give you the chance to allow
only digits or whatever you want. You B<must> return the key-value or no text will ever
reach into the widget.

=head2 get_text()

returns the text of the entry.

B<Example>

     $text=$te->get_text();

=head2 set_text($text)

set the text in the entry to $text.

B<Example>

     $te->set_text("default");

=cut


sub new {
    my $class  = shift;
    my $this   = Paw_base->new_widget_base;
    my %params = @_;
    my %cursor;

    $this->{name}        = (defined $params{name})?($params{name}):("_auto_"."entry");    #Name des Fensters (nicht Titel)
    $this->{string}      = (defined $params{text})?($params{text}):("");
    $this->{cols}        = $params{width};
    $this->{side}        = (defined $params{orientation})?($params{orientation}):("left");
    $this->{echo}        = (defined $params{echo})?($params{echo}):(2);
    $this->{max_length}  = (defined $params{max_length})?($params{max_length}):(1024);
    $this->{color_pair}  = (defined $params{color})?($params{color}):();
    $this->{act_able}    = 1;
    $this->{rows}        = 1;
    $this->{type}        = "text_entry";
    $this->{print_style} = "char";
    $this->{callback}    = $params{callback};
    
    $this->{cursor}   = \%cursor;

    bless ($this, $class);
    $this->{cursor}->{rcx} = ( $this->{side} eq "right" )?($this->{cols}):0;
    $this->{cursor}->{vcx} = length $this->{string} if ( $this->{side} eq "right" );
    $this->{cursor}->{rcy} = 0;
    $this->{cursor}->{vcy} = 0;

    return $this;
}

sub draw {
    my $this    = shift;
    my $str_len = ($this->{string})?(length $this->{string}):(0);
    my $dummy   = $this->{string};
    my $vcx     = $this->{cursor}->{vcx};
    my $rcx     = $this->{cursor}->{rcx};
    $this->{color_pair} = $this->{parent}->{color_pair} if ( not defined $this->{color_pair} );

    $vcx = 0 if ( not $vcx );

    #$this->{string} = $dummy         if ( $this->{echo} == 2 );
    $this->{string} = "*" x $str_len if ( $this->{echo} == 1 );
    $this->{string} = "HIDDEN"       if ( $this->{echo} == 0 );

    # bei Breite  == 0 wird die Breite des Parent Widgets genommen
    if ( $this->{cols} == 0 ) {
        $this->{cols} = $this->{parent}->{cols}-$this->{wx};
    }
    # Text Entry aktiv und String ist groesser als Text Entry ?
    if ( $this->{is_act} and ($str_len >= $this->{cols}) ) {
        if ( $vcx+$this->{cols} < $str_len and $rcx == 0 ) {
            $this->{text}=substr($this->{string}, $vcx, $vcx+$this->{cols});
        }
        elsif ( $this->{cols} <= $str_len and $rcx <= $this->{cols} ) {
            $this->{text}=substr($this->{string}, $vcx-$rcx, $vcx-$rcx+$this->{cols});
        }
    }
    # Text Entry NICHT aktiv und String ist groesser als Text Entry ?
    elsif ( $str_len > $this->{cols} ) {
        $this->{text}=substr $this->{string}, 0, $this->{cols};
    }
    # String passt ins Text Entry evtl. sogar kleiner
    else {
        if ( $this->{side} eq "left" ) {
            if ( $rcx == 0 and $vcx == 0 ) {
                $this->{text}=$this->{string} . ( "_" x ( $this->{cols}-$str_len) );
            }
            else {
                $this->{text}=substr $this->{string}, $vcx-$rcx;
            }
        }
        elsif ( $this->{side} eq "right" ) {
            $this->{text}=( "_" x ( $this->{cols}-$str_len ) . $this->{string} );
        }
    }
    if (length $this->{text} < $this->{cols} ) {
        $this->{text}.= ( "_" x ( $this->{cols}-length $this->{text}) );
    }
    if ( $this->{side} eq "right" and $vcx<$rcx ) {
        $this->{text}=( "_" x ( $rcx-$vcx ) . $this->{string} );
    }
    $this->{string}=$dummy;
    attron(COLOR_PAIR($this->{color_pair}));
    if ( $this->{is_act} ) {
        for ( my $i=0; $i<$this->{cols}; $i++ ) {
            attroff(A_REVERSE) if ( $this->{cursor}->{rcx} == $i );
            my $subst=substr($this->{text}, $i, 1);
            addch( $subst  );
            attron(A_REVERSE);
        }
    }
    else {
        addstr($this->{text});
    }
    return;
}

sub get_text {
    my $this = shift;

    return ( $this->{string} );
}

sub set_text {
    my $this = shift;

    if ( length $_[0] < length $this->{string} ) {
        $this->{cursor}->{rcx} = 0;
        $this->{cursor}->{vcx} = 0;
    }
    $this->{string} = $_[0];
    #$this->{parent}->_refresh();
}

sub key_press {
    my $this = shift;
    my $key  = shift;
    my $vcx  = $this->{cursor}->{vcx};
    my $rcx  = $this->{cursor}->{rcx};

    $vcx = 0 if ( not $vcx );

    $key = "" if ( not $key );
    my $new_string = $this->{string};
    $key=&{$this->{callback}}($key) if ( defined $this->{callback} );
    while ( $key ne KEY_UP and $key ne KEY_DOWN and $key ne "\t" and $key ne "\n") {
        if ( $key eq KEY_BACKSPACE ) {
            $key = "";
            $new_string = ( substr($new_string,0,$vcx-1) . substr($new_string,$vcx) ) if ( $vcx );
            $vcx-- if ( $vcx > 0 );
            $rcx-- if ( $rcx > 0 and $this->{side} eq "left" );
        }
        elsif ( $key eq KEY_DC ) {
            $key = "";
            if ( $vcx < length($new_string) ) {
                $new_string = ( substr($new_string,0,$vcx) . substr($new_string,$vcx+1) );
            }
            $rcx++ if ($rcx < $this->{cols} and $this->{side} eq "right");
        }
        elsif ( $key eq KEY_LEFT ) {
            $key = "";
            $vcx-- if ( $vcx > 0 );
            $rcx-- if (
                       ($rcx > 0 and $this->{side} eq "left") or
                       ($rcx > $this->{cols}-length $new_string and $this->{side} eq "right" and $rcx > 0)
                      );
        }
        elsif ( $key eq KEY_RIGHT ) {
            $key = "";
            $vcx++ if ( $vcx < length $new_string );
            $rcx++ if ( $rcx < $this->{cols} and ( $rcx < length $new_string or $this->{side} eq "right" ) );
        }
        # special keys.
        elsif ( length($key) > 1 ) {
            return $key;
        }
        if ( length $new_string < $this->{max_length} ) {
            $new_string = ( substr($new_string,0,$vcx) . $key . substr($new_string,$vcx) );
            if ( $this->{side} eq "right" ) {
                $vcx += length $key;
            }
            else {
                $rcx += length $key if ( $rcx < $this->{cols} );
                $vcx += length $key;
            }
        }
        $this->{cursor}->{vcx} = $vcx;
        $this->{cursor}->{rcx} = $rcx;
        $this->{string} = $new_string;
        $this->{parent}->_refresh();
        $key = getch();
        $key = "" if $key eq -1;  #kill the -1 or the "0" will not work ?-(
        $key=&{$this->{callback}}($key) if ( defined $this->{callback} );
    }
    $this->{parent}->next_active() if ( $key eq "\n" );
    return $key;
}
return 1;
