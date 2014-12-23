#!/bin/bash

USER=root
DAEMON_PATH=/root/kafka
DAEMON_NAME=kafka

PATH=$PATH:$DAEMON_PATH/bin

case "$1" in
start)
# Start daemon.
echo -n "Starting $DAEMON_NAME: ";echo
$DAEMON_PATH/bin/kafka-server-start.sh $DAEMON_PATH/config/server.properties > /mnt/kafka-logs/kafka.out 2>&1 &
;;
stop)
# Stop daemons.
echo -n "Shutting down $DAEMON_NAME: ";echo
#$DAEMON_PATH/kafka-server-stop.sh
ps ax | grep -i 'kafka.Kafka' | grep -v grep | awk '{print $1}' | xargs kill -9
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
