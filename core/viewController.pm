#!/usr/bin/perl
# viewController.pm
# global view functions and settings. Note that these are currently called from several places and are used as static functions

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
my @cookies=();
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

sub __getCurrentDir{

	use Cwd;
	return getcwd;

}

sub getViewFile {

	my $viewFile = shift;
	return &__getCurrentDir . "/views/" . $viewFile . ".pm";
}

sub setPairs {

	my %pairs = shift;
	foreach my $pair (%pairs){
		print $pair . " " . $pairs{$pair} . "<br />";
	}
}

sub setCookie {

	my $cookie = shift;
	$__cookie = $cookie;
	push(@cookies,$cookie);
}

# Sub printHeader
sub printHeader {

	if ($__cookie){
		print CGI::header(
				-status => $http_status,
				-type=> &getContentType,
				-cookie=>[@cookies],
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

# Function: setHeaderValue 
sub setHeaderValue {
	my $httpStatus = shift;
	my $httpMessage = shift;


	$http_status = $httpStatus;
}


# Sub:  loadView 
# Params: response (text) - this is the response from the controller that we need to insert into the view
# Meta: Places the content into the view 
sub loadView {

	my $response = shift;

	my $view = getView();
	my $viewFile = getViewFile($view);

	printHeader;

	# Assuming the view exists, require the file, render the view and then print directly 
	if (-e $viewFile){
		my $local_view;
		eval("require $view");
		$local_view = new $view; 
		my $render_function = $local_view->render;
		#my $result = &{\&{$render_function}}($response); # render the response into the view template dynamically. Other option would be a dispatch table.
		my $result = $local_view->render($response);
		#my $print_function = $view . '::print';
		my $print_result = $local_view->print($result);
		#my $print_result = &{\&{$print_function}}; # finally print the response in the view template
	} else {
		print "Error: No view file - unable to display data. (Return value from view was $view, and viewfile was $viewFile)\n";
	}

}

1;
