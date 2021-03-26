#!/usr/bin/perl
#userController.pm
#auth methods

use strict;
package userController;

use CGI qw/:standard/;
use CGI::Cookie;

sub new {

	my $class = shift;
	my $self = {};
	bless $self,$class;
	return $self;
}

# Sub: login
# Meta: log the user into the system
sub details {

	my $self = shift;

	my $params = shift;


	use AUTH;
	my $username = AUTH::get_user_name();
	my %content = (
		username => $username,
	);
	my $usertype;

	foreach my $admin_user (@CONFIG::admin_users){
		if ($admin_user eq $content{'username'}){
			$usertype="ADMIN";
		}
	}		
	$content{'type'}=$usertype;
	my %response = (
		success => 1,
		error => 0,
		content => \%content,
	);

	return \%response;

}
