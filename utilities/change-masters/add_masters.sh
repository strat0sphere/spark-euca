#!/bin/bash

#Usage: script_name
#old_master=$1
#new_master=$2

# Change IP addresse and cluster name (ex es1, es2 etc) in every configuration file on the 1st master node - The scripts will copy then these files to the rest of the nodes
#To do the changes automatically also try the replace_ip.sh script on the current directory.
#Locations to change: Everything inside the /etc configuration dir
#/etc/hadoop/conf.mesos-cluster directory dir: All the .xml files
#mesos-installation dir: The mesos-master and slave scripts
#/root/spark-euca dir: The masters and slaves text files 
#/root/change_masters dir: The masters, slaves and zoos files
#/root/spark/conf/ the spark-env.sh and spark-defaults.conf files
#file: /etc/kafka/config/server.properties
#file: /etc/storm-on-mesos/storm.yaml
#/etc/ganglia/g
#Set property dfs.namenode.datanode.registration.ip-hostname-check to tru on hdfs-site.xml and remember to delete exclude.txt file from hadoop condifuration dir


SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=5"

CLUSTER_NAME=$1
MASTERS=`cat masters`
NUM_MASTERS=`cat masters | wc -l`
OTHER_MASTERS=`cat masters | sed '1d'`
SLAVES=`cat slaves`
ZOOS=`cat zoos`

NAMENODES=`head -n 2 masters` #TODO: They should be the same with $NAMENODE and $STANDBY_NAMENODE but check
NAMENODE=`awk 'NR==1' masters`
STANDBY_NAMENODE=`awk 'NR==2' masters`
echo $NAMENODES > namenodes


/root/spark-euca/copy-dir-generic /etc masters
/root/spark-euca/copy-dir-generic /etc slaves
/root/spark-euca/copy-dir-generic /root/change_masters masters
/root/spark-euca/copy-dir-generic /root/change_masters slaves
/root/spark-euca/copy-dir-generic /root/mesos-installation/mesos-slave.sh slaves
/root/spark-euca/copy-dir-generic /root/mesos-installation/mesos-slave.sh masters
/root/spark-euca/copy-dir-generic /root/mesos-installation/mesos-master.sh masters
/root/spark-euca/copy-dir-generic /root/spark/conf masters


for node in $MASTERS $SLAVES;
do
ssh -t -t $SSH_OPTS root@$node "/root/change_masters/remove_known_hosts.sh" 
#Stop monit if running from an existing emi
ssh -t -t $SSH_OPTS root@$node "service monit stop; ps ax | grep -i 'datanode' | grep -v color | awk '{print \$1}' | xargs kill -9"
done


#TODO: Also replace public and private IP addresses and hostnames on all configuration files!!!
#./replace_ip.sh 

for node in $MASTERS; do
echo $node

ssh -t -t $SSH_OPTS root@$node "chmod +x /root/change_masters/*.sh"
ssh -t -t $SSH_OPTS root@$node "/root/change_masters/all_services.sh stop"

ssh -t -t $SSH_OPTS root@$node "/root/spark-euca/cloudera-hdfs/create-namenode-dirs.sh;/root/spark-euca/cloudera-hdfs/create-log-dirs.sh;/root/spark-euca/cloudera-hdfs/create-tmp-dir.sh; mkdir -p /mnt/zookeeper/dataDir; mkdir -p /mnt/zookeeper/dataLogDir; mkdir -p /mnt/zookeeper/log mkdir -p /mnt/zookeeper/run; chown -R zookeeper:zookeeper /mnt/zookeeper/; chmod -R g+w /mnt/zookeeper/; chown -R zookeeper:zookeeper /mnt/zookeeper/log; chown -R zookeeper:zookeeper /mnt/zookeeper/run;mkdir /mnt/hadoop-mapred;chown mapred:mapred /mnt/hadoop-mapred;service zookeeper-server force-stop;rm -rf /var/log/zookeeper/zookeeper.log;rm -rf /var/log/zookeeper/zookeeper.out"
done
wait


