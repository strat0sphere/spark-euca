#!/bin/sh

nohup /root/mesos-installation/sbin/mesos-master --cluster={{cluster_name}} --log_dir=/mnt/mesos-logs --zk=zk://{{active_master_private}}:2181/mesos --work_dir=/mnt/mesos-work-dir/ --quorum=1 start </dev/null >/dev/null 2>&1 &