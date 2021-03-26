#!/usr/bin/perl

use CGI;

print CGI::header(-type => 'text/html', -cookie=>[$__cookie],
		  -status => '500',
		);

print "okie";

exit;
