#########################################################################
# Copyright (c) 1999 SuSE Gmbh Nuernberg, Germany.  All rights reserved.
#
# Author  : Uwe Gansert <ug@suse.de>
# License : GPL, see LICENSE File for further information
package Paw::Paw_line;
use Curses;

@ISA = qw(Exporter Paw_base);
@EXPORT = qw();
$Paw::VERSION = "0.41";

=head1 Line Widget

B<$line=Paw::Paw_line->new($length, [$name], [$char], [$direction])>;

B<Parameter>

     $name      => name of the widget [optionally]

     $char      => character that will be used to build the line
                   (ACS_HLINE) [optionally]

     $direction => "v"ertically or "h"orizontally (default) [optional]

     $length    => length in characters of the line

B<Example>

     $l=Paw::Paw_line->new(length=>$columns, char=>"#");

=cut

sub new {
    my $class  = shift;
    my $this   = Paw_base->new_widget_base;
    my %params = @_;

    $this->{name}        = (defined $params{name})?($params{name}):("_auto_"."line");    #Name des Fensters (nicht Titel)
    $this->{cols}        = 1;
    $this->{rows}        = 1;
    $this->{char}        = (defined $params{char})?($params{char}):(ACS_HLINE);
    $this->{size}        = $params{length};
    $this->{direction}   = (defined $params{direction})?($params{direction}):("h");
    $this->{type}        = "line";
    $this->{print_style} = "char";
    
    bless ($this, $class);
    ( $this->{direction} eq "v" ) ? ($this->{rows}=$this->{size}):($this->{cols}=$this->{size});
    return $this;
}

sub draw {
    my $this    = shift;
    my $line    = shift;
    $this->{color_pair} = $this->{parent}->{color_pair} if ( not defined $this->{color_pair} );
    attron(COLOR_PAIR($this->{color_pair}));
    
    if ( $this->{direction} eq "h" ) {
        for ( my $i=0; $i<$this->{size}; $i++ ) {
            addch( $this->{char} );
        }
    }
    else {
        addch($this->{char});
    }
}
return 1;