for node in $SLAVES; do
echo "Cleaning up slaves from old logs..."
echo $node
ssh -t -t $SSH_OPTS root@$node "rm -rf /var/log/hadoop-hdfs/*; rm -rf /mnt/mesos-logs/*;rm -rf /mnt/hadoop/log/hadoop-hdfs/*; rm -rf /mnt/mesos-work-dir/*; rm -rf /mnt/monit/monit.log "
done


zid=1
for zoo in $ZOOS; do
echo "Initializing zoo $zoo with id $zid"
ssh -t -t $SSH_OPTS root@$zoo "service zookeeper-server init --myid=$zid --force"
ssh -t -t $SSH_OPTS root@$zoo "service zookeeper-server start"
zid=$(($zid+1))
done

for zoo in $ZOOS; do
ssh -t -t $SSH_OPTS root@$zoo "echo srvr | nc localhost 2181 | grep Mode"
done

echo "Need to re-initialize the HA state on the zookeeper..."
echo "Initializing the HA state on zookeeper from $NAMENODE..."
hdfs zkfc -formatZK -force

sudo -u mapred hadoop mrzkfc -formatZK -force

for node in $MASTERS; do
echo $node
ssh -t -t $SSH_OPTS root@$node "service hadoop-hdfs-journalnode start"
done

sudo -u hdfs hdfs namenode -format -force
service hadoop-hdfs-namenode start

echo "Formatting and starting standby namenode $STANDBY_NAMENODE..."
#Run only for the standby namenode
ssh -t -t $SSH_OPTS root@$STANDBY_NAMENODE "sudo -u hdfs hdfs namenode -bootstrapStandby -force"
wait
ssh -t -t $SSH_OPTS root@$STANDBY_NAMENODE "cp /etc/default-custom/hadoop-hdfs-namenode /etc/default/"
ssh -t -t $SSH_OPTS root@$STANDBY_NAMENODE "service hadoop-hdfs-namenode start"
ssh -t -t $SSH_OPTS root@$STANDBY_NAMENODE "service hadoop-hdfs-zkfc start"
wait


service hadoop-hdfs-zkfc start


echo "Starting up datanodes..."
for node in $SLAVES; do
    echo $node

    echo "Deleting old datanode dirs..."
    ssh -t -t $SSH_OPTS root@$node "service hadoop-hdfs-datanode stop; rm -rf /mnt/cloudera-hdfs/1/dfs/dn/current/; service hadoop-hdfs-datanode start"
done
wait

sudo -u hdfs hadoop fs -mkdir hdfs://$CLUSTER_NAME/tmp
sudo -u hdfs hadoop fs -chmod -R 1777 hdfs://$CLUSTER_NAME/tmp

for node in $NAMENODE $STANDBY_NAMENODE; do
echo $node
echo "Creating tmp mapred dir..."
ssh -t -t $SSH_OPTS root@$node "/root/spark-euca/cloudera-hdfs/create-tmp-dir.sh"
echo "Starting ZK daemon on node $node ..."
ssh -t -t $SSH_OPTS root@$node "service hadoop-0.20-mapreduce-zkfc start"
ssh -t -t $SSH_OPTS root@$node "service hadoop-0.20-mapreduce-jobtrackerha start"
done


#echo "Setting up monit for other masters..."
#for node in $OTHER_MASTERS; do
#    ssh $SSH_OPTS root@$node "source /root/spark-euca/monit/init.sh"
#    ssh $SSH_OPTS root@$node "source /root/spark-euca/monit/setup.sh other-master"
#    ssh $SSH_OPTS root@$node "source /root/spark-euca/monit/startup.sh"
#done

#echo "Starting monit..."

#for node in $MASTERS $SLAVES; do
#echo $node
#ssh -t -t $SSH_OPTS root@$node "service monit start"
#done



