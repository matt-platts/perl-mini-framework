#!/usr/bin/perl


package master;

sub new {
	my $class = shift;
	my $self = {
		value => "1",
	};
	bless $self,$class;
	return $self;
}

sub defaultAction {

	my $self = shift;
	print @_;

	return "value of default action";
}

1;

#########################
package child;
@ISA = (master);


package MAIN;

$x = new child;
print "X is " . $x;

$func = "defaultAction";


$y = $x->$func(1,2);
print $y;

