#!/bin/bash
mkdir -p /mnt/cloudera-hdfs/1/dfs/nn /nfsmount/dfs/nn /mnt/cloudera-hdfs/1/dfs/jn
chown -R hdfs:hdfs /mnt/cloudera-hdfs/1/dfs/nn /nfsmount/dfs/nn /mnt/cloudera-hdfs/1/dfs/jn
chmod 700 /mnt/cloudera-hdfs/1/dfs/nn /nfsmount/dfs/nn /mnt/cloudera-hdfs/1/dfs/jn 