#!/usr/bin/perl
#
# convert a voice message and email it


use Net::LDAP;
use MIME::Lite;

$hostname = `hostname`;
$timestamp = `date`;

#
# some variables to customize
#
$recipient = 'voicemail';
$directory = 'ldap.bigfoot.com';
$directoryBase = '';
#$voiceServerAddress = "simon";
$voiceServerAddress = "Voice.Message\@$hostname";

# customization beyond this point should not be required

($filename,$callerid,$callname) = @ARGV;

$ldap = Net::LDAP->new($directory,
                DN => "",
                Password => "",
                Port => 389,
                Debug => 3,
        ) or
        die $@;

$tag = "newmessage";
if ($filename =~ /(.*)\.rmd$/) {
  $tag = $1;
}

$pvf = $tag . '.pvf';
$wav = $tag . '.wav';

# convert the rmd file to pvf format
system ("/usr/bin/rmdtopvf -8 $filename $pvf");

# convert pvf to wav
system ("/usr/bin/pvftowav $pvf $wav");

# clean up
system ("rm $pvf");

$directoryInfo = "\n\nDirectory Profile\n";
if ($callerid) {
		for $filter (
			 "(telephoneNumber=$callerid)"
			 ) {
			$results = $ldap->search(
			 base   => $directoryBase,
			 filter => $filter
			 ) or die $@;
		}
		
		foreach $entry ($results->all_entries) {
				foreach $attr (keys %{${%{$entry}}{attrs}}) {
				$directoryInfo .=  "$attr: " . 
						${${%{$entry}}{attrs}}{$attr}[0] . "\n";
}
}
}



# generate some useful info

$msg = new MIME::Lite
    From    => $voiceServerAddress,
    To      => "$recipient",
    Subject => "voice message received at $timestamp",
    Type    => 'multipart/mixed';

attach $msg 
    Type     => 'TEXT',   
    Data     => "archived pvf copy in $hostname:$filename\n" .
                "callerid: $callerid\n" .
                "callname: $callname\n" .
#		$directoryInfo;

attach $msg 
    Type     => 'audio/x-wav',
    Path     => "$wav",
    Encoding => 'base64',
    Filename => 'message.wav';

$msg->send;

# send a message to my cellphone

$msg = new MIME::Lite
    From    => $voiceServerAddress,
    To      => "voicemailsms@imaginator.com",
    Subject => "New home voicemail received at $timestamp",

$msg->send;


	    
#system ("touch /home/simon/test.touched");

sleep 5; # give the mail command time to complete

system ("rm $wav");
