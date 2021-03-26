#!/usr/bin/perl
# debug.pm
# Simple debugging info to text file 

package debug;

use strict;
use Data::Dumper;

our $debug_log_file="log/api-debug.txt";

# init
sub new {

	my $class = shift;
        my $self = {};
        bless $self,$class;
        return $self;

}

# sub: debug_log 
# meta: print a message to the debug log 
sub debug_log {

	my $self = shift;
	my $input = shift;
	open (OUTF, ">>$debug_log_file") or die ("Cant open debug file for writing: $!");
	if (ref($input) eq "REF"){
		print OUTF time() . ": [REF] ";
		print OUTF Dumper $input;
	} else {
		print OUTF time() . ": " . ref($input) . ": $input\n";
		#print OUTF Dumper \$input;
	}
	print OUTF "\n" . "-" x 50 . "\n";
	close(OUTF);

}

1;


