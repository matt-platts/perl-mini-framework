#!/usr/bin/perl

use Crypt::Eksblowfish::Bcrypt qw(bcrypt_hash en_base64 de_base64 bcrypt);
use Crypt::Random;
use Authen::Passphrase::BlowfishCrypt;
use Data::Dumper;

my $salt = &salt; 
$password="yorick";

$hash = bcrypt_hash({ 
	key_nul => 1,
	cost => 8,
	salt => $salt,
	}, $password);

$hash = en_base64($hash);

$str = "\$2a\$10\$" . en_base64($salt) . " - that was the salt - " . en_base64($password);

my $ppr = Authen::Passphrase::BlowfishCrypt->new(
	cost => 12, 
	salt_random => 1,
        passphrase => "$password");
my $hash = $ppr->hash_base64;
my $salt = $ppr->salt_base64;

my $str = "\$2a\$10\$" . $salt . $hash;
print "String from Authen::Passphrase: " . $str . "\n\n" . "x" x 50 . "\n\n";

$newpassword = Authen::Passphrase::BlowfishCrypt->from_crypt($str);
print "This is the hash: ";
print Dumper en_base64($newpassword->{'hash'});
print "This is the salt :";
print Dumper en_base64($newpassword->{'salt'});


print "\n\n";
print "Now lets take the salt, re-encrypt the password with it: \n";


my $newppr = Authen::Passphrase::BlowfishCrypt->new(
	cost => 12, 
	salt => $newpassword->{'salt'},
        passphrase => "$password");

my $newone = $newppr->hash_base64;
print "-" x 50 . "\n";
print Dumper "It is " . $newone . " - which is the same hash";

if ($newppr->hash_base64 eq $hash){
	print "ITS THE SAME!!";
}


$settings = (
	key_nul => 1,
	cost => 8,
	sale => $salt,
);

#$pw = bcrypt($password,$settings);



exit;

sub salt {
	return Crypt::Random::makerandom_octet(Length => 16);
}
