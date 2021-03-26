#!/usr/bin/perl
# route.pm
# routing methods for framework
package route;
require Exporter;
use Cwd;
use strict;

#######################################################################################################################################
# The route is determined from the url itself, which is split at forward slashes to get parameters.
# The first value is the controller filename, found in the controllers folder.
# The second value is the function to call, found in the controller file itself.
# Eg. /auth/login/ - calls the login function in the auth controller.
#     /auth/login/goto/homepage/ - calls the login function in the auth controller, and passes in goto=homepage as a key/value pair.
# Further url paramaters are used as key/value pairs and are not for the route itself, 
# but are stored in @$params and %pairs in this module along with accessor methods
# Regular query strings / post data can still be picked up in your code in the usual ways
#######################################################################################################################################

# Sub new
# Meta: route constructor class
sub new {

	my $class = shift;
	my $request = shift;

	my $self = {
		_params => "",
		_pairs => "",
	};


	$request =~ s/$CONFIG::path//; # MPL - remove path from request
	$request =~ s/\/\//\//g; # MPL - remove double slashes

	my @parts = split(/\//g,$request);

	for (my $i=0;$i<scalar(@parts);$i++){
		#print "ON " . $parts[$i];
		if ($parts[$i] eq $CONFIG::path || !$parts[$i]){
			shift @parts; # remove blank parts of the url and the api path itself
			$i--;
		} else {
		}
	}
	$self->{'module'} = shift @parts;
	if (!$self->{'module'}){ # no api path specified, we can use default
		$self->{'module'} = "default";
	}
	$self->{'module'} .= "Controller";
	$self->{'function'} = shift @parts;

	if ($self->{'module'} !~ /^[a-zA-Z0-9\_\-]+$/ || ($self->{'function'} && $self->{'function'} !~ /^[a-zA-Z0-9\_\-]+$/)){
		# File does not exist - raise an error message
		$self->{'errorMessage'} = "Illegal characters in url";
		$self->{'errorCode'} = "URL1928678";
		$self->{'module'}="";
		$self->{'function'}="";
		bless $self,$class;
		return $self;

	}

	if (!$self->{'function'} || $self->{'function'} =~ /^\?.*/){ # if no second paramater or it's a query string
		$self->{'function'} = "defaultAction"; # call a sub called defaultAction if nothing specified
	}

	my $file = getcwd . "/controllers/".$self->{'module'};
	if (-e "$file.pm"){
		my $res = eval("use " . $self->{'module'}); # use the controller specified in the url
	} else {
		# File does not exist - raise an error message
		$self->{'errorMessage'} = "Controller module from path does not exist for " . $self->{'module'};
		$self->{'errorCode'} = "918273";
		bless $self,$class;
		return $self;
	}

	$self->{'route'} = $self->{'module'}."::".$self->{'function'}; # the function we want to call in the specified module
	my %response;
	my $checkRoute = $self->{'route'};

	# check validity of function. Private classes start with _ - don't allow these to be accessed directly through the url.
	if ($self->{'function'} ne "defaultAction" && defined(\&$checkRoute) && ref(\&$checkRoute) == "CODE" && $checkRoute !~ /^_/){

		$self->{'params'} = \@parts;
 		my %pairs = &set_key_pairs(@{$self->{'params'}});
		$self->{'pairs'} = \%pairs;
		#&get_key_pairs;

		%response = (
			route => $self->{'route'},
			function => $self->{'function'},
			module => $self->{'module'},
			error => 0,
			success => 1,
			params => \@parts,
			pairs => $self->{'pairs'},
		);

	} elsif ($self->{'function'} ne "defaultAction") {
		my $errorMsg = "Could not find route (route definition error) for " . $self->{'module'} . " and " . $self->{'function'} . "(".$checkRoute . ") where defined is " . defined(&$checkRoute) . " and ref is " . \&$checkRoute;

		%response = (
			error => 1,
			success => 0,
			errorMessage => $errorMsg, 
			function => $self->{'function'}, 
			route => 0,
			module => $self->{'module'},
			parts => \@parts,
			pairs => $self->{'pairs'},
		);

	} elsif ($self->{'function'} eq "defaultAction"){

		$self->{'params'} = \@parts;
 		my %pairs = &set_key_pairs(@{$self->{'params'}});
		$self->{'pairs'} = \%pairs;
		#&get_key_pairs;

		%response = (
			route => $self->{'route'},
			function => $self->{'function'},
			module => $self->{'module'},
			error => 0,
			success => 1,
			params => \@parts,
			pairs => $self->{'pairs'},
		);


	}

	$self->{'response'} = \%response;
	#return \%response;


	bless $self,$class;
	return $self;

}

# Sub: get_route
# Meta: get all the data from the route
# Returns: HASH of route data
sub get_route {

	my $self = shift;
	return $self->{'response'};

}

# initialize vars - there are two global to this package - @params (all url paramaters) and %pairs (url params split into key/value pairs)
my $params; # array ref of url paramaters
my %pairs; # url paramaters split into pairs

# Sub: params
# Return: array (list of url params sent as part of the url and not the query string
sub params {
	return @$params;
}

# Sub: set_key_pairs
# Meta: Go through the url paramaters that makes up the route, and store alternately as keys and values in %pairs hash
# Return: hash (key/value pairs from the url)
sub set_key_pairs {
	my @params = @_; 
	my %pairs;
	my $keyname;
	my $param;
	foreach $param (@params){
		if ($keyname){
			$pairs{$keyname} = $param;
			$keyname="";
		} else {
			$keyname=$param;
		}
	}
	#viewController::setPairs(%pairs);
	return %pairs;
}

# Sub: get_key_pairs
# Meta: return all key pairs from the url paramaters (route)
# Return: hash (all route pairs)
sub get_key_pairs {
	return %pairs;
	foreach my $key (keys %pairs){
		#print "$key - " . $pairs{$key} . "<br />";
	}
}

# Sub: get_route_value
# Meta: look up the value of an url paramater by it's key
# Param $key (string) - single key to return the resposne from the %pairs hash which is taken from url params
sub get_route_value {
	my $key = shift;
	return $pairs{$key};
}
1;
