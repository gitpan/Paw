#!/usr/bin/perl -w
#########################################################################
# Copyright (c) 1999 SuSE Gmbh Nuernberg, Germany.  All rights reserved.
#
# Author  : Uwe Gansert <ug@suse.de>
# License : GPL, see LICENSE File for further information
use Paw_base;    # needed for widgets
use Curses;      # needed for getch() and more
use Paw::Paw_button;
use Paw::Paw_text_entry;
use Paw::Paw_label;
use Paw::Paw_window;
use Paw::Paw_filedialog;


#
# init - as always
#
($columns, $rows)=Paw_base::init_widgetset;

#
# generate a window with a scoller as statusbar.
#
$status="                    test for Statusbar, by the way, F10 is the Quit Key";
$win=Paw::Paw_window->new(time_function=>\&time_func, quit_key=>KEY_F(10), height=>$rows, width=>$columns, statusbar=>\$status, orientation=>"grow");
#
# Labels, Entrys and all that stuff.
#
$label=Paw::Paw_label->new(text=>"Path :");
$entry=Paw::Paw_text_entry->new(text=>"/", width=>20, echo=>2);
$button=Paw::Paw_button->new(text=>"Open Filedialog", callback=>\&button_cb);
$fd=Paw::Paw_filedialog->new(dir=>"/");
$file_label=Paw::Paw_label->new(text=>"FILES: ");

#
# putting
#
$win->put($label);
$win->put_dir("h");
$win->put($entry);
$win->put($button);
$win->put_dir("v");
$win->put($file_label);
$win->raise();

#
# The Callback for the button.
#
sub button_cb {
    my $dummy = $entry->get_text();   #read the text entry
    my @back;
    my $files = "";

    # set filebox to the path from the text entry
    $fd->set_dir($dummy);
    # raise the filebox, @back will contain the files
    # which were selected in the filebox
    @back = $fd->draw();
    # set the text entry to the directory in where the
    # user left the filebox
    $entry->set_text($fd->get_dir());
    # put the selected filenames into one string
    foreach $dummy ( @back ) {
        $files.=($dummy." ");
    }
    # show the selected files
    $file_label->set_text("FILES: ".$files);
    
    return;
}

#
# The time_function (only used for the scroller here)
#
sub time_func {

    $status=substr($status, 1, 70).substr($status, 0, 1); #easy hm ?

}
