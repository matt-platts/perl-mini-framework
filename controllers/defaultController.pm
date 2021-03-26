#!/usr/bin/perl
# defaultController.pm
# used when no api path is specified

package defaultController;

@ISA = (masterController);


sub defaultAction {

	my %response = (
		error => 0,
		success => 1,
		content => "Welcome to the API. No API path has been specified, but if you are reading this message without errors then everything appears to be working fine. This message has been sent from the defaultAction function of the defaultController controller.",
	);

	return \%response;
}

1;
