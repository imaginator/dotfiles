#! /usr/bin/perl
#
# net-report by Aaron D. Marasco (Aaron@Marasco.com) - No warranties expressed nor implied.
#  PLEASE send me your comments! Even style ones if they are that horrible.
#
# Please see net-check.pl for commentary.
#
#
# 1.0 - ADM -  4 Mar 2000 - Initial release.
# 1.1 - ADM -  7 Mar 2000 - Cleaned dollar output with sprintf instead of crappy way I will not even mention.
# 1.2 - ADM - 10 Mar 2000 - Added "Calendar" Feature and the pretty HTML stuff.
# 1.3 - ADM - 28 Mar 2000 - Got my Bell Atlantic bill the other day... not the 30th. ;)
# 1.4 - ADM -  1 May 2000 - Nuttin. Like to keep version numbers matching. ;)
#
# Setup:
# Where to store log file (make sure this matches in net-check.pl)
$MainLog ="net-checks";
# E-mail report address (use \@ for @ symbol)
$mailto = "simon\@imaginator.com";
# How much are you charged monthly?
$bill = 49.99;
# Would you like the proof emailed also? Uncomment this:
$verbose = 1;
# Do you use a HTML smart browser (not MSOE)? If so, this will allow nicely formatted info:
$htmlon = 1;
# Executables. I like full paths because more secure to specify EXACTLY what external command to run.
# Your 'mail' program
$mail = "/usr/bin/mail";
#### End of User Servicable Parts. ;)
# $debug = 1;
open LOGFILE, "+<$MainLog";
$samples = 0;
$downs = 0;
while (<LOGFILE>) {
	@splitline = split(' ',$_);
	if (@splitline[0] == "0") {
		# Net was down for this sample
		$downs++;		
		@downarray[@splitline[1]]++; # Increment count for this date.
	};
	$samples++;
} # Parsing file
close LOGFILE;
# Store off the log file (/var/log/net-checks.mm-yyyy)
$RotateLog = "/var/log/net-checks.".(localtime)[4]."-".(1900+(localtime)[5]);
rename "$MainLog", "$RotateLog" unless $debug;
$length_of_last_month = (time - ((localtime)[3])*24*60*60); # now - todays_date*24hr*60min*60sec
$lastmonth = ((localtime($length_of_last_month))[3]);
print "Last month had ".$lastmonth." days\n" if $debug;
$downhours = ($downs * 0.25);
$monthhours = ($lastmonth * 24);
$htmlon ? ($nl = "<BR>\n") : ($nl = "\n");
$htmlon ? ($Textstr = "<HTML><HEAD><META CREATOR=\"Aaron D. Marasco\">\n<STYLE TYPE=\"text/css\">\n{font-family=\"Courier\"}\nSPAN.AARONCSS {font-family=\"Courier\"}\n</STYLE>\n</HEAD><BODY>\n<Span CLASS=AARONCSS>") : ($Textstr = "");
$Textstr .= "Last month, there were ".$downhours." hours of downtime out of ".$monthhours." possible hours.".$nl;
if ($samples != ($lastmonth * 96)) { # We missed some, so please say so
	$Textstr .= "(There were only ".$samples." out of ".($lastmonth * 96)." possible samples made.)".$nl;
};
$downratio = $downhours / $monthhours;
$pay = ((1-$downratio) * $bill);
$downratio = sprintf ("%2.3f", $downratio);
$pay = sprintf ("%2.2f", $pay);
# $Textstr .= "<DIV style=\"BACKGROUND: #FF0505\">" if $htmlon;
$Textstr .= "Last month's ratio was ".$downratio." so your bill should be \$".$pay.".";
# $Textstr .= "</DIV>" if $htmlon;
$htmlon ? ($Textstr .= "<BR><BR><HR WIDTH=75%><BR>") : ($Textstr .= $nl.$nl);
if ($verbose == 1) {
	for ($d = 1; $d < 32; $d++) {
		if (@downarray[$d] > 0) {
			# Down for at least 15 min this day
			$Textstr .= " " if ($d < 10);
			$Textstr .= $d." : ".(@downarray[$d]*0.25)." hr".$nl;
		} # if
	} # for
} else {
	$Textstr .= "Proof is in \"".$RotateLog."\".".$nl;
};
# Open a mail message
open (NewMsg, "| $mail -s \"Automated Network Checks Report\" $mailto") or die "\nCannot open mail handle.\n";
$Textstr .= "<BR></SPAN></BODY></HTML>" if $htmlon;
print NewMsg $Textstr;
close NewMsg;
