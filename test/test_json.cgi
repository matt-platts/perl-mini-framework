#!/usr/bin/perl

print "Content-type:text/html\n\n";

use JSON;
require("config.cgi"); # api and user config settings
print $CONFIG::allow_editing;
print @CONFIG::admin_users;
print "ok";

my %response = (
	error => 1,
	success => 0,
);

print encode_json(\%response);

print "ok";
exit;

