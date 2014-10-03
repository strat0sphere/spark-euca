#!/bin/bash
mkdir -p /mnt/cloudera-hdfs/1/dfs/nn /nfsmount/dfs/nn
chown -R hdfs:hdfs /mnt/cloudera-hdfs/1/dfs/nn /nfsmount/dfs/nn
chmod 700 /mnt/cloudera-hdfs/1/dfs/nn /nfsmount/dfs/nn