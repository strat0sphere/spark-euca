#!/bin/sh

nohup /root/mesos-installation/sbin/mesos-slave --log_dir=/mnt/mesos-logs --work_dir=/mnt/mesos-work-dir/ --master=zk://$ACTIVE_MASTER_PRIVATE:2181/mesos </dev/null >/dev/null 2>&1 &