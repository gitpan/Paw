print "1..2\n";
use Paw_base;
use Paw::Paw_radiobutton;
print "ok 1\n";

@labels=("a" , "b" );
$widget = Paw::Paw_radiobutton->new(direction=>"v", color=>1, name=>"name", callback=>\&test_sub, labels=>\@labels);
print "ok 2\n" if ( $widget->{name} eq "name" );    

