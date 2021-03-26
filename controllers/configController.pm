#!/usr/bin/perl
#configController.pm
#auth methods

use strict;
package configController;

use CGI qw/:standard/;
use CGI::Cookie;

sub new {

	my $class = shift;
	my $self = {};
	bless $self,$class;
	return $self;
}

sub defaultAction {
	
	my $self = shift;
	require configModel;

	my %response = (
		error => 0,
		success => 1,
		content=> &configModel::getConfig(),
	);
	return \%response;
}

sub get {
	
	my $self = shift;

	my %response = (
		error => 0,
		content=> "get result",
		success => 1,
	);
	return \%response;

}

sub userConfig {
	my $self = shift;

	require configModel;
	my %response = (
		error => 0,
		success => 1,
		content=> &configModel::getUserConfig(),
	);
	return \%response;
}

1;
