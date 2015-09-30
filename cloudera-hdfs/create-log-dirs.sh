#!/bin/bash

#Add users as they don't exist in case of the empty emi
echo "Adding users..."
useradd mapred
useradd hdfs

mkdir -p /mnt/hadoop/log/hadoop-0.20-mapreduce/

chown mapred:mapred /mnt/hadoop/log/hadoop-0.20-mapreduce/

mkdir -p /mnt/hadoop/log/hadoop-hdfs/

chown hdfs:hdfs /mnt/hadoop/log/hadoop-hdfs