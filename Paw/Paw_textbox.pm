#########################################################################
# Copyright (c) 1999 SuSE Gmbh Nuernberg, Germany.  All rights reserved.
#
# Author  : Uwe Gansert <ug@suse.de>
# License : GPL, see LICENSE File for further information
package Paw::Paw_textbox;
use Curses;

@ISA = qw(Exporter Paw_base);
@EXPORT = qw(
);
$Paw::VERSION = "0.41";


=head1 Textbox

B<$popup=Paw::Paw_textbox->new($height, $width, \@data, [$name]);>

B<Parameter>

     $height => number of rows

     $width  => number of columns

     \@data  => reference to an array that contains the text
                (each element for each paragraph).

B<Example>

     @data=("This is free software with ABSOLUTELY NO WARRANTY.",
            "Copyright (C) 1999 Free Software Foundation, Inc.");
     $pu=Paw::Paw_textbox->new(height=>20, width=>20, data=>\@data);

=cut

sub new {
    my $class  = shift;
    my $this   = Paw_base->new_widget_base();
    my %params = @_;

    my %cursor;
    $cursor{rcx}=0;
    $cursor{rcy}=0;
    $cursor{vcx}=0;
    $cursor{vcy}=0;

    my @line_length=();
    
    $this->{data}        = $params{data};
    $this->{name}      = (defined $params{name})?($params{name}):("_auto_"."textbox");    #Name des Fensters (nicht Titel)
    $this->{rows}        = $params{height};
    $this->{cols}        = $params{width};
    $this->{wordwrap}    = (defined $params{wordwrap})?($params{wordwrap}):(1);
    $this->{direction}   = "v";
    $this->{act_able}    = 0;
    $this->{type}        = "text_box";
    $this->{line_length} = \@line_length;
    $this->{view_start_y}= 0;
    $this->{view_start_x}= 0;
    $this->{used_rows}   = 0;
    $this->{cursor}      = \%cursor;
    $this->{active_row}  = 0;
    $this->{edit_able}   = 1;
    
    bless ($this, $class);

    return $this;
}

sub draw {
    my $this   = shift;
    my $print_line = shift;
    my @box    = ();
    my $i      = 0;
    my $k      = 0;
    my $breite = $this->{cols}+1;
    my $refer  = $this->{data};
    my $line;
    my $vs     = $this->{view_start_y};
    $this->{color_pair} = $this->{parent}->{color_pair};
    
    $this->{used_rows} = 0;
    @{$this->{line_length}} = ();

    if ( ref($refer) eq "SCALAR" and $this->{wordwrap} ) {
        my $data  = ${$refer};
        $data =~ s/\s/ /m;                    #kill WS
        while ( (length $data) > $breite ) {
            my $line = $data;
            $line =~ s/(.{$breite})(.*)/$1/;
            $line =~ s/(.*)( .*$)/$1/;
            if ( ($this->{used_rows} >= $vs) and ($this->{used_rows} < ($vs+$this->{rows}))  ) {
                $box[$k++]=$line;
            }
            $data=substr $data,(length $line)+1;
            push (@{$this->{line_length}}, (length($line)-1) );
            $this->{used_rows}++;
        }
        if ( $this->{used_rows} >= $vs and $this->{used_rows} <= ($vs+$this->{rows}-1) ) {
            $box[$k++]=$data;
        }
        $this->{used_rows}++;
        push (@{$this->{line_length}}, (length($data)-1) );
    }
    elsif ( ref($this->{data}) eq "ARRAY" and $this->{wordwrap} ) {
        my @data = @{$refer};
        my $anz = @data;
        my $j = 0;
        for ( $i=0; $i<$anz; $i++ ) {
            $data[$i] =~ s/\s/ /m;                    #kill WS
            while ( (length($data[$i])) > $breite ) {
                my $line = $data[$i];
                $line =~ s/(.{$breite})(.*)/$1/;
                $line =~ s/(.* )(.*$)/$1/;
                if ( ($this->{used_rows} >= $vs) and ($this->{used_rows} < ($vs+$this->{rows}))  ) {
                    $box[$k++]=$line;
                }
                $data[$i]=substr $data[$i],(length $line);
                push (@{$this->{line_length}}, (length($line)-1) );
                $this->{used_rows}++;
            }
            if ( $this->{used_rows} >= $vs and $this->{used_rows} <= ($vs+$this->{rows}-1) ) {
                $box[$k++]=$data[$i];
            }
            push (@{$this->{line_length}}, (length($data[$i])-1) );
            $this->{used_rows}++;
        }
    }
    elsif ( ref($refer) eq "SCALAR" ) {
        my $data = $$refer;
        $breite-=1;
        my $vsx=$this->{view_start_x};
        $data =~ s/(.{$vsx})(.{$breite})(.*)/$2/;
        $box[0]=$data;
        $this->{used_rows}=1;
        push (@{$this->{line_length}}, (length($data)-1) );
    }
    elsif ( ref($refer) eq "ARRAY" ) {
        $breite--;
        my $i=$print_line;
        #for ( my $i=0; $i < @{$refer}; $i++ ) {
        for ( my $i=0; $i < $this->{rows}; $i++ ) {
            my $data = @{$refer}->[$i+$this->{view_start_y}];
            my $vsx=$this->{view_start_x};
            push (@{$this->{line_length}}, (length($data)-1) );
            #$data =~ s/(.{$vsx})(.{$breite})(.*)/$2/;
            #$data = substr $data, $vsx,$breite if ( length($data) > $vsx );
            $data=(length($data) > $vsx)?(substr $data, $vsx,$breite):("");
            $box[$i]=$data;
            $this->{used_rows}++;
        }
    }
    for ( my $i=$this->{used_rows}+1; $i<($this->{rows}); $i++) {
        $box[$i]="";
    }
    if ( $this->{cursor}->{rcy} == $print_line ) {
        for ( my $i=0; $i<length($box[$print_line]); $i++ ) {
            ( $i==$this->{cursor}->{rcx} )?(attron(A_REVERSE)):(attroff(A_REVERSE));
            my $dummy=substr($box[$print_line], $i, 1);
            addch( $dummy );
        }
        addstr (" "x($this->{cols}-length($box[$print_line])));
    }
    else {
        addstr($box[$print_line].(" "x($this->{cols}-length($box[$print_line])))) if defined $box[$print_line];
    }
    addstr(" "x$this->{cols}) if not defined $box[$print_line];
}

