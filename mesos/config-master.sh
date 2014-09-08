#!/bin/bash
#makesure port 5050 is open - euca-authorize -P tcp -p 5050 -s 0.0.0.0/0 stratos
export LD_LIBRARY_PATH=/root/mesos/build/src/.libs/ #   Fixes error while loading shared libraries: libmesos--.xx.xx.so: cannot open shared object file: No such file or directory
nohup /usr/local/sbin/mesos-master --cluster=ucsb --log_dir=/mnt/mesos-logs start </dev/null >/dev/null 2>&1 &

#--log_dire=VALUE --> Default /etc/mesos
