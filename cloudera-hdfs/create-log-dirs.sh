#!/bin/bash

#Add users as they don't exist in case of the empty emi
echo "Adding users..."
useradd -G hadoop,mapred mapred
useradd -G hadoop,hdfs hdfs

usermod -a -G hadoop mapred
usermod -a -G hadoop hdfs
usermod -a -G hadoop root

mkdir -p /mnt/hadoop/log/hadoop-0.20-mapreduce/

chown mapred:mapred /mnt/hadoop/log/hadoop-0.20-mapreduce/

mkdir -p /mnt/hadoop/log/hadoop-hdfs/

chown hdfs:hdfs /mnt/hadoop/log/hadoop-hdfs