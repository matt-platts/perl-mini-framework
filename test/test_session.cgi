#!/usr/bin/perl

use lib("lib");
use Data::Dumper;
use CGI;
use CGI::Cookie;

use sessions;

$session = new sessions;
print Dumper $session;

my $q = new CGI::Cookie;
$cookies = $q->fetch;
print Dumper $q;
