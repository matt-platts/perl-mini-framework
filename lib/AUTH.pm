# AUTH.pm
# Local authentication
# Directly run this module on the command line for usage information

package AUTH;
require("config.cgi") || die("Can't require config.cgi");  # pull in configuration vars - for database, etc.
use lib ("lib");
use CGI::Cookie;

use constant SESSIONS_FOLDER  => "/tmp/register_ra_sessions/";
use constant SESSIONS_TIMEOUT => 60;      #30 minute timeout for session files

my $debug_login=0;

# Sub: authenticate
# Meta: authenticate a user by their username and password
sub authenticate {

	if ($debug_login){
		print "Content-type:text/html\n\n";
		print "ON SUB AUTH::AUTHENTICATE";
	}
	my $username = shift;
	my $password = shift;
	my $session_key = shift;

	my %auth_response = (); # return data array

	# First check the valid IPs if this is turned on.
	if ($CONFIG::check_ip){
		if (grep {$_ eq $ENV{'REMOTE_ADDR'} } @CONFIG::valid_ips) {
		} else {
			# This section needs to return a proper error message and put it into the json template to be read by the front end.
			print "Content-type: text/plain\n\n";
			print "Invalid IP address - sorry but we are unable to authenticate you to use this software.";
			exit;
		}
	}

	if ($CONFIG::limit_users){ # if we are using a limited user list

		if ($debug_login){ print "Users are limited!";}
		my $found_user=0;
		foreach my $key ( keys %CONFIG::valid_users){ # check valid users hash first before checking LDAP
			if ($key eq $username){
				my $ldap_response;
				if ($CONFIG::LDAP_AUTH){
					# authenticate through ldap
					%ldap_response = BRCM_LDAP::ldap_authenticate($username,$password);

					#use lib ("lib");
					#use debug;
					#my $debugger = new deb
					#$debugger->debug_log(\%ldap_response);
					#$debugger->debug_log("Error message hash");
					#$debugger->debug_log($ldap_response{'errorMsg'});

				} else {
					%ldap_response = (
						'success' => 'true', # authorise by default
					);
				}
				open (OUTF,">debug_log.txt");
				print OUTF time() . ":debug\n";
				print OUTF time()  . ":" .$ldap_response{'success'};
				close(OUTF);
				if ($ldap_response{'success'} eq "true"){
					# set up session
					my $session = sessions->new($session_key,$ldap_response{'memberOf'}); # leave the session id param blank to start a new session on login/ login::login passes in a blank string
					#return $CONFIG::valid_users{$key}; # pre-session version
					my %auth_response = (
						token => $session->{'ID'},
						success => 1,
						error => 0,
						memberOf => $ldap_response{'memberOf'},
						memberOf_array => $ldap_response{'memberOf_array'},
						errorMsg => $ldap_response{'errorMsg'},
					);
					$auth_response{'token'}= $session->{'ID'};
					$auth_response{'success'}=1;
					$auth_response{'error'}=0;
					$auth_response{'memberOf'} = $ldap_response{'memberOf'};
					$auth_response{'memberOf_array'} = $ldap_response{'memberOf_array'};
					$auth_response{'errorMsg'}=$ldap_response{'errorMsg'};
					#my $debugger = new debug;
					#$debugger->debug_log("Returning here");
					#$debugger->debug_log($ldap_response{'errorMsg'});
					#§$debugger->debug_log($ldap_response{'token'});
					if ($debug_login){
						print "<p>RETURNING";
						print "memberOf : " . $auth_response{'memberOf'} . "<br />";
						print "token : " . $auth_response{'token'} . "<br />";;
						print "memberOf in ldap_response : " . $ldap_response{'memberOf'} . "<br />"; # THIS ONE PRINTS, WHY NOT THE OTHERS???!
						print "<p>-</p>";
						print Dumper %auth_response;
						print $auth_response;
						print ref (%auth_response);
						print "<p> DONE - now to return";
					}
					return \%auth_response; 
				} else {
					$auth_response{'success'}=1;
					$auth_response{'error'}=0;
					$auth_response{'token'}='';
					$auth_response{'errorMsg'}=$ldap_response{'errorMsg'};
					return \%auth_response;
				}
			$found_user=1;
			}
		}
		if (!$found_user){
				$auth_response{'success'}=0;
				$auth_response{'error'}=1;
				$auth_response{'token'}='';
				$auth_response{'errorMsg'}="User not found";
				return \%auth_response;
		}
	} else {
		# authenticate through ldap - exactly the same 10 lines of code as above - move to own sub?
		my %ldap_response = BRCM_LDAP::ldap_authenticate($username,$password);
		#use lib ("lib");
		#use debug;
		#my $debugger = new debug ;
		#$debugger->debug_log("LDAP response from BC AUTH at (2)");
		#$debugger->debug_log(\%ldap_response);
		#$debugger->debug_log("Error message hash");
		#$debugger->debug_log($ldap_response{'errorMsg'});
		if ($ldap_response{'success'} eq "true"){
			# set up session
			my $session = sessions->new($session_key); # leave the session id param blank to start a new session on login/ login::login passes in a blank string
			#return $CONFIG::valid_users{$key}; # pre-session version
			$auth_response{'success'}=1;
			$auth_response{'error'}=0;
			$auth_response{'token'}=$session->{'ID'};
			$auth_response{'errorMsg'}=$ldap_response{'errorMsg'};
			return \%auth_response;
		} else {
			$auth_response{'success'}=0;
			$auth_response{'error'}=1;
			$auth_response{'token'}='';
			$auth_response{'errorMsg'}=$ldap_response{'errorMsg'};
			return \%auth_response;
		}

	}
}

