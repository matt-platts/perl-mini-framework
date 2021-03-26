#!/usr/bin/perl
#view_json.pm


package view_json;
use JSON;
use Data::Dumper;

#Sub: new
#Meta: view constructor function
sub new {

	my $class = shift;

	my $self = {
		renderText => "",
		error => "",
		errorMessage => "",
		errorCode => "",
		success => "",
	};

	bless $self,$class;
	return $self;
}

sub render {

	my $self = shift;
	my $response = shift;

	if ($$response{'error'} && $$response{'errorMessage'}){
		$self{'renderText'} = $$response{'errorMessage'};
		$self{'errorMessage'} = $$response{'errorMessage'};
		$self{'success'} = $$response{'success'};
		$self{'errorCode'} = $$response{'errorCode'};
	} elsif ($$response{'content'}){
		$self{'renderText'} = $$response{'content'};
	}

	$self{'errorMessage'} = $$response{'errorMessage'};
	$self{'success'} = $$response{'success'};
	$self{'error'} = $$response{'error'};
	$self{'errorCode'} = $$response{'errorCode'};

	return $self{'renderText'};
}

sub print {

	my $self = shift;
	my %response = shift;

	my $content = $$response{'content'} ; # we could get this from global scope of $renderText;
	if (!$content){
		$content = $self{'renderText'}; # and we do if not supplied
	}
	my %response = (
		"content" => $content,
		"error" => $self{'error'},
		"success" => $self{'success'},
		"errorMessage" => $self{'errorMessage'},
		"errorCode" => $self{'errorCode'},
	);
	my $result = encode_json(\%response);
	print $result;
}
1;
