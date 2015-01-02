#!/bin/sh

nohup /root/mesos-installation/sbin/mesos-master --cluster={{cluster_name}} --log_dir=/mnt/mesos-logs --zk={{cluster_url_private_ip}} --work_dir=/mnt/mesos-work-dir/ --quorum=1 start </dev/null >/dev/null 2>&1 &

#TODO: Convert on this format:
#nohup /root/mesos-installation/sbin/mesos-master --cluster=ha-test --log_dir=/mnt/mesos-logs --zk=zk://euca-10-2-202-21.eucalyptus.internal:2181,euca-10-2-202-13.eucalyptus.internal:2181,euca-10-2-202-25.eucalyptus.internal:2181/mesos --work_dir=/mnt/mesos-work-dir/ --quorum=1 start </dev/null >/dev/null 2>&1 &