#!/bin/sh

nohup /root/mesos-installation/sbin/mesos-master --cluster=$CLUSTER_NAME --log_dir=/mnt/mesos-logs --zk=zk://$ACTIVE_MASTER_PRIVATE:2181/mesos --work_dir=/mnt/mesos-work-dir/ --quorum=1 start </dev/null >/dev/null 2>&1 &