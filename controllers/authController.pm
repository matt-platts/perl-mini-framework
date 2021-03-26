#!/usr/bin/perl
#authController.pm
#auth methods

use strict;
package authController;

use CGI qw/:standard/;
use CGI::Cookie;

use lib ("../models/");
use lib ("../lib//");

sub new {

	my $class = shift;
	my $self = {};
	bless $self,$class;
	return $self;
}

# Sub: login
# Meta: log the user into the system
sub login {

	my $self = shift;

	my $params = shift;

	# we are using a login library function in the login model for this.
	use loginModel qw(login); # from login model	
	my %response = &loginModel::login;
	if ($response{'success'} && !$response{'error'} && $response{'auth_token'}){
		my $user_cookie = CGI::Cookie->new(-name=>'user',-value=>$response{'auth_token'},-expires=>'+1h');
		&viewController::setCookie($user_cookie);
		my $groups_cookie = CGI::Cookie->new(-name=>'memberOf',-value=>"".$response{'memberOf'},-expires=>'+1h');
		&viewController::setCookie($groups_cookie);
	} else {
		&viewController::setHeaderValue("401");
	}

	my $usertype = "USER";

	foreach my $admin_user (@CONFIG::admin_users){
		if ($admin_user eq $response{'username'}){
			$usertype="ADMIN";
		}
	}		
	$response{'type'}=$usertype;

	return \%response;
}

# Sub: authenticate
# Meta: authenticate the user 
# Returns: HASH with key 'username' in 'content' which will be set if the user is logged in (the user name is derived from the login cookie info)
sub authenticate {
	
	my $self = shift;
	use AUTH;

	my $username = AUTH::get_user_name_from_session();
	my $usertype = "USER";

	foreach my $admin_user (@CONFIG::admin_users){
		if ($admin_user eq $username){
			$usertype="ADMIN";
		}
	}		

	my %result;
	my %content;
	if ($username){
		%content = (
			username => $username, 
			type => $usertype,
			firstName => "",
			lastName => "",
		);

		%result = (
			error => 0,
			success => 1,
			content => \%content,
		);
	} else {

		&viewController::setHeaderValue("401");

		%content = (
			username => "",
			type => "",
			firstName => "",
			lastName => "",
		);

		%result = (
			error => 1,
			success => 0,
			content => \%content,
		);

	}

	return \%result;
}

# Sub: logout
# Meta: log the user out
sub logout {

	my $self = shift;

	use loginModel qw(logout);	
	my %response = &loginModel::logout;
	return \%response; 

}

# Sub notLoggedIn
# Meta: default response if not logged in
sub notLoggedIn() {

	my $self = shift;
	my $route = shift;

	&viewController::setHeaderValue("401");
	my %response = (
		error => 1,
		success => 0,
		errorMessage => "Login Required",
		errorCode => "LOG1",
		params => $route->{'params'},
		module => $route->{'module'},
		function => $route->{'function'},
	);
	return \%response;
}

1;
