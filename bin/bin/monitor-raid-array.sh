#!/bin/bash
 
# raidmon - monitors a Linux software raid device and emails administrator
# in case of drive failure
# 11-14-2000 Norman Clarke <norman@combimatrix.com>
# the raid device to monitor. Do not prefix it with /dev
RAIDDEV='md0'
# sleep for this many seconds between checks on raid status
BASE_SLEEPTIME=30
# report raid device failures this many seconds; default = 3600 = 60 mins
ERROR_REPORT_TIME=3600
# report raid failure to this person
ADMIN_EMAIL='root@localhost'
# spew status information to STDOUT
BE_VERBOSE=1
# this should be set to /proc/mdstat unless you're doing some testing
MDSTAT='/proc/mdstat'
 
if test -f $MDSTAT; then
while [ 1 ]
do
REPORT_TIME=`date +"%Y-%m-%d %H:%M:%S"`
DEADRAID=`grep -c -E '[h|s]d[a-z][0-9]+\[[0-9]+\]\(F\)' $MDSTAT`;
if [ $DEADRAID != 0 ]; then
for i in `grep $RAIDDEV $MDSTAT`;
do
MATCH=`echo $i | grep -c -E '[h|s]d[a-z][0-9]+\[[0-9]+\]\(F\)'`;
if [ $MATCH  = 1 ]; then
FAILEDDEV=`echo $i | sed -e 's/(F)//' | sed -e 's/\[[0-9]\]//'`
if [ $BE_VERBOSE -eq 1 ]; then
   echo "Drive $FAILEDDEV in raid device $RAIDDEV has failed";
fi
echo "Drive $FAILEDDEV in raid device $RAIDDEV has failed" | mail -s \
   "Report from `hostname` at $REPORT_TIME: raid failure" $ADMIN_EMAIL;
   SLEEPTIME=$ERROR_REPORT_TIME;
fi;
done;
sleep $SLEEPTIME
else
SLEEPTIME=$BASE_SLEEPTIME
if [ $BE_VERBOSE -eq 1 ]; then
   echo -n "$REPORT_TIME\t $RAIDDEV OK";
fi
sleep $SLEEPTIME
fi
done;
else
echo "Can not read $MDSTAT. Do you have RAID support compiled into \
your kernel?";
exit 1
fi


