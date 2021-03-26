#!/usr/bin/perl
# helpers.pm

package helpers;

sub trim($) {
  my ($in) = @_;
  $in =~ s/[\n\s]//g;
  return $in;
}

1;