sub __callLDAP {

	my $self = shift;
	my $username = shift;
	my $password = shift;

	my %ldap_response = BRCM_LDAP::ldap_authenticate($username,$password);
	if ($ldap_response{'success'} eq "true"){
		# set up session
		my $session = sessions->new($session_key); # leave the session id param blank to start a new session on login/ login::login passes in a blank string
		#return $CONFIG::valid_users{$key}; # pre-session version
		$auth_response{'success'}=1;
		$auth_response{'error'}=0;
		$auth_response{'token'}=$session->{'ID'};
		$auth_response{'errorMsg'}=$ldap_response{'errorMsg'};
		return \%auth_response;
	} else {
		$auth_response{'success'}=0;
		$auth_response{'error'}=1;
		$auth_response{'token'}='';
		$auth_response{'errorMsg'}=$ldap_response{'errorMsg'};
		return \%auth_response;
	}

}

# sub get_user_name
# Returns the name of the currently logged in user (name comes from the %valid_users hash in the config file)
sub get_user_name {

	my %cookies = CGI::Cookie->fetch;
	my $userdata = shift;

	# NEED TO EDIT THE BIT WHERE THE COOKIE IS SET - is it being set??!! Why is the session code below not running?
	#
	return get_user_name_from_session($userdata);

	if (!$cookies{'user'} && $userdata){
		$user_key = $userdata;

		return get_user_name_from_session($userdata); # THIS IS THE NEW RETURN STATEMENT
		#return join("",grep { $CONFIG::valid_users{$_} eq $user_key} keys %CONFIG::valid_users);
	} else {
		my @cookie_parts = split(/;/,$cookies{'user'});
		my @name_val = split(/=/,$cookie_parts[0]);
		my $user_key = $name_val[1];
		if (!$user_key){ $user_key = $cookies{'user'}; } # from login page only - we have stored the name directly in $cookies
		return join("",grep { $CONFIG::valid_users{$_} eq $user_key} keys %CONFIG::valid_users);
	}

}

# Sub: get_user_name_from_session
# Meta: this version gets the user name from a session file if you are using the sessions plugin
sub get_user_name_from_session {

	require sessions;
	my $session = new sessions(); # add user key here, move the folder shite to the actual module or into config as I dont want to pass that sort of nonsense in each time
	use lib ("lib");
	use debug;
	my $debugger = new debug ;
	$debugger->debug_log(\$session);
	return $session->{'username'};
}

# Sub: get_groups_from_session
sub get_groups_from_session {

	require sessions;
	my $session = new sessions(); # add user key here, move the folder shite to the actual module or into config as I dont want to pass that sort of nonsense in each time
	use lib ("lib");
	use debug;
	my $debugger = new debug;
	$debugger->debug_log(\$session);
	return $session->{'memberOf'};
}

# Sub: is_admin
# Meta: check if the user is an admin user
sub is_admin {
       my $uname = get_user_name();
       if (grep {$_ eq $uname} @CONFIG::admin_users) {
	       return 1;
       }
       return 0;
}

# Sub: refresh_login_cookie
# Meta: refresh the cookie each time the user uses the api - this keeps the login active for one hour from last use
sub refresh_login_cookie {

	my %cookies = CGI::Cookie->fetch;
	my @cookie_parts = split(/;/,$cookies{'user'});
	my @name_val = split(/=/,$cookie_parts[0]);
	my $user_key = $name_val[1];

	use lib ("lib");
	use debug;
	my $debugger = new debug ;
	$debugger->debug_log("Got cookie key of " . $user_key);

	my $user_cookie = CGI::Cookie->new(-name=>'user',-value=>$user_key,-expires=>'+2h');
	return $user_cookie; # return for printing in the header

}

sub get_login_cookie_value {
	my %cookies = CGI::Cookie->fetch();
	my @cookie_parts = split(/;/,$cookies{'user'});
	my @name_val = split(/=/,$cookie_parts[0]);
	my $user_key = $name_val[1];
	print @name_val;
	return $user_key;
}

# This has not been checked
sub refresh_login_cookie_and_print_header {

	my %headers = shift; # eg. -type => "application/json"
	my $user_cookie = SYMC_AUTH::refresh_login_cookie();
	print $cgi->header(-cookie=>[$user_cookie], %headers);

}

# give usage information if module is run directly on the command line 
# note backslashes are for display purposes and not reference if you are browsing the code.
__PACKAGE__->usage() unless caller;
sub usage {
	print <<EOT;
	Usage: Include the following line in your main script:

	use AUTH qw(authenticate);

	and call the authentication function using:

	AUTH::authenticate(\$username,\$password);
EOT
}
