#!/usr/bin/perl
#view_json.pm


package view_template;
use JSON;

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
	} elsif ($$response{'content'}){
		$self{'renderText'} = $$response{'content'};
	}
	
	# templating
	# template should have been set by the base from config, or by an individual controller.
	if (!$$response{'template'}){
		$$response{'template'} = "default_template.html";
	}
	$renderText = &__stl_template($$response{'template'},$response);
	# set globals
	$errorMessage = $$response{'errorMessage'};
	$success = $$response{'success'};
	$error = $$response{'error'};
	return $renderText;
}

sub print {

	my $self = shift;
	my %response = shift;

	my $content = $renderText ; # we could get this from global scope of $renderText; - NOT $$response{'content'}
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
	my $result = $response{'content'}; 
	print $result;
}


# function: template
# meta: populate a template with basic tags only with values from the response hash 
# param: filename - name of file in /views/templates directory to use as the view template
# param: fillings (hash reference) - hashref of key value pairs with which to populate the view
sub __template {
	my ($filename, $fillings) = @_;
	$filename = "views/templates/$filename";
	my $text;
	local $/;
	local *F;
	open(F, "< $filename\0") || return;
	$text = <F>;
	close(F);
	$text =~ s{ {= ( .*? ) } }
	{ exists( $fillings->{$1} )
	      ? $fillings->{$1}
	      : ""
	}gsex;
	return $text;
}


# function: __stl_template
# meta: populate a template with values from the response hash, template also uses simple template language (stl) tags (see lib/stl_parser.pm) 
# param: filename - name of file in /views/templates directory to use as the view template
# param: fillings (hash reference) - hashref of key value pairs with which to populate the view
sub __stl_template{

	my ($filename, $fillings) = @_;
	$filename = "views/templates/$filename";
	my $text;
	local $/;
	local *F;
	open(F, "< $filename\0") || return;
	$text = <F>;
	close(F);

	use stl_parser;
	my $result = stl_parser::parse_stl($text,$fillings);
	return $result;
}

1;
