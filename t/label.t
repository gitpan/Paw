print "1..3\n";
use Paw_base;
use Paw::Paw_label;
print "ok 1\n";

$label = Paw::Paw_label->new(text=>"test");
print "ok 2\n";    

print "ok 3\n" if ( $label->get_text() eq "test" );
