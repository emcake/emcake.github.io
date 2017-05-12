use strict;

use LWP::Simple;
use pQuery;

my $section_end = "<!-- End List Items -->";

sub find_games
{
	my $inSection = 0;

	my $content = "";

	my $file = $_[0];
	open my $info, $file or die "Could not open $file: $!";

	my @games;

	while( my $line = <$info>)  {  
		
			
		if ($line =~ /<!-- List Items -->/)
		{
			$inSection = 1;
		} 
		elsif ($inSection == 1 && $line !~ /<!-- End List Items -->/)
		{
			if ($line =~ /<a href="((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/)
			{
				push( @games, $1 );
			}
			$content = $content . $line;
		}
		#<div class="apphub_AppName">10 Second Ninja</div>
	    
	    last if $line =~ /<!-- End List Items -->/;
	}

	return @games
}

sub get_game
{
	my $game = $_[0];

	print $game . "\n";

	if ($game =~ /app\/([0-9]+)/)
	{
		my $appid = $1;
		my $dom;

		print "App ID: ".$appid."\n";

		my $dir = "apps/".$appid."/";
		print "creating folder ".$dir;
		
		mkdir $dir;
		print " Done\n";

		print $game." -> ".$dir."gamepage.html: ";
		getstore( $game, $dir."gamepage.html");
		print " Done\n";

		my $name;

		pQuery($game)->find("div")->each( sub { my $cl = $_->attr("class"); if ($cl =~ /apphub_AppName/) { $name = $_->innerHTML(); } } );

		print $name." -> ".$dir."name.txt:";

		open (MYFILE, ">>".$dir."name.txt");
		  print MYFILE $name;
		close (MYFILE);

		print " Done\n";

		pQuery($game)->find("div")->each( sub { my $id = $_->attr("id"); if ($id =~ /highlight_strip_scroll/) { $dom = $_; } } );

		my @images;

		pQuery("img", $dom)->each( sub { push(@images, $_->attr("src")); } );

		foreach my $img(@images)
		{
			
			if ($img =~ /(.*$1\/)(ss_(\w*))\.([0-9]+x[0-9]+)\.jpg/)
			{
				print "Downloading screenshot ".$2.".jpg:";

				my $url = $1.$2.".jpg";
				my $file = $dir.$2.".jpg";

				getstore($url, $file);

				print " Done\n";
			}
		}
	}
}

my @files = <*.html>;
foreach my $file (@files) {
	print "---------------------------------------------------------\n";
	print "---------------------------------------------------------\n";
	print "---------------------------------------------------------\n";
	print "$file\n";
	print "---------------------------------------------------------\n";
	print "---------------------------------------------------------\n";
	print "---------------------------------------------------------\n";
  my @gameURLs = find_games($file);

  foreach my $url(@gameURLs)
  {
  	get_game( $url );
  }
}


