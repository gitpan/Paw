#########################################################################
# Copyright (c) 1999 SuSE Gmbh Nuernberg, Germany.  All rights reserved.
#
# Author  : Uwe Gansert <ug@suse.de>
# License : GPL, see LICENSE File for further information
package Paw::Paw_popup;
use Curses;
use Paw::Paw_button;
use Paw::Paw_textbox;
use Paw::Paw_window;

@ISA = qw(Exporter Paw_base);
@EXPORT = qw();
$Paw::VERSION = "0.41";

=head1 Popup Window

B<$popup=Paw::Paw_popup->new($height, $width, \@buttons, \@text, [$name]);>

B<Parameter>

     $height   => number of rows

     $width    => number of columns

     $name     => name of the widget [optionally]

     \@buttons => an array of strings for the labels on the buttons
                  in the box.

     \@text    => an array of strings for the Text.
                  Each arrayelement for each paragraph.

B<Example>

     @butt=("Okay", "Cancel");
     @text=("Don't you really not want to continue ?");
     $pu=Paw_popup::new(height=>20, width=>20,
                        buttons=>\@butt, text=>\@text);

If a button is pressed, the box closes and the number of the button is returned (beginning by 0). 

=head2 draw();

raises the popup-window, returns the number of the pushed button.

B<Example>

     $button=$pu->draw();

=cut

sub new {
    my $class  = shift;
    my $this   = Paw_base->new_widget_base;
    my %params = @_;
    my $window = 0;
    my $textbox= 0;
    my @buttons= ();
    my $cb     = \&_callback;

    $this->{name}      = (defined $params{name})?($params{name}):("_auto_"."popup");    #Name des Fensters (nicht Titel)
    $this->{cols}    = $params{width};
    $this->{rows}    = $params{height};
    $this->{buttons} = $params{buttons};
    $this->{text}    = $params{text};
    bless ($this, $class);

    $window = Paw::Paw_window->new( abs_x=>($this->{screen_cols}-$this->{cols})/2, abs_y=>($this->{screen_rows}-$this->{rows})/2, callback=>$cb, height=>$this->{rows}, width=>$this->{cols} );
    $window->set_border("shade");
    $textbox = Paw::Paw_textbox->new( data=>\@{$params{text}}, width=>$params{width}-2, height=>($params{height}-5), wordwrap=>1 );
    $textbox->{act_able}=0;
    $textbox->set_border();
    $window->abs_move_curs(new_y=>1); #hmm...
    $window->put($textbox);
    $window->{parent}=$this;
    for ( my $i=0; $i < @{$params{buttons}}; $i++ ) {
        my $temp = Paw::Paw_button->new( text=>$params{buttons}->[$i] );
        push(@buttons, $temp);
        $temp->set_border();
        $window->put($temp);
        $window->put_dir("h");
    }
    $this->{window}  = $window;
    $this->{buttons} = \@buttons;
    return $this;
}

sub draw {
    my $this = shift;

    return $this->{window}->raise();
}

sub _callback {
    my $this = shift;

    
    for ( my $i=0; $i < @{$this->{parent}->{buttons}}; $i++ ) {
        @{$this->{parent}->{buttons}}->[$i]->release_button();
    }
    while ( 1 ) {
        my $key = getch();
        if ( $key ne -1 ) {
            $this->key_press($key);
            for ( my $i=0; $i < @{$this->{parent}->{buttons}}; $i++ ) {
                return $i if ( @{$this->{parent}->{buttons}}->[$i]->is_pressed() );
            }
        }
    }
}
return 1;
