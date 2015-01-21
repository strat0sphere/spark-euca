#!/bin/bash

# chkconfig: 345 80 20
# description: storm-nimbus

# pidfile: /var/run/storm/storm-nimbus.pid
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

case "$1" in
start)
# Start daemon.
echo -n "Starting $DAEMON_NAME: ";echo
nohup $DAEMON_PATH/bin/storm-mesos nimbus > /mnt/storm-logs/nimbus.out 2>&1 &
sleep 3.0
ps ax | grep -i 'xml storm.mesos.MesosNimbus' | grep -v grep | awk '{print $1}' > /var/run/storm/storm-nimbus.pid
#echo $(($$+1)) > /var/run/storm/storm-nimbus.pid
;;
stop)
# Stop daemons.
echo -n "Shutting down $DAEMON_NAME: ";echo
#$DAEMON_PATH/storm-nimbus-stop.sh
cat /var/run/storm/storm-nimbus.pid | xargs kill -9
rm -rf /var/run/storm/storm-nimbus.pid
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
