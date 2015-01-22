#!/bin/bash

# chkconfig: 345 80 20
# description: mesos-master

# pidfile: $PID_FILE
### BEGIN INIT INFO
# Provides:          mesos-master
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
DAEMON_PATH=/root/mesos-installation
DAEMON_NAME=mesos-master

PATH=$PATH:$DAEMON_PATH/bin

PID_FILE=/var/run/mesos/mesos-master.pid

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
mkdir /var/run/mesos
echo -n "Starting $DAEMON_NAME: ";echo
nohup $DAEMON_PATH/sbin/mesos-master --cluster={{cluster_name}} --log_dir=/mnt/mesos-logs --zk={{cluster_url_private_ip}} --work_dir=/mnt/mesos-work-dir/ --quorum=1 start </dev/null >/dev/null 2>&1 &
#sleep 3.0
#ps ax | grep -i 'mesos-master' | grep -v grep | awk '{print $1}' > $PID_FILE
echo $(($$+1)) > $PID_FILE
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
