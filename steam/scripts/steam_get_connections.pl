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

sub get_game_rec_json
{
	my $game = $_[0];

	print $game . "\n";

	my $json = "";

	if ($game =~ /app\/([0-9]+)/)
	{
		my $appid = $1;

		print "App ID: ".$appid."\n";

		$json = $json."{\n";
		$json = $json."\t\"id\" : $appid,\n";

		my $page = pQuery( "http://store.steampowered.com/recommended/morelike/app/$appid" );

		my $nameObj = $page->find(".game_name .blockbg")->get(0);

		if (defined($nameObj))
		{
			my $name = $nameObj->innerHTML();

			$name =~ s/^\s+|\s+$//g;

			$json = $json."\t\"name\": \"$name\",\n";

			print "App: $name\n";

			my @games;

			$page->find(".similar_grid_item")->each( sub { my $url = $_->find('a')->attr('href'); if ($url =~ /app\/([0-9]+)/ ){ push( @games, $1 ); } } );

			my $tagpage = pQuery( "http://store.steampowered.com/app/$appid" );

			my @tags;

			$tagpage->find('.app_tag')->each( sub { my $data = $_->innerHTML(); $data =~ s/^\s+|\s+$//g; if ($data !~ '\+' ) { push( @tags, "\"$data\"" ); } } );

			$json = $json."\t\"similar\" : [ ";

			$json = $json.join(", " , @games);

			$json = $json." ],\n";

			$json = $json."\t\"tags\" : [ ";

			$json = $json.join(", " , @tags);

			$json = $json." ]\n";

			$json = $json."}";

			print "---------------------------------------------------------\n";
			

			return $json;
		}
	}

	return undef;
}

my $outfile = ">>game_recs.js";

open (JSFILE, $outfile);
  print JSFILE "var GameRecommends = [\n";

  my $first = 1;

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
  	my $json = get_game_rec_json( $url );

  	if (defined($json))
  	{
  		if ($first == 1)
		{
			$first = 0;
		}
		else
		{
			print JSFILE ",\n";
		}

  		print JSFILE $json;
  	}
  	
  }
}

  print JSFILE "];\n";
close (JSFILE);


