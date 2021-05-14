#!/bin/sh
# Who Failed to login?
echo "Failed logins:"
faillog

# Who logged in today?
echo "Today's Lucky logins"
last | grep "`date | cut -f 1,2,3  -d \ `"

echo "What's listening"
netstat -plut | grep LISTEN

echo "Top 10 space users (in MB):"
du -ms /home/* | sort -g -r | head 

echo "Check for rootkits"
/usr/sbin/chkrootkit

echo "Who used system resources"
ac -z -p

# echo "Cruft on the system"
# /usr/sbin/cruft

echo "Check for SUID binaries"
find / -user root -perm -4000 -print

echo "Check for SGID binaries"
find / -type f -perm -2000 -print

