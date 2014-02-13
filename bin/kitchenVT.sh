#!/bin/bash
export $TERM=vt100
stty ispeed 19200
stty ospeed 19200
stty columns 132
#/usr/bin/splitvt -lower "tcpdump -i eth0" -upper "tcpdump -i eth1"
/usr/bin/splitvt -lower "tcpdump -i eth0" -upper "ntop"

exit 0 

