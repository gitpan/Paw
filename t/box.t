print "1..4\n";

use Paw_base;
use Paw::Paw_box;
print "ok 1\n";

$widget = Paw::Paw_box->new(direction=>"v");
print "ok 2\n";    

$box = Paw::Paw_box->new(direction=>"h", name=>"testbox", title=>"test", color=>1, orientation=>"top_left");
print "ok 3\n";

$box->put($widget);
print "ok 4\n";

