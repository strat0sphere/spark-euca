#!/bin/bash
pushd /root

mkdir /executor_tars
wget -P /executor_tars http://php.cs.ucsb.edu/spark-related-packages/executor_tars/spark-1.1.0-bin-2.3.0.tgz

chown -R hdfs:hadoop /executor_tars

echo "Putting spark-1.1.0-bin-2.3.0.tgz to HDFS..."
#/executor_tars directory already exists on the emi
hadoop fs -put /executor_tars/spark-1.1.0-bin-2.3.0.tgz /
hadoop fs -ls /

#delete to save some space if necessary
rm /executor_tars/spark-1.1.0-bin-2.3.0.tgz

popd