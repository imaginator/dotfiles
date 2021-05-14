#!/bin/bash

iptables=`which iptables`
if (( $? != 0 )); then
  echo "Unable to locate iptables in PATH"; exit 1
fi
tc=`which tc`
if (( $? != 0 )); then
  echo "Unable to locate tc in PATH"; exit 1
fi

opts="-n --line-numbers --verbose"
echo "Current network status:"
echo "-- FILTER tables"
$iptables $opts --list
echo "------------------";echo "";
echo "-- MANGLE tables"
$iptables $opts --table mangle --list
echo "------------------";echo "";
echo "-- NAT tables"
$iptables $opts --table nat --list
echo "------------------";

FIRST=true
NETDEVS=`cat /proc/net/dev | grep ':' | sed 's/:.*//'`
for DEV in $NETDEVS; do
  LC=`tc class show dev $DEV | wc -l | sed 's/ //g'`
  LC=`echo $LC`
  if (( $LC != 0 )); then
    if [ "$FIRST" == "true" ]; then
      echo ">>> Traffic controller status:";echo ""
      FIRST=false
    fi
    echo "-- CLASS entries for $DEV :"
    $tc -s -d class show dev $DEV
    echo "------------------";echo "";
    echo "-- QDISC entries for $DEV :"
    $tc -s -d qdisc show dev $DEV
    echo "------------------"; echo "";
    echo "-- FILTER entries for $DEV :"
    $tc -s -d filter show dev $DEV
    echo "------------------";echo "";
  fi
done

if [ "$FIRST" == "true" ]; then
  echo "No traffic shaping present ..."
fi

