#!/usr/bin/perl
$|=1;
$count = 0;
$pid = $$;
while (<>) {
chomp $_;
if ($_ =~ /(.*\.jpg)/i) {
$url = $1;
system("/usr/bin/wget", "-q", "-O","/var/web/www.imaginator.com/squid/$pid-$count.jpg", "$url");
system("/usr/bin/mogrify", "-flip","/var/web/www.imaginator.com/squid/$pid-$count.jpg");
system("/bin/chmod", "a+r","/var/web/www.imaginator.com/squid/$pid-$count.jpg");
print "http://www.imaginator.com/squid/$pid-$count.jpg\n";
}
elsif ($_ =~ /(.*\.gif)/i) {
$url = $1;
system("/usr/bin/wget", "-q", "-O","/var/web/www.imaginator.com/squid/$pid-$count.gif", "$url");
system("/usr/bin/mogrify", "-flip","/var/web/www.imaginator.com/squid/$pid-$count.gif");
system("/bin/chmod", "a+r", "/var/web/www.imaginator.com/squid/$pid-$count.gif");
print "http://www.imaginator.com/squid/$pid-$count.gif\n";
}
elsif ($_ =~ /(.*\.png)/i) {
$url = $1;
system("/usr/bin/wget", "-q", "-O","/var/web/www.imaginator.com/squid/$pid-$count.png", "$url");
system("/usr/bin/mogrify", "-flip","/var/web/www.imaginator.com/squid/$pid-$count.png");
system("/bin/chmod", "a+r", "/var/web/www.imaginator.com/squid/$pid-$count.png");
print "http://www.imaginator.com/squid/$pid-$count.png\n";
}
else {
print "$_\n";;
}
$count++;
}
