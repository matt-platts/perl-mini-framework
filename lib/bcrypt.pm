#!/usr/bin/perl
# bcrypt.pm

#usage
#my $enc = bcrypt::encrypt("testing");
#print $enc . "\n\n";

#my $res = bcrypt::check_password("testing",$enc);
#print "Result is " . $res;

package bcrypt;

#use Crypt::Eksblowfish::Bcrypt qw(bcrypt_hash en_base64 de_base64 bcrypt);
#use Crypt::Random;
use Authen::Passphrase::BlowfishCrypt;
use Data::Dumper;

sub encrypt {

	my $password = shift;

	my $ppr = Authen::Passphrase::BlowfishCrypt->new(
		cost => 12, 
		salt_random => 1,
		passphrase => "$password");
	my $hash = $ppr->hash_base64;
	my $salt = $ppr->salt_base64;

	my $str = "\$2a\$10\$" . $salt . $hash;
	return $ppr->as_rfc2307;
}

sub check_password {

	my $password = shift;
	my $existing = shift;

	my $blowfish = Authen::Passphrase->from_rfc2307($existing);


	if ($blowfish->match($password)) {
		return 1;
	}
	return 0;
}

