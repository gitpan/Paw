#########################################################################
# Copyright (c) 1999 SuSE Gmbh Nuernberg, Germany.  All rights reserved.
#
# Author  : Uwe Gansert <ug@suse.de>
# License : GPL, see LICENSE File for further information
package Paw::Paw_filedialog;
use Curses;
require Paw::Paw_window;
require Paw::Paw_listbox;
require Paw::Paw_button;
require Paw::Paw_label;
require Paw::Paw_text_entry;
require Paw::Paw_line;
require Paw::Paw_scrollbar;

@ISA = qw(Paw_base Exporter);
@EXPORT = qw(
);
$Paw::VERSION = "0.46";


=head1 Filedialog

B<$fd=Paw::Paw_filedialog->new([$height], [$width], [$name], [$dir])>;

B<Parameter>

     $height    => number of rows [optionally]

     $width     => number of columns [optionally]

     $name      => name of the widget [optionally]

     $dir       => the directory in which the filedialog
                   will be started ("." default) [optionally]

When the filedialogbox is closed by the "ok"-button, it returns an array of all marked filenames (without path)

B<Example>

     $fd=Paw::Paw_filedialog->new(dir=>"/etc");

=head2 set_dir($path)

Set the directory where the filedialog will begin.

B<Example>

     $fd->set_dir();       # start in "."
     $fd->set_dir("/etc"); # start in "/etc"

=head2 get_dir($scalar)

Returns the path of the filedialogbox.

B<Example>

     $path=$fd->get_dir();  #$path = "/etc" (for example).

=head2 draw()

Raises the filedialog. If the box is closed by the "ok-button", it returns an
array of all marked filenames (without path). If the box is closed by the "cancel-button",
no return of the marked files takes place.

B<Beispiel>

     @files=$fd->draw();

=cut

sub new {
    my $class  = shift;
    my $this   = Paw_base->new_widget_base();
    my %params = @_;
    my $cb     = \&_callback;
    
    $this->{dir}  = (defined $params{dir})?($params{dir}):(".");
    $this->{name} = (defined $params{name})?($params{name}):("_auto_"."filedialog");    #Name des Fensters (nicht Titel)
    $this->{rows} = (defined $params{height})?($params{height}):($this->{screen_rows}-10);
    $this->{cols} = (defined $params{width})?($params{width}):(30);
    $this->{type} = "filedialog";

    my $window = Paw::Paw_window->new( abs_x=>($this->{screen_cols}-$this->{cols})/2, abs_y=>($this->{screen_rows}-$this->{rows})/2, callback=>$cb, height=>$this->{rows}, width=>$this->{cols}, orientation=>"grow" );
    $window->{parent} = $this;
    $window->set_border("shade");
    my $label=Paw::Paw_label->new(text=>"Path: ");
    my $entry=Paw::Paw_text_entry->new(name=>"__fd_entry", text=>$this->{dir}, width=>22, echo=>2);
    my $line=Paw::Paw_line->new(char=>ACS_HLINE, length=>$this->{cols});
    my $list=Paw::Paw_listbox->new(name=>"__fd_listbox", width=>28, height=>$this->{rows}-7,colored=>1);
    $list->set_border();
    my $ok=Paw::Paw_button->new(text=>"Ok");
    $ok->set_border("shade");
    my $cancel=Paw::Paw_button->new(text=>"Cancel");
    $cancel->set_border("shade");
    my $sb=Paw::Paw_scrollbar->new(widget=>$list);

    $window->put_dir("h");
    $window->abs_move_curs(new_x=>1,new_y=>0);
    $window->put($label);
    $window->put($entry);
    $window->put_dir("v");
    $window->put($line);
    $window->put_dir("v");
    $window->put($list);
    $window->put_dir("h");
    $window->put($sb);
    $window->put_dir("v");
    $window->rel_move_curs(new_y=>3);
    $window->put($ok);
    $window->rel_move_curs(new_x=>$this->{cols}-17);
    $window->put_dir("h");
    $window->put($cancel);

    $this->{window}  = $window;
    $this->{ok}      = $ok;
    $this->{cancel}  = $cancel;
    $this->{list}    = $list;
    $this->{entry}   = $entry;
    
    bless ($this, $class);
    return $this;
}

sub draw {
    my $this = shift;
    $this->{color_pair} = $this->{parent}->{color_pair};
    $this->{window}->set_focus("__fd_listbox");
    
    return $this->{window}->raise();
}

sub _callback {
    my $this = shift;
    my $d=0;
    my @dirs=();
    my @files=();
    
    my $fg=0;
    my $bg=0;
    pair_content( $this->{color_pair}, $fg, $bg );
    $fg=unpack("C",$fg);$bg=unpack("C",$bg);
    init_pair($this->{anz_pairs}-3, COLOR_CYAN, $bg);
    $this->{parent}->{ok}->release_button();
    $this->{parent}->{cancel}->release_button();
    $this->{parent}->{list}->clear_listbox();
    opendir(DIR, $this->{parent}->{dir});
    while($d = readdir(DIR)) {
        (-d $this->{parent}->{dir}.$d)?(push @dirs, $d):(push @files, $d);
    }
    @dirs=sort @dirs;
    @files=sort @files;
    $this->{parent}->{list}->add_row(\@dirs,$this->{anz_pairs}-3);
    $this->{parent}->{list}->add_row(\@files,$this->{color_pair});

    closedir(DIR);

    my $key = "";
    while ( 1 ) {
        $this->_refresh() if ( $key ne -1 );
        $key = getch();
        $this->key_press($key) if ( $key ne -1 );
        return 0 if ($this->{parent}->{cancel}->is_pressed() );
        if ($this->{parent}->{ok}->is_pressed()) {
            my @dummy = $this->{parent}->{list}->get_pushed_rows("data");
            $dummy[0] = "" if not defined $dummy[0];
            $dummy[0] = ".." if ( @dirs == 0 );
            if ($dummy[0] eq "..") {
                $this->{parent}->{dir} =~ s/(.*\/)(.*\/$)/$1/;
                $this->{parent}->set_dir($this->{parent}->{dir});
                $file=$this->{parent}->{dir};
            }
            else {
                $file=($this->{parent}->{dir}.$dummy[0]."/");
            }
            if (-d $file and $this->{active}->{type} eq "listbox") {
                @dirs=();
                @files=();
                $this->{parent}->{ok}->release_button();
                $this->{parent}->{list}->clear_listbox();
                $this->{parent}->set_dir($file);
                opendir(DIR, $this->{parent}->{dir});
                while($d = readdir(DIR)) {
                    (-d $this->{parent}->{dir}.$d)?(push @dirs, $d):(push @files, $d);
                }
                @dirs=sort @dirs;
                @files=sort @files;
                $this->{parent}->{list}->add_row(\@dirs,$this->{anz_pairs}-3);
                $this->{parent}->{list}->add_row(\@files,$this->{color_pair});
                closedir(DIR);
                $this->_refresh();
            }
            else {
                return $this->{parent}->{list}->get_pushed_rows("data");
            }
        };
    }
}

sub set_dir {
    
    my $this = shift;
    my $path = shift;
    
    return if $path =~ /\/\.\/$/;
    $path=$path."/" if ( not ($path =~ /\/$/i) ); #evtl, Slash anhaengen
    $this->{dir} = $path;
    $this->{entry}->set_text($path);
}

sub get_dir {
    my $this = shift;

    return $this->{dir};
}
return 1;
