#!/bin/bash
#TODO: Install s3cmd if not included in modules because it is a dependecy for this script to workpushd /root
mkdir /executor_tars

s3cmd -c /etc/s3cmd/s3cfg get --recursive --disable-multipart s3://mesos-repo/executors/hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz /executor_tars/

chown -R hdfs:hadoop /executor_tars

echo "Putting hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz to HDFS..."
#/executor_tars directory already exists on the emi
hadoop fs -put /executor_tars/hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz /
hadoop fs -ls /

#delete to save some space if necessary
rm /executor_tars/hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz

popd