#!/bin/sh 
# 
# Show load and # of users on machine and write to file. 
# Used at login to notify users of load distribution across machs. 

MACH=`uname -n` 
LOGINS=`who | wc | awk '{print $1}'` 

LOAD=`uptime | cut -d, -f4 | cut -d: -f2` 
UNIQ=`who | sort | awk '{print $1}' | uniq | wc | awk '{print $1}'` 

echo "$MACH has $LOGINS sessions and a load of $LOAD ($UNIQ unique users)" 

