#########################################################################
# Copyright (c) 1999 SuSE Gmbh Nuernberg, Germany.  All rights reserved.
#
# Author  : Uwe Gansert <ug@suse.de>
# License : GPL, see LICENSE File for further information
package Paw::Penguin;
use Curses;

@Paw::ISA = qw(Exporter);
@ISA = qw(Paw);
@Paw::EXPORT = qw(
);
$Paw::VERSION = "0.47";


sub new {
    my $classs = shift;
    my $this   = Paw::new_widget_base;
    my %params = @_;

    $this->{name}      = (defined $params{name})?($params{name}):("tux");    #Name des Fensters (nicht Titel)
    $this->{cols}      = 4;
    $this->{rows}      = 3;
    $this->{direction} = "v",
    bless ($this, $class);
    return $this;
}

sub draw {
    my $this = shift;
    my $line = shift;
    my @box = (" -o)", " /\\\\", "_\\_v");

    addstr($box[$line]);

    return;
}
return 1;
