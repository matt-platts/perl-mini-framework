#!/usr/bin/perl
# dbconnect.pm
#
package dbconnect;
use DBI;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw();
@EXPORT_OK = qw($dbh);

require ("config.cgi");
our $dbh = DBI->connect( $CONFIG::db_name, $CONFIG::db_user, $CONFIG::db_pass) || die("Cant conect to database server: " . $!);
