print "1..6\n";
use Paw_base;
use Paw::Paw_window;
use Paw::Paw_label;
print "ok 1\n";
$widget = Paw::Paw_window->new(abs_x=>1, abs_y=>1, height=>30, width=>20, color=>1, statusbar=>1);
print "ok 2\n";    

$widget->set_border();
print "ok 3\n";

$test_widget = Paw::Paw_label->new(text=>" ");
$widget->put($test_widget);
print "ok 4\n";

$test_widget->abs_move_widget( new_y=>15, new_x=>15 );
print "ok 5\n";

($x,$y) = $test_widget->get_widget_pos();
if ( $x eq 15 and $y eq 15 ) {
print "ok 6\n";                
}
