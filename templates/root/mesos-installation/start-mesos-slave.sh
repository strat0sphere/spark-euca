#!/bin/sh

nohup /root/mesos-installation/sbin/mesos-slave --log_dir=/mnt/mesos-logs --work_dir=/mnt/mesos-work-dir/ --master={{cluster_url_private_ip}} </dev/null >/dev/null 2>&1 &