#########################################################################
# Copyright (c) 1999 SuSE Gmbh Nuernberg, Germany.  All rights reserved.
#
# Author  : Uwe Gansert <ug@suse.de>
# License : GPL, see LICENSE File for further information
package Paw::Paw_label;
use Curses;

@ISA = qw(Exporter);
@ISA=qw(Paw_base);
@EXPORT = qw();
$Paw::VERSION = "0.45";

=head1 Label Widget

B<$label=Paw::Paw_label->new($text, [$color], [$name]);>

B<Example>

     $label=Paw::Paw_label->new(text=>"Text", color=>3, name=>"Linux_Label");

B<Parameter>

     text  => Text of the label

     color => The colorpair must be generated with
              Curses::init_pair(pair_nr, COLOR_fg, COLOR_bg)
              [optionally]

     name  => Name of the widget [optionally]

=head2 set_text($text)

Change the text of the label to the string $text.

B<Example>

     $label->set_text("changed label text");

=head2 get_text();

returns the label-text.

B<Example>

     $text=$label->get_text();

=head2 abs_move_widget($new_x, $new_y)

the widget moves to the new absolute screen position.
if you set only one of the two parameters, the other one keeps the old value.

B<Example>

     $label->abs_move_widget( new_x=>5 );      #y-pos is the same

=head2 get_widget_pos()

returns an array of two values, the x-position and the y-position of the widget.

B<Example>

     ($xpos,$ypos)=$label->get_widget_pos();      #y-pos is the same

=head2 set_color($color_pair)

Set a new color_pair for the widget.

B<Example>

     $box->set_color(3);


=cut

sub new {
    my $class  = shift;
    my $this   = Paw_base->new_widget_base;
    my %params = @_;
    
    $this->{name} = (defined $params{name})?($params{name}):("_auto_"."label");    #Name des Fensters (nicht Titel)
    $this->{text} = $params{text};;
    $this->{rows} = 1;
    $this->{direction} = "h";
    $this->{type} = "label";
    $this->{color_pair} = (defined $params{color})?($params{color}):(0);
    
    bless ($this, $class);
    $this->{cols} = length $this->{text};
    return $this;
};

sub draw {
    my $this = shift;
    $this->{color_pair} = $this->{parent}->{color_pair} if ( not defined $this->{color_pair} );

    $this->{cols}=length $this->{text};
    attron(COLOR_PAIR( $this->{color_pair} ) );
    addstr($this->{text});
}

sub set_text {
    my $this = shift;
    my @box  = ();
    my $old  = $this->{text};
    $this->{text} = $_[0];

    #    if ( length $this->{text} < length $old ) {
    #    $this->{text} = $_[0] . (" "x(length $old-length $this->{text}));
    #    $this->{parent}->_refresh($this);
    #}
    #else {
    $this->{parent}->_refresh($this);
    #}
    $this->{cols} = length $this->{text};
}

sub get_text {
    my $this = shift;
    
    return $this->{text};
}
return 1;
