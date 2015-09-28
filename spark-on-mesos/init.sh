#!/bin/bash
#TODO: Install s3cmd if not included in modules because it is a dependecy for this script to work
pushd /root

mkdir /executor_tars

if [[ -e executor_tars/spark-1.2.1-bin-2.3.0-mr1-cdh5.1.2.tgz]]; then
    echo "Executor tar exists already!"
else
    s3cmd -c /etc/s3cmd/s3cfg get --recursive --disable-multipart s3://mesos-repo/executors/spark-1.2.1-bin-2.3.0-mr1-cdh5.1.2.tgz /executor_tars/
fi

chown -R hdfs:hadoop /executor_tars

echo "Putting spark-1.2.1-bin-2.3.0-mr1-cdh5.1.2..tgz to HDFS..."
#/executor_tars directory already exists on the emi
hadoop fs -put /executor_tars/spark-1.2.1-bin-2.3.0-mr1-cdh5.1.2.tgz /
hadoop fs -ls /

#delete to save some space if necessary
rm /executor_tars/spark-1.2.1-bin-2.3.0-mr1-cdh5.1.2.tgz

popd