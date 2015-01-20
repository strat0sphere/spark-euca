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

case "$1" in
start)
# Start daemon.
echo -n "Starting $DAEMON_NAME: ";echo
$DAEMON_PATH/bin/kafka-server.sh $DAEMON_PATH/config/server.properties > /mnt/kafka-logs/kafka.out 2>&1 &
echo $(($$+1)) >  > /var/run/kafka-server.pid
;;
stop)
# Stop daemons.
echo -n "Shutting down $DAEMON_NAME: ";echo
#$DAEMON_PATH/kafka-server-stop.sh
#ps ax | grep -i 'kafka.Kafka' | grep -v grep | awk '{print $1}' | xargs kill -9
cat /var/run/kafka-server.pid | xargs kill -9
rm -rf /var/run/kafka-server.pid
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
