#!/bin/bash

# chkconfig: 345 80 20
# description: mesos-slave

# pidfile: /var/run/mesos/mesos-slave.pid
### BEGIN INIT INFO
# Provides:          storm-nimbus
# Required-Start:    $network $local_fs
# Required-Stop:
# Should-Start:      $named
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: mesos slave
### END INIT INFO

source /lib/lsb/init-functions

USER=root
DAEMON_PATH=/root/mesos-installation/
DAEMON_NAME=mesos-slave

PATH=$PATH:$DAEMON_PATH/bin

case "$1" in
start)
# Start daemon.
echo -n "Starting $DAEMON_NAME: ";echo

nohup $DAEMON_PATH/bin/storm-mesos/sbin/mesos-slave --log_dir=/mnt/mesos-logs --work_dir=/mnt/mesos-work-dir/ --master={{cluster_url_private_ip}} </dev/null >/dev/null 2>&1 &
echo $(($$+1)) > /var/run/mesos/mesos-slave.pid
;;
stop)
# Stop daemons.
echo -n "Shutting down $DAEMON_NAME: ";echo
cat /var/run/mesos/mesos-slave.pid | xargs kill -9
rm -rf /var/run/mesos/mesos-slave.pid
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
