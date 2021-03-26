# BC_LDAP.pm
# BlueCoat LDAP authentication
# Run this module through the perl interpreter on the command line for usage information

package BC_LDAP;
require("config.cgi") || die("Can't require config.cgi");  # pull in configuration vars - for database, etc.
use JSON;

# Sub ldap_authenticate
# Authenticate the user via the LDAP server
# NB: This authentication can be turned off in the config file in the lib directory.
sub ldap_authenticate {
	my $login	= shift;
	my $password	= shift;

	if (!$CONFIG::ldap_auth){ return 0; } # ldap authentication can be turned on in the configuration file

	my %resp = (); # Store response

#-------------------------------------------------------------------------------------------------
# Create a new LDAP session
#-------------------------------------------------------------------------------------------------
	#print "<br>Connecting to " . $CONFIG::LDAP_SERVER . " on port " . $CONFIG::LDAP_PORT . "<br />";
	my $ldap = Net::LDAP->new($CONFIG::LDAP_SERVER, port => $CONFIG::LDAP_PORT) or die "Could not create LDAP object because:\n" . $! . " is the reason!";
	# TO DO: Handle the case where the LDAP cannot connect

	$login = BC_LDAP::ldapSafeName($login);
	my $user_dn = BC_LDAP::GetbDistinguishedNameFromUserName($ldap, $login);

	#-------------------------------------------------------------------------------------------------
	# LDAP Binding using a bcl.services service account
	# 'errorMessage' => '80090308: LdapErr: DSID-0C0903A9, comment: AcceptSecurityContext error, data 52e, v1db0^@',
        # 'resultCode' => 49,
	#-------------------------------------------------------------------------------------------------
#print $DEBUGLOG "Login: $login ==> User_DN: $user_dn\n";
	if ($user_dn eq '0') {
		$resp{'success'} = 'false';
		$resp{'errorMsg'} = "Error: Unknown user name $login";
	} else {
		my $ldapMsg = $ldap->bind( 'dn' => "$user_dn", 'password' => $password);
#print $DEBUGLOG "ldapmesg0:\n";
#print $DEBUGLOG Data::Dumper->Dumper($ldapMsg);
		if ($ldapMsg->{'resultCode'} ne '0') {
			$resp{'success'} = 'false';
			$resp{'errorMsg'} = "Error: Unknown User: $login or Bad Password";
		} else {
			my $ldap_string="cn=".$CONFIG::LDAP_USER.",".$CONFIG::LDAP_BASE;
			$ldapMsg = $ldap->bind( 'dn' => $ldap_string, 'password' => $CONFIG::LDAP_PASSWORD);
#print $DEBUGLOG "ldapmesg1: \n";
#print $DEBUGLOG Data::Dumper->Dumper($ldapMsg);
			if ($ldapMsg->{'resultCode'} ne '0') {
				$resp{'success'} = 'false';
				$resp{'errorMsg'} = "Error: Unknown User: $login or Bad Password";
			} else {
				#-------------------------------------------------------------------------------------------------
				# LDAP Search for user with login and password
				#-------------------------------------------------------------------------------------------------
				my $filter = "(&(sAMAccountName=$login)(|(objectCategory=person)(objectClass=User)))";
				my $ldapSearch = $ldap->search( 'base' => $CONFIG::LDAP_BASE, 'filter' => Net::LDAP::Filter->new($filter));
				if ($ldapSearch->{'resultCode'} ne '0') {
					$resp{'success'} = 'false';
					$resp{'errorMsg'} = "Error: Unknown User: $login or Bad Password";
				} else {
					$resp{'success'} = 'true';
				}
			}
		}
	}

#-------------------------------------------------------------------------------
#only matt gets admin enabled.
#-------------------------------------------------------------------------------
	if ($login eq 'mattplatts'){
		$resp{'admin'} = 'true';
	} else {
		$resp{'admin'} = 'false';	
	}

#print $DEBUGLOG Dumper %resp;
	#my $resp_json = encode_json(\%resp);
#print $DEBUGLOG Dumper $resp_json;
	return %resp;
}

# The following sub required for LDAP
sub ldapSafeName($) {
        my ($name) = @_;
        $name =~ s/^[ ]+//;
        $name =~ s/[ ]+$//;
        $name =~ s/([,+"\\<>;])/\\$1/g;
        $name =~ s/^#/\#/;
        $name =~ s/([^\040-\176])/sprintf("\%02x",ord($1))/eg;
        return $name;
}

# The following sub required for LDAP
sub GetbDistinguishedNameFromUserName($$) {
	my ($ldap, $user_name) = @_;

	my $mesg = $ldap->bind;
	$mesg = $ldap->search(base => "CN=Users,DC=internal,DC=cacheflow,DC=com",
                              filter => "(&(samAccountname=$user_name) )");
	$mesg->code && die $mesg->error;
	
	my($entry);
	my @all = $mesg->entries;

	foreach my $ent (@all) {
		foreach my $att (sort $ent->attributes ) {
     			if ( $att =~ m!\bdistinguishedName\b! ) {
				#$ldap->unbind;
				return ($ent->get_value($att));
      			}
		}
	}
	$ldap->unbind;
	return(0);
}

# give usage information if module is run directly on the command line 
__PACKAGE__->usage() unless caller;
sub usage {
	print <<EOT;
	Usage: Include the following line in your main script:

	use LDAP qw(ldap_authenticate ldapSafeName  GetbDistinguishedNameFromUserName);

	and call the main function using:

	LDAP::ldap_authenticate(\$username,\$password);
EOT
}
