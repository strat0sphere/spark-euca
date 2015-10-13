#!/bin/bash
#TODO: Install s3cmd if not included in modules because it is a dependecy for this script to workpushd /root
mkdir /executor_tars
chown -R hdfs:hadoop /executor_tars

if [[ -e /executor_tars/hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz ]]; then
    echo "Executor tar exists already!"
else
    echo "Downloading hadoop-on-mesos tar from s3..."
    s3cmd -c /etc/s3cmd/s3cfg get --recursive --disable-multipart s3://mesos-repo/executors/hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz /executor_tars/
fi

echo "Putting hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz to HDFS..."
#/executor_tars directory already exists on the emi
sudo -u hdfs hadoop fs -put /executor_tars/hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz /
hadoop fs -chown hdfs:hadoop /hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz
hadoop fs -ls /

popd