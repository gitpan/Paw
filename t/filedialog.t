print "1..4\n";
use Paw_base;
use Paw::Paw_filedialog;
print "ok 1\n";

$fd = Paw::Paw_filedialog->new();
print "ok 2\n";    

$fd = Paw::Paw_filedialog->new(height=>10, width=>10, name=>"fd", dir=>"/tmp" );
print "ok 3\n" if ( $fd->{name} eq "fd" );

print "ok 4\n" if ( $fd->get_dir() eq "/tmp" );
$fd->set_dir("/etc");
print "ok 5\n" if ( $fd->get_dir() eq "/etc" );
