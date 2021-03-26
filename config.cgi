#!/usr/bin/perl -w

package CONFIG;


############## REQUIRED CONFIG VALUES #####################

our $path 			= "git/perl-framework/api"; # must not include leading or trailing slashes. This *must* be correct or nothing will work. It should relate to the URL called (no cgi-bins reqd unless part of the url).
our $login_required 		= 1;  			   # login_required - set to 1 to force login for all routes (except the auth module in order to gain a login) . See the @no_login_required array below to allow certain routes.
our $limit_users 		= 1;  			   # limit users to a list defined here in the config file? If not, any LDAP success will allow a log in. Otherwise the username MUST be in the %valid_users hash below.
our $default_content_type	='application/json'; 	   # default content type specifies the MIME type of the document returned if it is not specifically made
our $use_dispatch_table 	= 0; 			   # use dispatch table? This is a table of allowed api calls, rather than automatically allowing any function in a controller to be used as an API call.
our $application_environment 	= "PRODUCTION"; 	   # PRODUCTION / DEV

# If a login is required for use, you can add paths to the "no login required" array to open up specific functionality to all. The api to perform a login needs to be listed here of course.
# The relate to controller/function in routing, or the sub named [function] in controllers/[controller]Controller.pm.
# Use defaultAction as the function name if only a single param is required.
our @no_login_required = (
	"default/defaultAction",	# A test url telling you everything is technically working ok. 
	"config/defaultAction", 	# Returns the required configuration values for the front end.
	"auth/login", 			# When logging in, obviously you don't have to be logged in
	"auth/authenticate", 		# Authenticating a user is part of the login script, where again obviously don't have to be logged in to log in..
);

our $SESSIONS_TIMEOUT = 60; 		  # Session timeout used by serssions.pm
our $SESSIONS_FOLDER  = "/tmp/sessions/"; # Session storage folder used by sessions.pm 

################## END REQUIRED VALUES ####################



# Allow editing through this interface?
our $allow_editing = 1;

# LDAP settings
our $ldap_auth=0; # turn ldap authentication on and off - otherwise will simply authenticate against the '%valid users' hash
our $LDAP_AUTH=0;

our $LDAP_USER = '';
our $LDAP_PASSWORD = '';
our $LDAP_SERVER = '';
our $LDAP_PORT = '';
our $LDAP_BASE = '';

# Hard coded array of valid users in addition to LDAP authentication.
# The random character string is stored as the cookie value, and is purposely obscure to stop cookie spoofing (no storing 1,2,3.. or actual names etc). 
# To add users, append to this hash with a *UNIQUE* random string as the hash value (there is no limitation as to length or chars used in this string)
our %valid_users = (
	'mattplatts@gmail.com'			=> '9RT6XSNLL0LL',
);

# If the user has administrator access, add their name here
our @admin_users = ('mattplatts@gmail.com');

# Hard coded array of valid IP addresses which can be used to access the system. NB: ::1 = localhost.
our $check_ip 	= 0; # turn IP address checking on/off
our @valid_ips 	= ('192.168.198.68','192.168.212.141','::1');


# USER PERMISSIONS
# Hash: tabs
# Meta: Values are binary keys - 1,2,4,8,16 etc. Permissions for the tab are gleaned from the users hash below by assigning a value from adding permitted tab values together
our %tabs = (

        "tab1" => 1,
        "tab2" => 2,
        "tab3" => 4,

);

# Hash: Users
# Meta: Keys are usernames, values are a binary representation of what is allowed fromm the %tabs has by adding up the numbers from the tabs user can access
our %admins = (

        'mattplatts@gmail.com' => 1,

);

our %frs_editors = (

        'mattplatts@gmail.com' => 1,

);
