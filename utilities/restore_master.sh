#!/bin/bash

#Script to restore one of the secondary masters
#Usage: script_name master_ip zk_id - example: ./restore_master.sh 128.111.179.132 2
master=$1
/root/spark-euca/cloudera-hdfs/create-namenode-dirs.sh
/root/spark-euca/cloudera-hdfs/create-log-dirs.sh
/root/spark-euca/cloudera-hdfs/create-tmp-dir.sh

mkdir -p /mnt/zookeeper/dataDir; mkdir -p /mnt/zookeeper/dataLogDir; mkdir -p /mnt/zookeeper/log mkdir -p /mnt/zookeeper/run; chown -R zookeeper:zookeeper /mnt/zookeeper/; chmod -R g+w /mnt/zookeeper/; chown -R zookeeper:zookeeper /mnt/zookeeper/log; chown -R zookeeper:zookeeper /mnt/zookeeper/run
mkdir /mnt/hadoop-mapred
chown mapred:mapred /mnt/hadoop-mapred
service zookeeper-server force-stop
rm -rf /var/log/zookeeper/zookeeper.log
rm -rf /var/log/zookeeper/zookeeper.out

#sed -i '/PUBLIC_DNS=/d' /etc/environment
#echo 'PUBLIC_DNS=$master' >> /etc/environment
service zookeeper-server init --myid=$zk_id --force
service zookeeper-server start
echo srvr | nc localhost 2181 | grep Mode
sudo -u hdfs hdfs namenode -bootstrapStandby -force
service hadoop-hdfs-namenode start
/root/spark-euca/monit/init.sh
/root/spark-euca/monit/setup.sh other-master
/root/spark-euca/monit/startup.sh

echo "Need to re-initialize the HA state on the zookeeper..."
echo "Initializing the HA state on zookeeper from $NAMENODE..."
hdfs zkfc -formatZK
echo "Initialize the HA State in Zookeeper"...
sudo -u mapred hadoop mrzkfc -formatZK -force
