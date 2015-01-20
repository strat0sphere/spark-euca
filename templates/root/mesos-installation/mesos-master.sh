#!/bin/bash

# chkconfig: 345 80 20
# description: mesos-master

# pidfile: /var/run/mesos/mesos-master.pid
### BEGIN INIT INFO
# Provides:          storm-nimbus
# Required-Start:    $network $local_fs
# Required-Stop:
# Should-Start:      $named
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: mesos master
### END INIT INFO

source /lib/lsb/init-functions

USER=root
DAEMON_PATH=/root/mesos-installation/
DAEMON_NAME=mesos-master

PATH=$PATH:$DAEMON_PATH/bin

case "$1" in
start)
# Start daemon.
echo -n "Starting $DAEMON_NAME: ";echo
nohup $DAEMON_PATH/bin/storm-mesos/sbin/mesos-master --cluster={{cluster_name}} --log_dir=/mnt/mesos-logs --zk={{cluster_url_private_ip}} --work_dir=/mnt/mesos-work-dir/ --quorum=1 start </dev/null >/dev/null 2>&1 &
echo $(($$+1)) > /var/run/mesos/mesos-master.pid
;;
stop)
# Stop daemons.
echo -n "Shutting down $DAEMON_NAME: ";echo
cat /var/run/mesos/mesos-master.pid | xargs kill -9
rm -rf /var/run/mesos/mesos-master.pid
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
