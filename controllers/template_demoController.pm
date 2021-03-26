#!/usr/bin/perl
# template_demoController.pm
#
package template_demoController;

my $view;


sub new {

	my $class = shift;
	my $self = {};
	bless $self,$class;
	return $self;

}

sub do_demo {

	my $self = shift;
	my $inputs = shift;
	my $pairs_text = _get_pairs($inputs);
	%response = (
		error => 0,
		success => 1,
		content => "This is some demo content which is set by the controller " . $inputs->{'route'} . "<p>" . $pairs_text,
		title => "This is a demo title - set by the controller",
	);
	&_set_content_type("text/html");
	&_set_view("view_template");
	return \%response;
}

sub _set_view {
	$view = shift;
	viewController::setView($view);	
	return $view;
}

sub _set_content_type {
	$ct = shift;
	&viewController::setContentType($ct);
	return $ct;
}

sub _get_pairs {
	my $inputs = shift;
	my $response;
	foreach $key (keys %{$inputs->{'pairs'}}){
		$response .= "key value pair: " . $key . " = " . $inputs->{'pairs'}->{$key};
	}
	return $response;
}

1;
