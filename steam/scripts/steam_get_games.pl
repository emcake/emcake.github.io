use strict;
#my $url = 'http://store.steampowered.com/search/?sort_by=Name&sort_order=ASC&category1=998';
    # Just an example: the URL for the most recent /Fresh Air/ show

#  use LWP::Simple;
#  my $content = get $url;
#  die "Couldn't get $url" unless defined $content;

#open (MYFILE, '>>steam_page.html');
#  print MYFILE $content;
#close (MYFILE);

#print "done";*/

use LWP::Simple;

sub get_page
{
	my $url = "http://store.steampowered.com/search/?sort_by=Name&sort_order=ASC&category1=998&page=$_[0]";
	
	my $filename = ">>steam_listing_$_[0].html";

print "get page $url\n";

	my $content = get $url;
	die "Couldn't get $url" unless defined $content;

	

	open (MYFILE, $filename);
	  print MYFILE $content;
	close (MYFILE);

	print "saved to file $filename";
}

for( $a = 1; $a <= 106; $a = $a + 1 ){
    get_page($a);
}