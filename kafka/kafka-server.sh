#!/bin/bash

# chkconfig: 345 80 20
# description: kafka

# pidfile: /var/run/kafka-server.pid
### BEGIN INIT INFO
# Provides:          kafka-server
# Required-Start:    $network $local_fs
# Required-Stop:
# Should-Start:      $named
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Kafka server
### END INIT INFO

source /lib/lsb/init-functions

USER=root
DAEMON_PATH=/root/kafka
DAEMON_NAME=kafka

PATH=$PATH:$DAEMON_PATH/bin

PID_FILE=/var/run/kafka-server.pid

# Check if a service is running
is_running(){
ISRUNNING="0"
# Check if a service is running
# Do we have PID-file?
if [ -f "$1" ]; then
# Check if proc is running
pid=`cat "$1" 2> /dev/null`
echo "pid = $pid"
if [ "$pid" != "" ]; then
if [ -d /proc/$pid ]; then
# Process is running
ISRUNNING="1"
fi
fi
fi
}
case "$1" in
start)
is_running $PID_FILE
if [ "$ISRUNNING" == "1" ]; then
echo "Error: $DAEMON_NAME is running. Stop it first." >&2
exit 1
else
# Start daemon.
echo -n "Starting $DAEMON_NAME: ";echo
$DAEMON_PATH/bin/kafka-server-start.sh $DAEMON_PATH/config/server.properties > $PID_FILE 2>&1 &
sleep 3.0
ps ax | grep -i 'kafka.Kafka' | grep -v grep | awk '{print $1}' > $PID_FILE
#echo $(($$+1)) > $PID_FILE
fi
;;
stop)
# Stop daemons.
echo -n "Shutting down $DAEMON_NAME: ";echo
#$DAEMON_PATH/kafka-server-stop.sh
#ps ax | grep -i 'kafka.Kafka' | grep -v grep | awk '{print $1}' | xargs kill -9
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
