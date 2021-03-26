#!/usr/bin/perl
# exampleController.pm

package exampleController;
@ISA = (masterController);

use strict;
use warnings;
use CGI;
use Data::Dumper;

sub defaultAction {

	my $inputs = shift; 
	my $cgi = new CGI;

	my $result = $cgi->param("example_value");
	#my $res = $inputs->{'pairs'}->{'example_value'};
	my %response = (
		success => 1,
		error => 0,
		content => "Your example value is $result",
	);
	return \%response;

}

# Sub modelExample
# Call as: http://localhost/api/example/modelExample/example_value/1000480381
sub modelExample {

	my $self = shift;
	my $inputs = shift;

	use exampleModel;
	my $cgi = new CGI;

	my $result = &exampleModel::doSomethingTechnical($inputs->{'pairs'}->{'example_value'}); # Business logic should be in the model

	my %response = (
		success => $result->{'success'},
		error => $result->{'error'},
		content => "Your example response is: " . $result->{'response'},
	);

	if ($result->{'error'}){
		$response{'errorMessage'} = $result->{'errorMessage'};
	}

	return \%response; # always return a HASH reference
}

1;
