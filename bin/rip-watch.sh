#!/bin/sh
#

#
# Defines
#

## PID=/var/run/$0.pid

LOG_FILE=$HOME/.rip-log
SLEEP_INTERVAL=5

DRIVE="/dev/hdc"

#
# Functions
#

usage() {
	echo "usage: $0 (start|stop)"
}

check_drive() {
	cdparanoia -Qq >/dev/null 2>&1
	rv=$?
	echo $rv
	return $rv
}

rip() {
	abcde -x <<EOF
n
n
EOF

wait

}

poll() {
	while true
	do
		sleep $SLEEP_INTERVAL
		if [ `check_drive` -eq 0 ] 
		then
			date > $LOG_FILE
			rip  >> $LOG_FILE 2>&1
		fi
	done
}

get_all_child_pids() {
	for Pid in $*
	do
		ps -o ppid=$Pid
		get_all_child_pids $Pid
	done
}

stop_script() {
	script_name=`basename $0`
	pkill $script_name
}

#
# Main
#

case "$*" in
	'start')
		poll &
	;;
	'stop')
		stop_script
	;;
	*)
		usage
	;;
esac
