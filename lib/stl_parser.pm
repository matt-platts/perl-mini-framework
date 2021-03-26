#!/usr/bin/perl
# stl_parser.pm
# Parse Simple Template Language files and data hashes - see documentation section at the bottom of this script for more info.

package stl_parser;

use strict;
use Data::Dumper;

# sub: parse_stl
# meta: parse simple template language
sub parse_stl {
	my $input = shift;
	my $input_values = shift; 
	my %values = %$input_values; # simple dereference because the original code contained a hash and not a hashref

	my $output = $input;

	#Basic value replace first - does not take into account 'if', 'and', 'or'..
	foreach my $value (keys %values){
		my $test = "{=$value}";
		$output =~ s/$test/$values{$value}/g;
	}

	# Now we look for {=if...{=end if}
	my @matches = $output =~ /({=if ((?:!?\w+[,;+|]?)+ ?=? ?[\w ]+)}(.*?){=end[ _]?if})/g;
	print Dumper @matches;

	for (my $i=0;$i<@matches.length;$i++){ # for each =if block

		# have we got characters representing an OR or AND match?
		my @all_keys = ();
		my @temp_keys = ();
		my $and_or_or;
		if ($matches[$i+1] =~ /[,;+|]/){
			@temp_keys=split(/([,;+|])/,$matches[$i+1]);
			foreach my $var(@temp_keys){
				if ($var ne "," && $var ne ";" && $var ne "|" && $var ne "+"){
					push(@all_keys,$var);
				} else {
					$and_or_or=$var;
				}
			}
		} else {
			$all_keys[0]=$matches[$i+1];
		}

		my $expression_passes=1;
		my $partial_expression_passes=0;
		foreach my $var (@all_keys){

			# positive or negative match
			my $negative_match=0;
			if (substr($var, 0, 1) eq "!"){
				print "neg match for $var\n";
				$negative_match=1;
			};

			# check for value in match template query
			if ($var =~ /=/){
				my ($key,$value)=split(/=/,$var);

				# check for negative match with a value
				my $negative_match_with_value=0;
				if (substr($var,0,1) eq "!"){
					$negative_match=1;
					$negative_match_with_value=1;	
					$var =~ s/^\!//;
				}

				if (!$negative_match_with_value && $values{$key} eq $value){
					print "on here";
					$var=$key; # just set the key to the value and continue as normal
					$partial_expression_passes=1;
				} elsif ($negative_match_with_value && $values{$key} ne $value){
					$var=$key; # just set the key to the value and continue as normal
					$partial_expression_passes=1;
				} else {
					print "no pass";
					$expression_passes=0;
				}
			} else {
				$var =~ s/^\!//;
			} 

			if (__hasValue($values{$var}) && !$negative_match){
				$partial_expression_passes=1;
			} elsif (!__hasValue($values{$var}) && $negative_match) {
				print "hargh";
				$expression_passes=1;
			} elsif (!__hasValue($values{$var}) && !$negative_match) {
				print "arthur";
				$expression_passes=0;
			} elsif (__hasValue($values{$var}) && $negative_match){
				print "frank";
				$expression_passes=0;
			}

		}

		$matches[$i] =~ s/\+/\\\+/g;
		$matches[$i] =~ s/\|/\\\|/g;
		if ($expression_passes || (($and_or_or eq ";" || $and_or_or eq "|") && $partial_expression_passes)){
			$output =~ s/$matches[$i]/$matches[$i+2]/;
		} else {
			$output =~ s/$matches[$i]//;
		}

		$i++;
		$i++;
	}

	return $output;
}

# sub: __hasValue
# meta: Test if a tag has value. 
#       The reason for the boolean test AND the length of 1 is to find occurrunces of 0 which *are* a value which should be included.
#       Just remove the "|| length($input)==1" part of the code to make a value of 0 equate to a boolean false
#       Only an empty string or missing hash key generates a falsey value unless this function is changed. Why? See (3) below
sub __hasValue {

	my $input = shift;

	if ($input || length($input)==1){
	#if (($input || length($input)==1) && $input ne "null"){ # use this line instead if you want the string 'null' to actually appear as null
		return 1;
	} else {
		return 0;
	}
}
1;

__END__

DOCUMENTATION
=============

Simple Template Language (stl) is purposely *almost* the simplest template language there can be whilst having some real world practical use just above straight up inserting of values into tags.
It is designed to save the effort of writing classes purely to template data with very minimal processing such as very few basic 'if' statements. 
It is NOT designed to excuse you from writing code where you should do. If this doesn't do what you want it to do, you should probably be writing some code instead.

The parser will accept a template and a hash/associative array of values, and do the following.

* Replace tags in the format {=tagname} with the value of the key of 'tagname' in the hash/associtive array.
* Replace tags in the format {=if tagname} some content {=end if} with the part of the template between the 'if' and 'end if' tags IF the tag exists and contains any content at all (including 0) 
* Allow very basic 'and' and 'or' rules to these 'if' statements. 
	Eg:  {=if tag1+tag2} We have both tag 1 and tag2 {=end if} 
	Eg2: {=if tag1|tag2} We have either tag 1 or tag 2 (and we might have both!) {=end if}
* Allow negation using '!' 
	Eg.  {=if tag1+!tag2} We have tag 1 but not tag 2 {=end if} 
	Eg2. {=if !tag1|tag2} We have either not got tag 1 or we have tag 2 {=end if}. 
	Note that the ! only applies to the immediately following tag and not the whole expression. 
* Allow basic equality testing. 
	Eg. {=if tag1=Yes}Value is 'yes'{=end_if}
	Eg2. {=if tag2=Value of tag 2} {=tag3} {=end_if} # insert tag3 if tag2 = 'Value of tag 2' (case sensitive)
* Combine many of the above rules (see ** for limitations below) 
	Eg:  {=if tagname+!other_tag+anothertag=thisvalue} {=value_of_yet_other_tag} and {=yet_another_tag_here} {=end_if}

Notes and limitations: 
----------------------
No parentheses or specified order of precedence for mixing and/or queries together. So Don't. 
No else/elseif, you'll need separate expressions.
+ and | are logical NOT mathematical operators so no on-the-fly addition etc.
Basic boolean testing HOWEVER: The ONLY false values by default are an empty string or a non-existent hash key (See (1) below)
You CANNOT nest {=if} tags.
** - only ONE equality test per expression, which must be the last test you do (See (2) below) in the 'if' statement. 

Footnotes:
---------
(1) - the __hasValue specifically allows 0 to pass as a truthy value rather than the default false. Type is not taken into account so 0 and '0' are treated the same. If you want 0 to be false edit the __hasValue function

(2) - because it becomes far more complex to do this as a regex otherwise. Multiple splits on strings would work but this is not meant to be a whole language, just a very basic data templater. The fact that even one works when mixed with others was not planned just how the code came out.

(3) - Why should 0 evaluate to true by default? Because this was written for parsing database records, which often contained 0 as a field value that I wanted to print and test on. Actual nulls you don't want to display should be converted to blank strings in the code before this part ran. Or, edit the __hasValue function to do your own test.

Example:
--------

$input = "Complex if: {=if value8+!value7+value9=something}Expression passed{=end if}";

%keys = (
	value1 => "Value of value 1",
	value2 => "0", 
	value3 => 0, 
	value4 => 9, 
	value5 => "0 but true", 
	value6 => null, 
	value7 => '', 
	value8 => 'null', 
	value9 => "something",
);

$response = stl_parser::parse_stl($input,\%keys);

print "REPONSE: " . $response . " END RESPONSE";
exit;
