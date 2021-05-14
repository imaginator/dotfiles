#!/usr/bin/perl
# $Id: weatherF.pl,v 1.1 2000/11/19 15:46:26 prenagha Exp $
#
# get the NWS forecast for a weather zone and email
# it to the specified address.
# parameters:
#   state (e.g., "MD")
#   zone (e.g., "001" - see weather.gov for zone ids)
#   email recipient
# 
# ---- LICENSE ------------
# weatherF
# Copyright (C) 2000  Padraic Renaghan <padraic@renaghan.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# ---- INSTALL ------------
# 1) download this script, make the script executable
#    chmod 755 weather.pl
#
# 2) Make sure the first line of the script correctly points
#    to perl on your system.
#
# 3) figure out the state and zone of the forecast you want.
#    I haven't found an easy way to do this yet, so the hard
#    way is to go to http://iwin.nws.noaa.gov/iwin/??/zone.html
#    (replace ?? with your lowercase 2 character state code).
#    Then scroll down until you find the city/area you want
#    listed. Just above that you will find the zone code, in
#    the format of ??Z??? (first 2 chars are state code,
#    followed by "Z", followed by 3 digit zone code).
#
# 4) Set the configuration variables in the script like
#    $from... You might also want to enable $DEBUG until
#    you are satisfied everything is working.
#
# 5) Run the script passing it three parameters:
#    [1] the 2 char state code
#    [2] the 3 digit zone code
#    [3] the recipient email address
#    For example:
#      weatherF.pl DC 001 user@domain
#
# 6) Familiarize yourself with the text compression expressions
#    in the code. A quick summary of the non-intuitive compressions:
#       From -> To
#       ----------
#       north -> N (and so on for south, northeast...)
#       5 to 10 mph -> 5-10
#       with a chance of -> chnc
#       partly -> part
#       around -> ~
#       with -> w/
#       low in the -> L:
#       high in the -> H:
#       wind -> W:
#       clear -> clr
#       friday -> FR (and so on for monday -> MO...)
#
# 6) Most likely you'll want to run this script from cron
#    each day, so set it up in your crontab. See "man cron"
#    for help on that step.
#
# 7) If you have ideas for improvements, especially better/new
#    text compression expressions, please send them to me at
#    <padraic@renaghan.com>
#
# ---- CONFIGURATION VARIABLES ------------
# 1 to enable, 0 to disable
# Email is NOT sent in debug mode
$DEBUG=0;

# the From: address for the email
# you must escape the "@" symbol since
# this is used in a HERE document
$from="<weather\@imaginator.com>";

# message is piped to this command which should
# send STDIN as an email message
$mailer="/usr/lib/sendmail -oi -t";

# ---- BEGIN PROGRAM ------------
# you'll need the LWP Perl module to use this script.
# see http://www.cpan.org/
use LWP::Simple;

# get the arguments passed to the script
$state  = lc($ARGV[0]);
$zone   = $ARGV[1];
$email  = $ARGV[2];

# build the URL used to retrieve the forecast
# like http://weather.noaa.gov/pub/data/forecasts/zone/dc/dcz001.txt
$url="http://weather.noaa.gov/pub/data/forecasts/zone/$state/${state}z${zone}.txt";

# get the weather data from national weather service
# the "get" call here is inside of the LWP module.
# It does an HTTP GET request on the passed URL.
$r = get $url;

# then split into blocks - separated by blank lines
# the format of the file is 3 header sections, then
# the current forecast, then the extended forecast.

@lines = split(/\n/, $r);
$inForecast=0;
$f="";
foreach $line (@lines) {
  # trim the line
  $line =~ s/^\s+//;
  $line =~ s/\s+$//;

  # if the line starts with a period, and we haven't
  # got any forecast data yet, then this is the start
  # of the forecast data.
  if (length($f)==0) {
    if ($line =~ /^\./) {
      $inForecast=1;
    }
  } else {
  # the forecast data ends with the first blank
  # line after it started
    if (length($line)==0) {
      $inForecast=0;
    }
  }
    
  # if we are in the forecast
  if ($inForecast) {
    # add contents of current line to the forecast
    $f .= "$line\n";
  }
}

