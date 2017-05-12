use warnings;
use strict;

my $outfile = '>>game_json.js';

my $root = 'apps/';

my $colorific = 'colorific';

my $colorific_options = '--parallel=8 --max-colors=10 --min-saturation=0.1 --min-distance=20';

sub get_game_name
{
	open my $file, '<', "$_[0]/name.txt"; 

	my $firstLine = "";

	if ($file)
	{
		$firstLine = <$file>; 
		close $file;
	}
	
	return $firstLine;
}

sub get_game_json
{
	my $dir = "apps/".$_[0];

	
	my @files = <$dir/*.jpg>;

	if (scalar(@files) == 0)
	{
		return "";
	}

	print $dir."\n";

	my $json = "{\n";

	my $gamename = get_game_name( $dir );

	$json  = $json . "\"name\" : \"$gamename\",\n";
	$json = $json."\"appid\" : $_[0],\n";

	
	my $colorific_files = "";

	$colorific_files = $colorific_files.$_."\n" foreach @files;

	my @results = split (/\n/,`$colorific $colorific_options $colorific_files`);

	$json = $json."\"pics\" : [\n";

	my @shot_items;

	foreach my $jpg (@results)
	{

		if ($jpg =~/(ss_[\w_]*\.jpg)/)
		{
			my $shot_json = "";
			$shot_json = $shot_json . "\t{\n\t\"shot\" : \"$1\",\n";
			$shot_json = $shot_json . "\t\"colours\" : [";
			$shot_json = $shot_json . join(',',map { "\"$_\"" } $jpg =~ m/#(\w\w\w\w\w\w)/g);
			$shot_json = $shot_json . "]\n\t}\n";

			push( @shot_items, $shot_json );
		}
		
	}

	$json = $json.join(",", @shot_items);

	$json = $json."]\n";

	$json = $json . "}";

	return $json;
}

opendir my $dh, $root
  or die "$0: opendir: $!";

my @dirs = grep {-d "$root/$_" && ! /^\.{1,2}$/} readdir($dh);

my @json_objects;


foreach my $dir (@dirs)
{
	my $json = get_game_json($dir);

	if ($json ne "")
	{
		push (@json_objects, $json);
	}
}

open (JSFILE, $outfile);
  print JSFILE "var SteamGames = [\n";
  print JSFILE join(',',@json_objects);
  print JSFILE "];\n";
close (JSFILE);