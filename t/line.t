print "1..2\n";
use Paw_base;
use Paw::Paw_line;
print "ok 1\n";

$line = Paw::Paw_line->new(char=>"#");
print "ok 2\n" if $line->{char} eq "#";    

