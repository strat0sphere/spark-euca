#!/bin/bash

mkdir /executor_tars
chown -R hdfs:hadoop /executor_tars

if [[ -e /executor_tars/spark-1.2.1-bin-2.3.0-mr1-cdh5.1.2.tgz ]]; then
echo "Executor tar exists already!"
else
echo "Downloading spark-on-mesos tar from s3..."
s3cmd -c /etc/s3cmd/s3cfg get --recursive --disable-multipart s3://mesos-repo/executors/spark-1.2.1-bin-2.3.0-mr1-cdh5.1.2.tgz /executor_tars/
fi


echo "Putting spark-1.2.1-bin-2.3.0-mr1-cdh5.1.2..tgz to HDFS..."
#/executor_tars directory already exists on the emi
hadoop fs -put /executor_tars/spark-1.2.1-bin-2.3.0-mr1-cdh5.1.2.tgz /
hadoop fs -ls /