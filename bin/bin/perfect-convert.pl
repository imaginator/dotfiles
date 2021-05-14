#!/usr/bin/perl

# "Simple but Perfect" mbox to Maildir converter v0.1
# by Philip Mak <pmak@aaanime.net>

# Usage: perfect_maildir ~/Maildir < mbox

# Simple  - only converts one mbox (can use script in one-liners)
# Perfect - message Flags/X-Flags are converted; "^>From ." line is unescaped

# I wrote this script after being unsatisfied with existing mbox to
# maildir converters. By making it "Simple", code complexity is kept
# low thus making it easy to program and debug. At the same time,
# since it only converts one mbox at a time, it is perfect for use in
# a shell ``for'' loop (for example).

# As for being "Perfect", to the best of my knowledge this script does
# the conversion correctly in all cases; it will translate "Status"
# and "X-Status" fields into maildir info, and it correctly detects
# where messages begin and end. (This is only version 0.1 so I may
# have messed something up though. Please send me feedback!)

# NOTE: The MUA ``mutt'' has a bug/feature where in the message index,
# it claims that all maildir messages have 0 lines unless they have a
# "Lines:" header set. perfect_maildir does not attempt to add the
# "Lines:" header; you may want to reconfigure ``mutt' to display byte
# size instead of lines instead by adding the following line to your
# ~/.muttrc file:
#
# set index_format="%4C %Z %{%b %d} %-15.15L (%4c) %s"

# check for valid arguments
my ($maildir) = @ARGV;
if (!$maildir) {
  print STDERR "Usage: perfect_maildir ~/Maildir < mbox\n";
  exit 1;
}

# check for writable maildir
unless (-w "$maildir/cur") {
  print STDERR "Cannot write to $maildir/cur\n";
  exit 1;
}
unless (-w "$maildir/new") {
  print STDERR "Cannot write to $maildir/new\n";
  exit 1;
}

my $num = 0;
my $time = time;

repeat:

# read header
my $headers = '';
my $flags = '';
my $subject = '';
while (my $line = <STDIN>) {
  # detect end of headers
  last if $line eq "\n";

  # strip "From" line from header
  $headers .= $line unless $line =~ /^From ./;

  # detect flags
  $flags .= $1 if $line =~ /^Status: ([A-Z]+)/;
  $flags .= $1 if $line =~ /^X-Status: ([A-Z]+)/;
  $subject = $1 if $line =~ /^Subject: (.*)$/;
}
$num++;

# open output file
my $file;
if ($flags =~ /O/) {
  $file = "$maildir/cur/$time.$num.$ENV{HOSTNAME}";
  my $extra = '';
  $extra .= 'F' if $flags =~ /F/; # flagged
  $extra .= 'R' if $flags =~ /A/; # replied
  $extra .= 'S' if $flags =~ /R/; # seen
  $extra .= 'T' if $flags =~ /D/; # trashed
  $file .= ":2,$extra" if $extra;
} else {
  $file = "$maildir/new/$time.$num.$ENV{HOSTNAME}";
}

# filter out the "DON'T DELETE THIS MESSAGE -- FOLDER INTERNAL DATA" message
$file = '/dev/null' if ($num == 1 and $subject eq "DON'T DELETE THIS MESSAGE --
 FOLDER
INTERNAL DATA");

open(FILE, ">$file");
print FILE "$headers\n";
while (my $line = <STDIN>) {
  # detect end of message
  last if $line =~ /^From ./;

  # unescape "From"
  $line =~ s/^>From (.)/From $1/;

  print FILE $line;
}
close(FILE);

goto repeat unless eof(STDIN);

my $elapsed = time - $time;
print "Inserted $num messages into maildir $maildir in $elapsed seconds\n";
