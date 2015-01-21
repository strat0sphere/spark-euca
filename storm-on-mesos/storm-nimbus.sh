#!/bin/bash

# chkconfig: 345 80 20
# description: storm-nimbus

# pidfile: $PID_FILE
### BEGIN INIT INFO
# Provides:          storm-nimbus
# Required-Start:    $network $local_fs
# Required-Stop:
# Should-Start:      $named
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: storm nimbus
### END INIT INFO

source /lib/lsb/init-functions

USER=root
DAEMON_PATH=/root/storm-mesos-0.9.2-incubating
DAEMON_NAME=mesos-nimbus

PATH=$PATH:$DAEMON_PATH/bin
PID_FILE=/var/run/storm/storm-nimbus.pid

# Check if a service is running
isrunning() {
ISRUNNING="0"
# Do we have PID-file?
if [ -f "$PIDDIR/$1.pid" ]; then
# Check if proc is running
pid=`cat "$PIDDIR/$1.pid" 2> /dev/null`
if [ "$pid" != "" ]; then
if [ -d /proc/$pid ]; then
# Process is running
ISRUNNING="1"
fi
fi
fi
#ISRUNNING="0"
}

case "$1" in
start)
if isrunning $PID_FILE ; then
echo "Error: $DAEMON_NAME is running. Stop it first." >&2
exit 1
else
# Start daemon.
echo -n "Starting $DAEMON_NAME: ";echo
nohup $DAEMON_PATH/bin/storm-mesos nimbus > /mnt/storm-logs/nimbus.out 2>&1 &
#sleep 3.0
#ps ax | grep -i 'xml storm.mesos.MesosNimbus' | grep -v grep | awk '{print $1}' > $PID_FILE
echo $(($$+1)) > $PID_FILE
fi
;;
stop)
# Stop daemons.
echo -n "Shutting down $DAEMON_NAME: ";echo
#$DAEMON_PATH/storm-nimbus-stop.sh
cat $PID_FILE | xargs kill -9
rm -rf $PID_FILE
;;
restart)
$0 stop
sleep 1
$0 start
;;
*)
echo "Usage: $0 {start|stop|restart}"
exit 1
esac

exit 0
