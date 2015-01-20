#!/bin/bash

# chkconfig: 345 80 20
# description: storm-ui

# pidfile: /var/run/storm-ui.pid
### BEGIN INIT INFO
# Provides:          storm-ui
# Required-Start:    $network $local_fs
# Required-Stop:
# Should-Start:      $named
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: storm ui
### END INIT INFO

source /lib/lsb/init-functions

USER=root
DAEMON_PATH=/root/storm-mesos-0.9.2-incubating/
DAEMON_NAME=mesos-ui

PATH=$PATH:$DAEMON_PATH/bin

case "$1" in
start)
# Start daemon.
echo -n "Starting $DAEMON_NAME: ";echo
nohup $DAEMON_PATH/bin/storm ui /mnt/storm-logs/ui.out 2>&1 &
echo $(($$+1)) > /var/run/storm/storm-ui.pid
;;
stop)
# Stop daemons.
echo -n "Shutting down $DAEMON_NAME: ";echo
#$DAEMON_PATH/storm-ui-stop.sh
cat /var/run/storm-ui.pid | xargs kill -9
rm -rf /var/run/storm-ui.pid
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
