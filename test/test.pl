#!/usr/bin/perl

use Crypt::Eksblowfish::Bcrypt qw(bcrypt_hash en_base64 de_base64 bcrypt);

my $salt = "saltymmmyeah1433";
$password="yorick";

$hash = bcrypt_hash({ 
	key_nul => 1,
	cost => 8,
	salt => $salt,
	}, $password);

$settings = (
	key_nul => 1,
	cost => 8,
	sale => $salt,
);

$hash = en_base64($hash);

print "hash is $hash\n";

$pw = bcrypt($password,$settings);




exit;


$s = "cahce-pulse-op/caihjuasd-wer-wer.cgi";

@fs=split(/\//,$s);
print $fs[$#fs];
exit;

$this = "something/something-else,something/another-something";
@bits = split(/\//,$this);
print $bits[0];
exit;

print &get_sync_link(3715300054,"Kaspersky") . "\n";
print &get_sync_link(3715300054,"FileInspection") . "\n";



sub get_sync_link {

        my $serial_number = shift;
        my $feature_name = shift;

        my %features_matrix = (
                Kaspersky => "kaspersky/kaspersky.cgi",
                CPOS => "cache-pulse-policy/cache-pulse-policy.cgi",
                Sophos => "sophos/sophos.cgi",
                McAffee => "mcaffee/mcaffee.cgi",
                Cylance => "cylance/cylance.cgi",
                WAP => ["geoip/geoip.cgi","app-protect/app-protect.cgi"],
                FileInspection  => ["cylance/cylance.cgi","filewhitelisting/filewhitelisting.cgi"],
        );

	my $return;
        if ($features_matrix{$feature_name}){

		if (ref($features_matrix{$feature_name}) eq "ARRAY"){
			$return = join(",",@{$features_matrix{$feature_name}});
		} else {
			$return = $features_matrix{$feature_name};
		}
        } else {
                return;
        }
                                  
	return $return;

}
