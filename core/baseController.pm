#!/usr/bin/perl
# viewController.pm

use strict;
package viewController;

# Function: new
# NOT YET USED 
sub new {
	
	my $class = shift;

        my $self = {
                view => "view_json", # default response format 
                view_template => "", 
                __cookie => "", 
                contentType => "", 
		http_status => "200", # default status
        };  

	bless $self,$class;
	return $self;
}

# SETTINGS
my $view = "view_json";
my $__cookie = "";
my $content_type;
my $contentType;
my $view_template;
my $http_status = 200;

# Sub: getView
# Meta: return the view
sub getView {

	return $view;
}

# Sub setView
# Meta: set the view - normally called by a controller
sub setView {

	my $var_view = shift;
	my $template = shift;
	$view = $var_view;
	if ($template){
		$view_template = $template;
	}
}

sub getCurrentDir{

	use Cwd;
	return getcwd;

}

sub getViewFile {

	my $viewFile = shift;
	return &getCurrentDir . "/views/" . $viewFile . ".pm";
}

sub setPairs {

	my %pairs = shift;
	foreach my $pair (%pairs){
		print $pair . " " . $pairs{$pair} . "<br />";
	}
}

# view related
sub setCookie {

	my $cookie = shift;
	$__cookie = $cookie;
}

# Should be in the view
sub printHeader {

	if ($__cookie){
		print CGI::header(
				-status => $http_status,
				-type=> &getContentType,
				-cookie=>[$__cookie],
				);
	} else {
		print CGI::header(
				-status => $http_status,
				-type=> &getContentType,
				);
	}
}

# Sub: getContentType
# Meta: read the current document content type
# Returns: string
sub getContentType {

	if (!$contentType){
		$contentType = $CONFIG::default_content_type;
	}

	return $contentType;

}

# Sub: setContentType
# Meta: sets the content type variable, which is printed as the header in framework.cgi
# Returns: string - simply the content type that was sent in
sub setContentType {
	my $ct = shift;
	$contentType = $ct;
	return $ct;
}

# more view stuff 
sub setHeaderValue {
	my $httpStatus = shift;
	my $httpMessage = shift;


	$http_status = $httpStatus;
}

1;
