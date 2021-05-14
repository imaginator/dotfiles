#!/usr/bin/perl
#
# Tue Nov  4 17:37:18 GMT 2003
# Copyright Robin * Slomkowski
# 

use strict ;

my ( @dirs,
     $top_proc,
     $proc_dir,
     $dir,
     %proc_dirs,
     %ps_procs,
     %ps_vprocs,
     $debug,
     $last_pid,
     $virtual_pid,
     ) ;

# build the ps list

open PS, "ps -ef |" ;
while (<PS>) {
	my $pid ;
	$_ =~ /^\S*\s+(\d+)/ ;
	$pid = $1 ;
	if ( $pid == 0 ) {
		$virtual_pid = $last_pid + 1  ; 
		$_ =~ /\[(.*)\]$/ ;
		$ps_vprocs{$virtual_pid} = $1;
		$last_pid = $virtual_pid ;
	} else {
		$ps_procs{$pid} = 1 ;
		$last_pid = $pid ;
	}
}
close PS ;

# build the directory listing
opendir DIR, "/proc" ;
@dirs = readdir DIR ;
closedir DIR ;

@dirs = grep /[0-9]+/, @dirs ;
@dirs = sort { $a <=> $b } @dirs ;

foreach $proc_dir ( @dirs ) {
	$proc_dirs{$proc_dir} = 1 ;
}

$top_proc = $dirs[$#dirs] ;

# check the dirs

$dir = 0 ;
while ( $dir <= $top_proc ) {
	my $re ;
	$re = chdir "/proc/$dir" ;
	if ( $re ) {
	   if ( ! defined ($proc_dirs{$dir}) ) {
	        print "ERROR: not listable: /proc/$dir\n" ;
	  }
	  if ( ! defined ($ps_procs{$dir}) ) {
	  	print "WARN: not in ps: /proc/$dir" ;
		if ( defined ($ps_vprocs{$dir}) ) {
			print " - probable virtual thread [$ps_vprocs{$dir}]\n" ;
		} else {
			print "\n" ;
		}
	  }
	} else {
		print "cannot chrdir to $dir\n" if $debug > 0 ;
	}
	$dir ++ ;
}

exit 0 ;
