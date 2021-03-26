#!/usr/bin/perl -w
# sessions.pm
# Session management module 

# NB: This is a MODIFIED version of the session.pm found in other places in Blue Coat.
#
# Mods: 
# 	1) Cookie 'user' is looked up to get the session id if it is not sent in. This is always used if it exists rather than just generating a new session id. This is more logical than having to look up the session ID outside of the module and pass it in.

#       2) CGI param 'username' is used to populate the username field of the session file when it is created.

package sessions;

use strict;
use Data::Dumper;

use constant SESSIONS_FOLDER  => "/tmp/register_ra_sessions/";   # /tmp/systemd-private-9d2aaccab803407dab371b4ea208c678-httpd.service-KpTXNz/tmp/register_ra_sessions
use constant SESSIONS_TIMEOUT => 60;      #60 minute timeout for session files

sub Save_recursive($$$); # needs to be here to quash 'called too early to check prototype' error. Could be removed if you add the ampersand before the call name

###########################################
###
### new (session_id (optional))
### session_id = identifier of session; if not sent the cookie is looked up. If no session is not found, a new ID is created
###
### returns: $session object
### all new sessions have $session->{ID} prepopulated
###
###########################################

sub new($$$) {

    my ($proto, $session_id,$grouplist) = @_;
    my $self = {};
    my $class = ref($proto) || $proto;
    bless($self, $class);

    $self->{'grouplist'} = $grouplist;
    # do we have an existing cookie?
    if (!$session_id){
	    $session_id = &Retrieve_Cookie("user");
    }

    $self->{SESSIONS_FOLDER}  = SESSIONS_FOLDER;
    $self->{SESSIONS_TIMEOUT} = SESSIONS_TIMEOUT;
    unless(-d $self->{SESSIONS_FOLDER}) {
        mkdir $self->{SESSIONS_FOLDER};
        unless(-d $self->{SESSIONS_FOLDER}) {
           die "Cannot access session folder ".$self->{SESSIONS_FOLDER};
        }
    }
    $self->Clear_Files_Session();
    if($session_id) {
        $self->{ID} = $session_id;
        if($self->Read_Session()) {
            return $self;
        }
    }
    $self->Create_Session();
    return $self;
}

sub DESTROY {
    my ($self) = @_;
    $self->Save_Session();
}

#############################
###
### Save_Session ()
### session = session hash variable
###
### Saves session hash up to 4 levels deep
###
#############################
sub Save_recursive($$$) {
    my ($fh, $var, $prefix) = @_;
    my $sep = (ref($var) eq "sessions"?"":">");
    if(ref($var) eq "HASH" || ref($var) eq "sessions") {
        foreach my $sub_var (keys(%{$var})) {
             Save_recursive($fh, $var->{$sub_var}, $prefix . $sep . $sub_var);
        }
    } else {
        #$hs->{$prefix} = $var;
        print($fh $prefix . "=" . Encrypt_Session_string($var) . "\n");
    }
}
sub Save_Session($) {
    my ($self) = @_;
    unless($self->{ID}) {
        return;
    }
#    my %HASH;
#    my $filename = $self->{SESSIONS_FOLDER} . $self->{ID};
#    if (tie(%HASH, 'SDBM_File', $filename, O_RDWR|O_CREAT, 0666) ) {
#        %HASH = {};
#        Save_recursive(\%HASH, $self, "");
#        untie %HASH;
#    } else {
#        delete $self->{ID};
#    }

    local(*SES_FILE);
    open(SES_FILE, ">".$self->{SESSIONS_FOLDER} . $self->{ID}) || die "Cannot create session file";
    Save_recursive(\*SES_FILE, $self, "");
    close(SES_FILE);
}

###########################################
###
### Create_Session ()
###
### returns: nothing
### all new sessions has $session->{ID} prepopulated
###
###########################################

sub Create_Session($$) {
    my $self = shift;
    my $groups = shift;
    my $session_id = time;
    my $is_bad = 1;
    while($is_bad) {
       for(my $x=0;$x<16;$x++) {
           $session_id .= chr(int(rand(25))+65);
       }
       unless(-e $self->{SESSIONS_FOLDER} . $session_id) {
          $is_bad = 0;
       }
    }
    $self->{ID} = $session_id;
    if (!$self->{'username'}){
	use CGI;
	my $q = new CGI;
	$self->{'username'}= $q->param("username");
	my @name_parts = split(/[._]/,$self->{'username'});
	$self->{'first_name'}= shift (@name_parts); # shift first part of username off array into first name
	$self->{'last_name'}= join (" ", @name_parts); # join rest of name to give last name
	$self->{'memberOf'}=$self->{'grouplist'};
#        use lib ("lib");
#        use debug;
#        my $debugger = new debug ;
#	 $debugger->debug_log("Session id:");
#	 $debugger->debug_log($session_id);
#	 $debugger->debug_log("Params");
#        $debugger->debug_log($q->param());
#	 $debugger->debug_log("Url Param");
#        $debugger->debug_log($q->url_param());

    }
    $self->Save_Session();
}

