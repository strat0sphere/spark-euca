#!/bin/bash

mkdir /executor_tars
wget -P /executor_tars http://php.cs.ucsb.edu/spark-related-packages/executor_tars/hadoop-2.3.0-cdh5.1.2-mesos.0.20.tar.gz
echo "Putting hadoop-2.3.0-cdh5.1.2-mesos.0.20.tar.gz to HDFS..."
#/executor_tars directory already exists on the emi
hadoop fs -put /executor_tars/hadoop-2.3.0-cdh5.1.2-mesos.0.20.tar.gz /
hadoop fs -ls /

chown -R /executor_tars
#delete to save some space if necessary
rm /executor_tars/hadoop-2.3.0-cdh5.1.2-mesos.0.20.tar.gz