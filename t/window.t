print "1..3\n";
use Paw_base;
use Paw::Paw_window;
print "ok 1\n";
$widget = Paw::Paw_window->new(abs_x=>1, abs_y=>1, height=>30, width=>20, color=>1, statusbar=>1);
print "ok 2\n";    

$widget->set_border();
print "ok 3\n";

$widget->close_win();
$widget->raise();