###########################################
###
### Read_Session ($session_id)
### session_id = identification string of the session
###
### returns: 1 if file was found
###          or returns 0 if not found
###
###########################################

sub Read_Session($) {
    my ($self) = @_;
    
    open(SES_FILE, "<".$self->{SESSIONS_FOLDER} . $self->{ID}) || return 0;
    my @lines = <SES_FILE>;
    close(SES_FILE);

#    my $filename = $self->{SESSIONS_FOLDER} . $self->{ID};
#    if (tie(%HASH, 'SDBM_File', $filename, O_RDWR|O_CREAT, 0666) ) {
#      foreach my $key (keys(%HASH)) {

      foreach my $line (@lines) {
        chomp($line);
        my ($key, $val) = split(/=/, $line);
        my @keys = split(/\>/, $key);
        my $key_nr = @keys;
        my $cur_var = $self;
        for(my $i=0; $i<$key_nr-1; $i++) {
            unless(defined $cur_var->{$keys[$i]}) {
               $cur_var->{$keys[$i]} = {};
            }
            $cur_var = $cur_var->{$keys[$i]};
        }
        $cur_var->{$keys[$key_nr-1]} = Decrypt_Session_string($val);
      }
    return 1;
}

###########################################
###
### Delete_Session ()
### session_id = identification string of the session
###
### Deletes session file
###
###########################################

sub Delete_Session($) {
    my ($self) = @_;
    unlink ($self->{SESSIONS_FOLDER} . $self->{ID});
    
#chmod (0777, $self->{SESSIONS_FOLDER} . $self->{ID});
#print ("Content-type: text/html\n\n");
#print ($self->{SESSIONS_FOLDER} . $self->{ID}."|||");
#print (unlink ($self->{SESSIONS_FOLDER} . $self->{ID}));
#exit 0;

    foreach my $key (keys(%{$self})) {
       delete $self->{$key};
    }
}

###########################################
###
### Decrypt_Session_string ($input)
### input = encrypted session string
###
### returns: decrypted session string
###
### Session strings are encrypted by replacing each
### character with its ASCII value, with spaces
### between all numbers. 
### Example: 'hallo' => '104 101 108 108 111'
###
###########################################

sub Decrypt_Session_string($) {
    my ($val) = @_;
#    my @chrs = split(/ /, $val);
#    my $value;
#    while(my $tmp = shift(@chrs)) {
#        if(IsNumeric($tmp)) {
#            $value .= chr($tmp);
#        }
#    }
    $val =~ s/&equal;/=/g;
    $val =~ s/&enter;/\n/g;
    return $val;
}

###########################################
###
### Encrypt_Session_string ($input)
### input = arbitrary string to encrypt
###
### returns: encrypted session string
###
### Session strings are encrypted by replacing each
### character with its ASCII value, with spaces
### between all numbers. 
### Example: 'hallo' => '104 101 108 108 111'
###
###########################################

sub Encrypt_Session_string($) {
    my ($str) = @_;
    
    $str =~ s/=/&equal;/g;
    $str =~ s/\n/&enter;/g;
#    my $res = "";
#    for (my $x=0; $x<length($str); $x++) {
#        $res .= ord(substr($str, $x, 1)) . " ";
#    }
    return $str;
}

###########################################
###
### Clear_Files_Session ()
###
### Scans all files in SESSIONS_FOLDER. If a
### modify time for a file is greater than 
### SESSIONS_TIMEOUT, then the file is deleted.
###
###########################################

sub Clear_Files_Session($) {
    my ($self) = @_;
    opendir (SES_FILES, $self->{SESSIONS_FOLDER}) || die "Cannot access session folder";
    my @files = readdir(SES_FILES);
    closedir SES_FILES;
    
    my $cur_time = time;
    
    foreach my $file (@files) {
        my $mtime = (stat($self->{SESSIONS_FOLDER} . $file))[9];
        if($mtime) {
            if($cur_time -  $mtime> $self->{SESSIONS_TIMEOUT} * 60) {
                unlink($self->{SESSIONS_FOLDER} . $file);
            }
        }
    }
}

###########################################
###
### IsNumeric ($InputString)
###
### returns: 1 if input string contains only
###          numeric characters, 0 otherwise
###
###########################################

sub IsNumeric($) {
    my ($InputString) = @_;
    if ($InputString !~ /^[0-9]*$/) {
            return 0;
    }
    else {
            return 1;	
    }	
}

sub Retrieve_Cookie{
   my ($cookiename) = @_;
   my @cookies = split(/\s*;\s*/, $ENV{'HTTP_COOKIE'});
   foreach (@cookies){
     my @tokens = split(/=/, $_);
     return $tokens[1] if($tokens[0] eq $cookiename);
   }
   return '';
}

1;

