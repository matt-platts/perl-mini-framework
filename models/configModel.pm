#!/usr/bin/perl
#configModel.pm
#auth methods

use strict;
package configModel;

sub getConfig {

	my %return = (
		api_path => "/".$CONFIG::path . "/",
		editable => $CONFIG::allow_editing,
		login_required => $CONFIG::login_required,
		application_environment => $CONFIG::application_environment,
	);
	
	return \%return;
}

sub getUserConfig {

        use AUTH;
        my $username = AUTH::get_user_name_from_session();

	my %return = (
		admin_access => $CONFIG::admins{$username},
		random_text => "this is random",
	);
	return \%return;
}

sub testing {
	return "thislot";
}

1;
