#!/usr/bin/perl
# accountController.pm

package accountController;
@ISA = (masterController);

use Data::Dumper;

# Example of basic return
sub thing {
	return "This is some content";
}

sub thingy {
	$return{'content'}="this";	
	$return{'error'}=0;
	$return{'success'}=1;
	return \%return; 
}

sub thingo {
	my %response = &masterController::return_content("Some content to send back"); 
	return \%response;
}

1;
