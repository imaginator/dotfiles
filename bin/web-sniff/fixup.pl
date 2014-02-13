#!/usr/bin/perl

use Socket;
use MIME::Base64;

$|=1;
while (<>) {
    next unless ($host,$client,$msg) = /(\S+) -> (\S+)\s+(.*)\s+/;
    $msg=~s/(Authorization:\s+Basic\s+)(\S+)/$1 . decode_base64($2)/e;
    print lookup($host)," -> ",lookup($client),"\t$msg\n";
}

sub lookup {
    my $addr = shift;
    my $lookup =  (gethostbyaddr(inet_aton($addr),AF_INET))[0];
    return $lookup || $addr;
}