# make sure we got some kind of forecast, if
# not, then dump to stdout which will go to 
# the admin since this normally runs from cron.
if (length($f) > 10) {
} else {
  print("\n\n*** Error: forecast not found ***\n\n"); 
  # turn on debug to dump other data
  $DEBUG=1;
}

print("date.: ".localtime(time())."\n")   if ($DEBUG);
print("zone.: $zone\n")   if ($DEBUG);
print("state.: $state\n")   if ($DEBUG);
print("zone number: $zoneNbr\n")   if ($DEBUG);
print("email: $email\n")  if ($DEBUG);
print("url..: $url\n\n")    if ($DEBUG);
print("response: $r\n\n") if($DEBUG);

$forecast = $f;
# clean up the text a little.
# leading dot removed
$forecast =~ s/^\.+//gis;
# all dots changed to space
$forecast =~ s/\./ /gis;
# all newlines changed to spaces
$forecast =~ s/\n+/ /gis;
# multiple spaces changed to single space
$forecast =~ s/ +/ /gis;
# lowercase the whole thing
$forecast = lc($forecast);

# shorten up known words
$forecast =~ s/temperature(s)?/temp/gis;
$forecast =~ s/ ([a-z]+)ing/ $1/gis;

$forecast =~ s/afternoon/aftn/gis;
$forecast =~ s/tonight/tonit/gis;
$forecast =~ s/overnight/ovnit/gis;

$forecast =~ s/cloudy/cldy/gis;
$forecast =~ s/sunny/sun/gis;
$forecast =~ s/ percent/%/gis;
$forecast =~ s/monday/MO/gis;
$forecast =~ s/tuesday/TU/gis;
$forecast =~ s/wednsday/WE/gis;
$forecast =~ s/thursday/TH/gis;
$forecast =~ s/friday/FR/gis;
$forecast =~ s/saturday/SA/gis;
$forecast =~ s/sunday/SU/gis;
$forecast =~ s/north/N/gis;
$forecast =~ s/south/S/gis;
$forecast =~ s/west/W/gis;
$forecast =~ s/east/E/gis;
$forecast =~ s/([0-9]+) to ([0-9]+) mph/$1-$2/gis;
$forecast =~ s/with (a )?chance( of)?/chnc/gis;
$forecast =~ s/chance of/chnc/gis;
$forecast =~ s/partly/part/gis;
$forecast =~ s/mostly/most/gis;
$forecast =~ s/shower(s)?/shwr/gis;
$forecast =~ s/around /~/gis;
$forecast =~ s/with /w\//gis;
$forecast =~ s/low(s)? in the (lower and mid)?/L:/gis;
$forecast =~ s/high(s)? in the (mid and upper)?/H:/gis;
$forecast =~ s/upper ([0-9]+)s/$1\+s/gis;
$forecast =~ s/lower ([0-9]+)s/$1-s/gis;
$forecast =~ s/mid ([0-9]+)s/$1s/gis;
$forecast =~ s/mid //gis;
$forecast =~ s/wind /W:/gis;
$forecast =~ s/clear/clr/gis;
$forecast =~ s/mph //gis;
$forecast =~ s/scattered/scat/gis;
$forecast =~ s/an inch/1"/gis;
$forecast =~ s/([0-9]+) inches/$1"/gis;
$forecast =~ s/accumulation/accum/gis;
$forecast =~ s/continued/cont/gis;

print("orig forecast: $f\n\n") if($DEBUG);
print("forecast orig length: ".length($f)."\n") if($DEBUG);
print("forecast compact length: ".length($forecast)."\n\n") if($DEBUG);
print("forecast: $forecast\n\n") if($DEBUG);

$cleanF = $f;
$cleanF =~ s/\n+/ /gis;

# send the results to the recipient
if ($DEBUG) {
  print("** debug mode, message not sent! **\n");
} else {
  open SM, "|$mailer"
    or die "Cannot launch mailer: $!";
print SM <<END;
From: $from
X-State: $state
X-Zone: $zone
X-URL: $url
X-Orig-Forecast: $cleanF
To: <$email>

$forecast
END
  close SM;
  die "mailer exited with $?" if $?;
}
