#! /usr/bin/perl
#
# net-check by Aaron D. Marasco (Aaron@Marasco.com) - No warranties expressed nor implied.
#  PLEASE send me your comments! Even style ones if they are that horrible. 
#
# My DSL connection seems quirky, at best. This is to be a 15 minute cron job to "touch base"
# and make sure that the net is still up. If not I plan on fighting for some credit. ;)
#
# If it cannot connect 2 runs in a row, it forces the machine to reconnect.
#
#
# 1.0 - ADM -  4 Mar 2000 - Initial release.
# 1.1 - ADM -  7 Mar 2000 - Made some fixes if the net is fully down (was getting blank which said net was up!)   
#                     Changed log format to be a little more human readable.
# 1.2 - ADM - 10 Mar 2000 - Nuttin. Like to keep version numbers matching. ;)
# 1.3 - ADM - 12 Apr 2000 - Modified ping command line to timeout in 30 seconds.
# 1.4 - ADM -  1 May 2000 - Still had blank returns meaning connected! (Note every time I update is when DSL is down!) 
#                     Added $restart_conn too because killall -HUP didn't help if pppd gave up.
#
# Setup:
# Where to store log file (make sure this matches in net-report.pl)
$MainLog = "net-checks";
# Where to store temporary down file
$DownFile = "net-is-down";
#
# HOW TO SETUP: Look thru these notes, and then when done comment this line:
$debug = 1;
# Who to reset.
$pppd = "pppd";
# Some people do not use PPP. If not, uncomment the next line.
# $customkill = 1;
# Custom kill command. Put here something that should resync your connection. Maybe a script to tickle eth0...?
$customkillcmd = "/bin/more /dev/null"; # Default is obviously fake. Send suggestions to e-mail above. 
# What is the threshold you are willing to accept? Under 10 is probably unrealistic since answering pings is low priority.
$thresh = 21; # Loss will always end in 0 (10 packets). This allows 10% and 20%.
# A router at your ISP. Find one by picking the 2nd or 3rd IP displayed in a traceroute.
# I wouldn't use any generic IP but you can if you want.
# Example: "4\.1\.25\.233" Note that you need \ before each "."...
$router = "209\.232\.130\.154";
# Executables. I like full paths because more secure to specify EXACTLY what external command to run.
# Executable rm
$rm = "/bin/rm";
# Executable killall (Linux only?).
$killall = "/usr/bin/killall";
# Bring it back (set as "/bin/more /dev/null" if not needed). 
$restart_conn = "/usr/sbin/pppd";
# Executable ping
$ping = "/bin/ping";
#
#### End of User Servicable Parts. ;)
$lossloc = 6; # This may change if ping ever changes...
if ($debug == 1) { 
	print "Setup mode is on, running ping test...\n";	
	@pingdat_raw = `$ping -c 1 -n -q $router`;
	for ($item = 0; $item < (scalar @pingdat_raw); $item++) {	
		print $item,": ",@pingdat_raw[$item];
	};
	@lossline = grep /packet loss/, @pingdat_raw;
	print "\n-\> ",@lossline[0];
	@splitline = split(' ',@lossline[0]);	
	chop (@splitline[$lossloc]);
	print "\nI think that there was ",@splitline[$lossloc],"% packet loss. If I am wrong, you need to contact\nthe author, please.\n"; 
	if ($customkill == 1) {
		print "\nCurrent connection mode is NOT PPP. If net is down 2x,\nI will \"",$customkillcmd,"\".\n";
	} else {
		print "\nCurrent connection mode is PPP based. If net is down 2x, I will respawn \"", $pppd, "\".\n";
	};
	print "Please open this program in an editor to finish setup and disable this message.\n";
} else {   
	@pingdat_raw = `$ping -c 10 -w 30 -n -q $router`; #10 pings should be sufficient
	@splitline = split(' ',@pingdat_raw[ (scalar @pingdat_raw -2) ]);
	chop (@splitline[$lossloc]);
	$pingcnt = @splitline[$lossloc];
	if (length $pingcnt == 0) {$pingcnt = 100};
	if ($pingcnt > $thresh) {
		if (-e "$DownFile") {
			# Network was down last time too, time to reconnect.
			if ($customkill == 1) {
				$fake = `$customkillcmd`;
			} else {
				$fake = `$killall $pppd`;
			};
			sleep 5;
			$fake = `$restart_conn`;
			unlink "$DownFile";
		} else {
			# Network is down now but up last time. Let it slip, but do not forget.
			open DOWNFILE_H, ">$DownFile"; # If it fails, nothing to die for.
			close DOWNFILE_H;
		}; 
	} else {
		# Below threshold so net is up
		if (-e "$DownFile") {
			unlink "$DownFile"; # Since we are up
		}; # File exist
	}; # Net up/down
	# Whether up or down, we want to store off our number for the net-report program.
	open LOGFILE, ">>$MainLog";
	if ($pingcnt > $thresh) {
		print LOGFILE "0 ";
	} else {
		print LOGFILE "1 ";		
	};
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);	
	$min = sprintf ("%0.2d", $min); # make 0 into 00
	print LOGFILE $mday," ",$hour,":",$min," - ",$pingcnt,"% loss\n";
	close LOGFILE;
};
