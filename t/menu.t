print "1..3\n";
use Paw_base;
use Paw::Paw_menu;
print "ok 1\n";

$widget = Paw::Paw_menu->new(title=>"test", name=>"menu_name", border=>"shade");
print "ok 2\n" if $widget->{name} eq "menu_name";    

$widget->add_menu_point(text=>"menu_point", callback=>\&test_sub);
print "ok 3\n" if ( ref($widget->{points}->[0]) eq "Paw::Paw_button" );

sub test_sub {
 	return;
}
