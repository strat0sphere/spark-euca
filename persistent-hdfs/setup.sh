#!/bin/bash

PERSISTENT_HDFS=/root/persistent-hdfs

pushd /root/spark-euca/persistent-hdfs
source ./setup-slave.sh

for node in $SLAVES $OTHER_MASTERS; do
  ssh -t $SSH_OPTS root@$node "/root/spark-euca/persistent-hdfs/setup-slave.sh" & sleep 0.3
done
wait

/root/spark-euca/copy-dir $PERSISTENT_HDFS/conf

if [[ ! -e /vol/persistent-hdfs/dfs/name ]] ; then
  echo "Formatting persistent HDFS namenode..."
  $PERSISTENT_HDFS/bin/hadoop namenode -format
fi

echo "Persistent HDFS installed, won't start by default..."

popd