sub key_press {
    my $this = shift;
    my $key  = shift;
    my $rcx  = $this->{cursor}->{rcx};
    my $rcy  = $this->{cursor}->{rcy};
    my $vcx  = $this->{cursor}->{vcx};
    my $vcy  = $this->{cursor}->{vcy};
    my $data = $this->{data};
    my $vsy  = $this->{view_start_y};
    my $vsx  = $this->{view_start_x};
    my $ll   = $this->{line_length};

    $vcx = 0 if ( not defined $vcx );
    $rcx = 0 if ( not defined $rcx );
    $vcy = 0 if ( not defined $vcy );
    $rcy = 0 if ( not defined $rcy );
    $vs  = 0 if ( not defined $vs);

    $key = "" if ( not defined $key );
    while ( $key ne "\t" and $key ne "\n" ) {
        if ( $this->{wordwrap} and ref($data) eq "ARRAY" ) {
            if ( $key eq KEY_RIGHT ) {
                $key = "";
                # 2 and 3
                if ( $rcx == ($ll->[$vsy+$rcy]) ) {
                    $vsy++ if ( $rcy == $this->{rows}-1 and $vsy+$rcy<$this->{used_rows}-1 ); #bottom ?
                    $rcy++ if ( $rcy < $this->{rows}-1 );  #
                    # 2
                    if ( $vcx < length($data->[$vcy])-1 ) {
                        print STDERR "Fall 2\n";
                        $vcx++;
                        $rcx=0;
                    }
                    # 3
                    else {
                        print STDERR "Fall 3\n";
                        $rcx=0;
                        $vcx=0;
                        $vcy++ if ( $vsy+$rcy < $this->{used_rows}-1 );
                    }
                }
                # 1
                else {
                    $rcx++;
                    $vcx++;
                }
            }
            elsif ( $key eq KEY_LEFT ) {
                $key = "";
                # 5 and 6
                if ( $rcx == 0 ) {
                    # 5
                    if ( $vcx > 0 ) {
                        print STDERR "Fall 5\n";
                        $vsy-- if ( not $rcy and $vcy );
                        $rcy-- if ( $rcy );
                        $vcx--;
                        $rcx=$ll->[$vsy+$rcy];
                    }
                    # 6
                    else {
                        print STDERR "Fall 6\n";
                        $vsy-- if ( not $rcy and $vcy );
                        $rcy-- if ( $rcy );
                        $vcy-- if ( $vcy );
                        $vcx=length($data->[$vcy])-1;
                        $rcx=$ll->[$vsy+$rcy];
                    }
                }
                # 4
                else {
                    $rcx--;
                    $vcx--;
                }
            }
            elsif ( $key eq KEY_DOWN ) {
                $key = "";
                #8 and 9
                if ( defined $ll->[$rcy+$vsy+1] and $ll->[$rcy+$vsy+1] < $rcx ) {
                    # 8 - hope this works
                    my $dummy = $vcx+($ll->[$vsy+$rcy]-$rcx);
                    if ( length($data->[$vcy]) >= $dummy ) {
                        print STDERR "Fall 8\n";
                        $vcx+=$ll->[$vsy+$rcy]-$rcx+1;
                        $vsy++ if ( $rcy == $this->{rows}-1 and $vsy+$rcy < $this->{used_rows}-1 ); #bottom ?
                        $rcy++ if ( $rcy < $this->{rows}-1 );
                        $rcx=$ll->[$vsy+$rcy];
                        $vcx+=$rcx;
                    }
                    # 9
                    else {
                        print STDERR "Fall 9\n";
                        $vsy++ if ( $rcy == $this->{rows}-1 and $vsy+$rcy < $this->{used_rows}-1 ); #bottom ?
                        $vcy++ if ( $vsy+$rcy < $this->{used_rows}-1 );
                        $rcx=$ll->[$vsy+$rcy];
                        $vcx=$rcx;
                        $rcy++ if ( $rcy < $this->{rows}-1 );
                    }
                }
                #7 and 10
                else {
                    # 7
                    if ( length($data->[$vcy]) > ($vcx+$ll->[$vsy+$rcy]+1) ) {
                        print STDERR "Fall 7\n";
                        $vcx+=$ll->[$vsy+$rcy]+1;
                        $vsy++ if ( $rcy == $this->{rows}-1 and $vsy+$rcy < $this->{used_rows}-1 ); #bottom ?
                        $rcy++ if ( $rcy < $this->{rows}-1 );;
                    }
                    # 10
                    else {
                        print STDERR "Fall 10\n";
                        $vsy++ if ( $rcy == $this->{rows}-1 and $vsy+$rcy < $this->{used_rows}-1 ); #bottom ?
                        $vcy++ if ( $vsy+$rcy < $this->{used_rows}-1 );
                        $vcx=$rcx;
                        $rcy++ if ( $rcy < $this->{rows}-1 );;
                    }
                }
            }
            elsif ( $key eq KEY_UP ) {
                $key = "";
                # 12 and 13
                if ( defined $ll->[$rcy+$vsy-1] and $rcx > $ll->[$rcy+$vsy-1] ) {
                    $vsy-- if ( not $rcy and $vcy );
                    # 12
                    if ( $vcx > $rcx ) {
                        print STDERR "Fall 12\n";
                        $vcx-=$rcx;
                        $rcy-- if ( $rcy );
                        $rcx=$ll->[$rcy+$vsy];
                        $vcx-=($ll->[$rcy+$vsy]-$rcx)+1;
                    }
                    # 13
                    else {
                        print STDERR "Fall 13\n";
                        $vcy-- if ( $vcy );;
                        $rcy-- if ( $rcy );
                        $vcx=$ll->[$rcy+$vsy];
                        $rcx=$vcx;
                    }
                }
                # 11 and 14
                else {
                    $vsy-- if ( not $rcy and $vcy );
                    # 14
                    if ( $rcx == $vcx ) {
                        print STDERR "Fall 14\n";
                        $vcy-- if ( $vcy );;
                        $rcy-- if ( $rcy );
                        $vcx = length ( $data->[$vcy] )-1;
                        $vcx -= $ll->[$rcy+$vsy]-$rcx;
                    }
                    # 11
                    else {
                        print STDERR "Fall 11\n";
                        $rcy-- if ( $rcy );
                        $vcx-=$ll->[$rcy+$vsy]+1;   #alles scheisse.
                    }
                }
            }
        }
        elsif ( not $this->{wordwrap} and ref($data) eq "ARRAY" ) {
            if ( $key eq KEY_RIGHT ) {
                $key = "";
                # 2
                if ( $vcx == ($ll->[$vsy+$rcy]) ) {
                    $vsx=0;
                    $rcy++ if ( $rcy < $this->{rows}-1 );  #
                    $vcx=0;
                    $rcx=0;
                    $vcy++ if ( $vsy+$rcy < $this->{used_rows} );
                }
                # 1
                else {
                    $vsy++ if ( $rcy == $this->{rows}-1 and $vsy+$rcy<$this->{used_rows}-1 ); #bottom ?
                    $vsx++ if ( $rcx == $this->{cols} );
                    $rcx++ if ( $rcx < $this->{cols} );
                    $vcx++;
                }
            }
            elsif ( $key eq KEY_LEFT ) {
                $key = "";
                # 4
                if ( $vcx == 0 ) {
                    $vsy-- if ( not $rcy and $vcy );
                    $rcy-- if ( $rcy );
                    $vcy-- if ( $vcy );
                    $vcx=length($data->[$vcy])-1;
                    $rcx=($vcx>$this->{cols})?($this->{cols}):($vcx);
                    $vsx = $vcx-$this->{cols};
                    $vsx = 0 if ( $vsx < 0 );
                }
                # 3
                else {
                    $vsx-- if ( not $rcx );
                    $rcx-- if ( $rcx );
                    $vcx--;
                }
            }
            elsif ( $key eq KEY_DOWN ) {
                $key = "";
                # 6
                if ( defined $data->[$vcy+1] and length($data->[$vcy+1]) < $vcx ) {
                    $vsy++ if ( $rcy==$this->{rows} and $vcy<$this->{used_rows} );
                    $rcy++ if ( $rcy < $this->{rows} );
                    $vcy++;
                    $rcx=length($data->[$vcy]);
                    $vcx=$rcx;
                }
                # 5
                elsif ( defined $data->[$vcy+1] ) {
                    $vsy++ if ( $rcy==$this->{rows} and $vcy<$this->{used_rows} );
                    $rcy++ if ( $rcy < $this->{rows} );
                    $vcy++;
                }
            }
            elsif ( $key eq KEY_UP ) {
                $key = "";
                # 8
                if ( defined $data->[$vcy-1] and length($data->[$vcy-1])<$vcx ) {
                    $vsy-- if ( not $rcy and $vsy );
                    $rcy-- if ( $rcy );
                    $vcy-- if ( $vcy );
                    $rcx=length($data->[$vcy])-1;
                    $vcx=$rcx;
                    $vsx=($vcx>$this->{cols})?($vcx-$this->{cols}):(0);
                }
                # 7
                elsif ( defined $data->[$vcy-1] ) {
                    $vsy-- if ( not $rcy and $vsy );
                    $vcy--;
                    $rcy-- if ( $rcy );
                }
            }
        }
        $this->{active_row}    = $vsy+$rcy;
        $this->{view_start_y}  = $vsy;
        $this->{view_start_x}  = $vsx;
        $this->{cursor}->{vcx} = $vcx;
        $this->{cursor}->{rcx} = $rcx;
        $this->{cursor}->{vcy} = $vcy;
        $this->{cursor}->{rcy} = $rcy;
        $this->{string} = $new_string;
        $this->{parent}->_refresh();
        print STDERR "rcx=$rcx rcy=$rcy vcx=$vcx vcy=$vcy vsx=$this->{view_start_x} vsy=$this->{view_start_y} ur=$this->{used_rows}\n";
        $key = getch();
    }
    if ( $key eq "\t" ) {
        $this->{parent}->next_active();
    }
}


return 1;
