#!/usr/bin/perl
#exampleModel.pm

package exampleModel;

# Sub: doSomethingTechnical
# Meta: technical stuff and business logic should go into model files
sub doSomethingTechnical {

	my $value = shift;

	my $response;
	my $error;
	my $success;
	my $error_message;

	# code here to connect to db, service etc. Below is just example playing with the data.
	
	if ($value =~ /^[a-zA-X0-9]+$/){
		$response = "Response for input of $value";
		# $response may also contain hash keys (which are auto-converted to json in a json view, or replaced in a template in template view)
		$success=1;
		$error=0;
	} else {
		$response = "Illegal input";
		$success=0;
		$error = 1;
		$error_message = "You can only use letters and numbers in your input to the 'example_value' paramater.";
	}
	
	my %response = (
		response=>$response,
		error=>$error,
		success=>$success,
		errorMessage=>$error_message,
	);
	return \%response; # return reference to hash

}

1;
