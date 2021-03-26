#!/usr/bin/perl
# masterController.pm

package masterController;

sub new {
	
	my $class = shift;
	my $self = {};
	bless $self,$class;
	return $self;
}

sub defaultAction {

	my %response = (
		content => "A default action is not available.",
		success => 0,
		error => 1,
	);
	return \%response;
}

sub errorResponse {

	my $errorMessage = shift;
	my $errorCode = shift;

	my %response = (
		error => 1,
		success => 0,
		errorMessage => $errorMessage,
		errorCode => $errorCode,
	);
	return %response;
}

# Function: return_content
# Meta: format a string of content so you don't need to build an entire hash to return a quick message.
# Param: content (required) (string)
# Param: success (optional) (bool) - Return a success or fail boolean. If omitted defaults to a positive "success" flag (1).
#
sub return_content {

	my $error = 0;
	my $content = shift;
	my $success = shift;
	if (defined($success) && !$success){ $error=1;} elsif (!defined($success)){ $success=1;}

	my %return = (
		success => $success,
		error => $error,
		content => $content,
	);
	return %return;
}

# function AUTOLOAD
# meta: simply having this function exist at all stops the undefined subroutine error and gives a default 404 error message instead.
sub AUTOLOAD {
	my %response = (
		error => 1,
		success => 0,
		errorMessage => "Error 404",
		errorCode => "404",
	);
	return \%response;
}

1;
