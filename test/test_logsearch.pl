#!/usr/bin/perl

print "Content-type:text/html\n\n";

log_search("2815320276");
print "Done.";

sub log_search {

	my $search_for = shift;

	open (INF, "data/latest_searches.txt");
	my @filedata = <INF>;
	close(INF);

	my @rewrite_lines;
	my $datestring = localtime();
	my $username = "mattplatts" || "No logged in user";
	push (@rewrite_lines, $username . "|" . $search_for . "|" . $datestring); # add the new search
	foreach my $line (@filedata){
		chomp $line;
		my (@linedata) = split(/\|/,$line);
		if ($linedata[1] ne $search_for || $username ne $linedata[0]){
			# rewrite if serial doesn't match OR name doesn't match.. if both match we don't need to repeat it
			print $linedata[1] . "\n";
			push (@rewrite_lines, $line);
		} else {
			print "Not rewriting " . $linedata[0] . " - " . $linedata[1] . "\n";
		}
	}
	my $output_file="data/latest_searches.txt";
	open( OUTPUT, ">", $output_file ) or die "Can't write to $output_file: $!";
	flock(OUTPUT, LOCK_EX);
	my @slice = @rewrite_lines[0 .. 30]; # max of 500 entries. Note this is multi-user, would be far better to do database log
	my $loop;
	foreach $loop(@slice){
		print OUTPUT $loop . "\n";
	} 
	flock(OUTPUT, LOCK_UN);
	close(OUTPUT);
}

