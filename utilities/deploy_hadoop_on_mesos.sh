#!/bin/bash

cp target/hadoop-mesos-0.0.8.jar /usr/lib/hadoop-0.20-mapreduce/lib/
cp target/hadoop-mesos-0.0.8.jar /root/hadoop-2.3.0-cdh5.1.2/share/hadoop/common/lib/

cd /root #make sure you are on root dir

#pack to be ready to upload to HDFS
echo "Packing hadoop-on-mesos..."
tar czf hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz hadoop-2.3.0-cdh5.1.2

echo "Deleting old jar if exists..."
rm /executor_tars/hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz
echo "Moving hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz to /executor_tars"
mv hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz /executor_tars

echo "Listing executor_tars files:"
ls /executor_tars

echo "Deleting old tar from HDFS"
hadoop fs -rm -r -f /hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz
echo "Putting hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz to HDFS..."
sudo -u hdfs hadoop fs -put /executor_tars/hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz /
hadoop fs -chown hdfs:hadoop /hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz
hadoop fs -ls /

echo "Deleting jar file from /executor_tars"
rm /executor_tars/hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz

