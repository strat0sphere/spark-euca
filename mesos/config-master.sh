#!/bin/bash
#makesure port 5050 is open - euca-authorize -P tcp -p 5050 -s 0.0.0.0/0 stratos
#export LD_LIBRARY_PATH=/root/mesos/build/src/.libs/ #   Fixes error while loading shared libraries: libmesos--.xx.xx.so: cannot open shared object file: No such file or directory
export LD_LIBRARY_PATH=/root/mesos-$MESOS_VERSION/build/src/.libs/
#nohup /root/mesos-installation/sbin/mesos-master --cluster=mesos-2node-cluster --log_dir=/mnt/mesos-logs start </dev/null >/dev/null 2>&1 &



#with Zookeeper for mesos 0.18.1
#nohup /root/mesos-installation/sbin/mesos-master --cluster=mesos-2node-cluster --log_dir=/mnt/mesos-logs --zk=zk://10.2.7.122:2181/mesos start </dev/null >/dev/null 2>&1 &

#With Zookeeper for mesos 0.20.0
nohup /root/mesos-installation/sbin/mesos-master --cluster=mesos-spark-hadoop-cdh5-cluster --log_dir=/mnt/mesos-logs --zk=zk://10.2.24.25:2181/mesos --work_dir=/mnt/mesos-work-dir/ --quorum=1 start </dev/null >/dev/null 2>&1 &

#--log_dire=VALUE --> Default /etc/mesos
