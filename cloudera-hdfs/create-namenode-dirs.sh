#!/bin/bash
#Attention: With HA all directories should be local storage - not nsfmount
#the nsfmount bellow is just a name - not an actuall dir on nsf
mkdir -p /mnt/cloudera-hdfs/1/dfs/nn /nfsmount/dfs/nn /mnt/cloudera-hdfs/1/dfs/jn
chown -R hdfs:hdfs /mnt/cloudera-hdfs/1/dfs/nn /nfsmount/dfs/nn /mnt/cloudera-hdfs/1/dfs/jn
chmod 700 /mnt/cloudera-hdfs/1/dfs/nn /nfsmount/dfs/nn /mnt/cloudera-hdfs/1/dfs/jn 