#!/bin/bash

mkdir -p /mnt/hadoop/log/hadoop-0.20-mapreduce/
mkdir -p /mnt/hadoop/run/hadoop-0.20-mapreduce/

chown mapred:mapred /mnt/hadoop/log/hadoop-0.20-mapreduce/
chown mapred:mapred /mnt/hadoop/run/hadoop-0.20-mapreduce/


mkdir -p /mnt/hadoop/log/hadoop-hdfs/
mkdir -p /mnt/hadoop/run/hadoop-hdfs/

chown hdfs:hdfs /mnt/hadoop/log/hadoop-hdfs
chown hdfs:hdfs /mnt/hadoop/run/hadoop-hdfs