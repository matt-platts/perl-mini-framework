#permissions.pm

package permissions;
use CGI::Cookie;
use Data::Dumper;

sub check_group {
	my $group = shift;
	my $grouplist = shift;

	print "Checking for $group in ";
	print Dumper $grouplist;
}

sub load_groups {

my $groups = AUTH::get_groups_from_session();
return $groups;

}

1;
