#!/usr/bin/perl
# dispatch.pm
# Used for creating a dispatch-like table for code. 
# This can be checked as an additional security precaution rather than allowing the module to run functions unchecked.
# The %dispatch hash simply contains a list of url-accessible methods within the controllers as keys, with a positive value as the key value indicating
# that it can be dynamically called.

package dispatch;
use Data::Dumper;

my %dispatch;

# Controller functions which are permitted to run through the url routing can be specified here
# this feature can be turned on and off in config.cgi using the use_dispatch_table key.
# If turned off, any public function in a file in the controllers folder (does not start with underscore) can be called directly through a url. 
$dispatch{'auth'}{'login'} = 1; 
$dispatch{'auth'}{'logout'} = 1; 
$dispatch{'auth'}{'authenticate'} = 1; 
$dispatch{'search'}{'search_for'} = 1;
$dispatch{'search'}{'history'} = 1;
$dispatch{'entitlement'}{'get_entitlement'} = 1;
$dispatch{'template_demo'}{'do_demo'} = 1;
$dispatch{'phs'}{'getPhs'} = 1;

# public function, used to see if a value in %dispatch has been set.
sub dispatchValue {

	my $module = shift;
	my $func = shift;
	return $dispatch{$module}{$func}? 1 : 0;

}

1;

