print "1..2\n";
use Paw_base;
use Paw::Paw_popup;
print "ok 1\n";

@b=("ok", "cancel");
@text=("jo", "jojo");
$widget = Paw::Paw_popup->new(buttons=>\@b, name=>"pop", height=>10, width=>10, text=>\@text);
print "ok 2\n" if $widget->{name} eq "pop";    

