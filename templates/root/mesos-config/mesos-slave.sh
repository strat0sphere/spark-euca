#!/bin/bash

# chkconfig: 345 80 20
# description: mesos-slave

# pidfile: $PID_FILE
### BEGIN INIT INFO
# Provides:          mesos-slave
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
DAEMON_PATH=/root/mesos-installation
DAEMON_NAME=mesos-slave

PATH=$PATH:$DAEMON_PATH/bin

PID_FILE=/var/run/mesos/mesos-slave.pid

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
mkdir /var/run/mesos
echo -n "Starting $DAEMON_NAME: ";echo

nohup $DAEMON_PATH/sbin/mesos-slave --executor_registration_timeout=5mins --log_dir=/mnt/mesos-logs --work_dir=/root/mesos-work-dir/ --master={{cluster_url_private_ip}} </dev/null >/dev/null 2>&1 &
sleep 3.0
ps ax | grep -i 'sbin/mesos-slave' | grep -v grep | awk '{print $1}' > $PID_FILE
fi
;;
stop)
# Stop daemons.
echo -n "Shutting down $DAEMON_NAME: ";echo
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
