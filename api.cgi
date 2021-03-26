#!/usr/bin/perl
# File: api.cgi 
# Meta: Entry point to a lightweight perl api/framework

use strict;
use warnings;

use Data::Dumper; # for debugging
use lib("core"); # core framework files
use lib("controllers"); # user defined controllers
use lib("models"); # user defined models
use lib("views"); # user defined views
use lib("lib"); # function library
use lib("lib/API"); # Broadcom API library
use helpers; # helper function library

use viewController; # simple base class for storing view info which is called from various controllers
use masterController; # custom built controllers can extend this class

use route; # deals with routing from urls to classes
use CGI qw/:standard/; # standard cgi class
use CGI::Carp qw(fatalsToBrowser); # fatal error messages to stdout for development

use sessions;

require("config.cgi"); # api and user config settings

# permissions - is the requested action allowed?
my $allow_action = 0;
my $init_route = new route($ENV{'REQUEST_URI'}); # get basic params including the controller and action out of the url. The two important hash keys are 'module' and 'function' which dynamically load the required code.
my $response; # to contain the response from the function called by the url params
my $debug=0;

#print "Contetnt-type:text/html\n\n";

# Check to see if a login is required to access the route
if ($CONFIG::login_required){

	$init_route->{'module'} =~ s/Controller//; # remove the 'Controller' part of the filename, so it matches the URL for comparison
	foreach my $permitted (@CONFIG::no_login_required){
		my ($module,$function)=split("/",$permitted);
		if ($debug){ print "Check $module and $function against " . $init_route->{'module'} . " and " . $init_route->{'function'} . "\n";}
		if ($init_route->{'module'} eq $module && $init_route->{'function'} eq $function){
			$allow_action=1;
				if ($debug){ print "Set allow to 1";}
		}
	}	

	if (!$allow_action){
		
		my $cgi = new CGI;
		use AUTH;
		my $user_cookie = AUTH::refresh_login_cookie();
		if (!$user_cookie){
			require("authController.pm");
			my $controller = new authController;
			$response = $controller->notLoggedIn($init_route);
		} else {
			$allow_action = 1;
		}

	}

} else {

	# login_required is 0 in this else block, so set $allow_action to true 
	$allow_action = 1;

}

# If the action is allowed..
if ($allow_action){

	# ..parse the url and load the route into $route - this tells which controller and action to load, and this is run dynamically
	# note that get_route is different from init_route in that get_route also checks that the route exists - init is purely for pre-checking (eg. permissions)
	my $route = $init_route->get_route();

		# route is either a function in a module that we can call, or a falsy value.
		# If a function is returned (and exists), we call this to run that module from the controllers folder.
		# The result of the function is stored in the hashref $response (which is later sent to the view)
		if ($route->{'success'} && !$route->{'error'}){

			my $route_to_function = $route->{'route'};
			my $params = $route->{'params'};

			if ($CONFIG::use_dispatch_table){

				use dispatch;
				if (&dispatch::dispatchValue($route->{'module'},$route->{'function'})){
					$response = &{\&{$route_to_function}}($route); # route function called dynamically

					if ($response && !ref($response)){ # if we don't have a hashref returned but $response is defined, just use $response as content
						$response = {
							content => $response,
							success => 0,
							error => 1,
						};
					}
				} else {
					$response = &route_error("Function not found in dispatch table");
				}

			} else {

				my $module = $route->{'module'};
				my $func = $route->{'function'};
				my $controller = new $module;
				$response = $controller->$func($route); # Call the action, get the response in $response. Note the return value is a HASH by reference, not a string response.
				#$response = &{\&{$route_to_function}}($route); # route function called dynamically - other option would be a dispatch table.
				
				if ($response && !ref($response)){ # if we don't have a hashref returned but $response is defined, just use $response as content
					$response = {
						content => $response,
						success => 0,
						error => 1,
					};
				}
				
			}

		} else {

			if ($init_route->{'errorMessage'} && !$route->{'errorMessage'}){
				$route->{'errorMessage'} = $init_route->{'errorMessage'};
			}

			$response = &route_error("Route not available: " . $route->{'errorMessage'});

		}

} else {

	# action NOT allowed

	my $cgi = new CGI;
	use AUTH;
	my $user_cookie = AUTH::refresh_login_cookie();
	if (!$user_cookie){
		require("authController.pm");
		my $controller = new authController;
		$response = $controller->notLoggedIn($init_route);
	}

}

# We now have a response - pass this data to the view 
my $load_view = &viewController::loadView($response);

# Sub route_error
# Meta: print error message if route is incorrect
sub route_error {

	my $message = shift;

	my %response = (
		error => 1,
		success => 0,
		errorMessage => $message,
		errorCode => "Route-923798",
	);

	return \%response;
}

exit;

1;
