#!/usr/bin/perl -w
#########################################################################
# Copyright (c) 1999 SuSE Gmbh Nuernberg, Germany.  All rights reserved.
#
# Author  : Uwe Gansert <ug@suse.de>
# License : GPL, see LICENSE File for further information
#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# textbox is buggy !
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# insert text on your own risk !
# displaying of text should work
#
use Paw_base;           # needed for widgets
use Curses;             # needed for getch() and more
use Paw::Paw_textbox;
use Paw::Paw_window;
use Paw::Paw_scrollbar;


($columns, $rows)=Paw_base::init_widgetset;

$win=Paw::Paw_window->new(height=>$rows, width=>$columns);

#@text=();
#$text[0]="Ignored; for Unix";
#$text[1]="List the numeric";
#$text[2]="Although both windows may be displayed at the  same  time";
#$text[3]="Many  of  the special xterm features may be modified under";
#$text[4]="In VT102 mode, there are escape sequences to activate and";
$text="widget to buggy ... sorry";
$box=Paw::Paw_textbox->new(data=>\$text, width=>30, height=>5, wordwrap=>0);
$box->set_border();
$sb=Paw::Paw_scrollbar->new(widget=>$box);

$win->abs_move_curs(new_y=>2);
$win->put($box);
$win->put($sb);
$win->raise();
