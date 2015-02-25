#!/bin/bash

# Make sure we are in the spark-euca directory
cd /root/spark-euca

# Load the cluster variables set by the deploy script
source ec2-variables.sh

echo $HOSTNAME > /etc/hostname

echo "Setting up Mesos on `hostname`..."

#Getting arguments
run_tests=$1
restore=$2
cohost=$3

export RESTORE=$restore #If it is a restore session the backup module will restore files from S3

# Set up the masters, slaves, etc files based on cluster env variables
echo "$MASTERS" > masters
echo "$SLAVES" > slaves

echo "$ZOOS" > zoos

echo "$ZOOS_PRIVATE_IP" > zoos_private #List with zoos private IPs needed on storm and kafka setup scripts

#If instances are co-hosted then masters will also act as Zoos
if [ "$cohost" == "True" ]; then
    echo "cohost:$cohost"
fi

MASTERS=`cat masters`
NUM_MASTERS=`cat masters | wc -l`
OTHER_MASTERS=`cat masters | sed '1d'`
SLAVES=`cat slaves`
ZOOS=`cat zoos`

NAMENODES=`head -n 2 masters` #TODO: They should be the same with $NAMENODE and $STANDBY_NAMENODE but check
echo $NAMENODES > namenodes

#TODO: Change - should never go on the if statement - always at least 1 zoo
if [[ $ZOOS = *NONE* ]]; then
    NUM_ZOOS=0
    ZOOS=""
else
    ZOOS=`cat zoos | wc -l`
fi

SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=5"

if [[ "x$JAVA_HOME" == "x" ]] ; then
    echo "Expected JAVA_HOME to be set in .bash_profile!"
exit 1
fi

if [[ "x$SCALA_HOME" == "x" ]] ; then
    echo "Expected SCALA_HOME to be set in .bash_profile!"
exit 1
fi

if [[ `tty` == "not a tty" ]] ; then
    echo "Expecting a tty or pty! (use the ssh -t option)."
exit 1
fi

echo "Setting executable permissions on scripts..."
find . -regex "^.+.\(sh\|py\)" | xargs chmod a+x

echo "Running setup-slave on master to mount filesystems, etc..."
source /root/spark-euca/setup-mesos-emi-slave.sh

echo "SSH'ing to master machine(s) to approve key(s)..."
for master in $MASTERS; do
    echo $master
    #Delete previous PUBLIC_DNS env variable if exists (restore session)
    echo "Seding previous PUBLIC_DNS value..."
    ssh $SSH_OPTS $master "sed -i '/PUBLIC_DNS=/d' /etc/environment"
    ssh $SSH_OPTS $master "echo 'PUBLIC_DNS=$master' >> /etc/environment"
    ssh $SSH_OPTS $master echo -n &
done

ssh $SSH_OPTS localhost echo -n &
ssh $SSH_OPTS `hostname` echo -n &
wait


# Try to SSH to each cluster node to approve their key. Since some nodes may
# be slow in starting, we retry failed slaves up to 3 times.

if [ "$cohost" == "True" ]; then
    INSTANCES="$SLAVES $ZOOS"
    ALL_NODES="$MASTERS $SLAVES"
else
    INSTANCES="$SLAVES $OTHER_MASTERS $ZOOS" # List of nodes to try (initially all)
    ALL_NODES="$MASTERS $SLAVES $ZOOS"
fi

TRIES="0"                          # Number of times we've tried so far
echo "SSH'ing to other cluster nodes to approve keys..."
while [ "e$INSTANCES" != "e" ] && [ $TRIES -lt 4 ] ; do
    NEW_INSTANCES=
    for node in $INSTANCES; do
        echo $node
        ssh $SSH_OPTS $node echo -n
        if [ $? != 0 ] ; then
            NEW_INSTANCES="$NEW_INSTANCES $node"
        fi
    done
    TRIES=$[$TRIES + 1]
    if [ "e$NEW_INSTANCES" != "e" ] && [ $TRIES -lt 4 ] ; then
        sleep 15
        INSTANCES="$NEW_INSTANCES"
        echo "Re-attempting SSH to cluster nodes to approve keys..."
    else
        break;
    fi
done

echo "RSYNC'ing /root/spark-euca to other cluster nodes..."
for node in $INSTANCES; do
    echo $node
    rsync -e "ssh $SSH_OPTS" -az /root/spark-euca $node:/root &
    scp $SSH_OPTS ~/.ssh/id_rsa $node:.ssh &
done
wait


# NOTE: We need to rsync spark-euca before we can run setup-mesos-slave.sh
# on other cluster nodes
echo "Running slave setup script on other cluster nodes..."
for node in $SLAVES; do
    echo $node
    ssh -t -t $SSH_OPTS root@$node "/root/spark-euca/setup-mesos-emi-slave.sh"
done
wait

echo "Setting up Mesos on `hostname`..."

# Deploy templates
# TODO: Move configuring templates to a per-module ?
echo "Creating local config files..."
./deploy_templates_mesos.py

echo "Sending new cloudera-csh5.list file, running apt-get update and setting env variables to other nodes..."
#TODO: Add this to EMI to avoid upgrades from CDH5.1.2
for node in $ALL_NODES; do
    echo "Running on $node ..."
    rsync -e "ssh $SSH_OPTS" -az /etc/apt/sources.list.d/cloudera-cdh5.list $node:/etc/apt/sources.list.d/ & sleep 5.0
    echo "Rsyncing custom hadoop configuration to node $node ..."
    rsync -e "ssh $SSH_OPTS" -az /etc/default-custom $node:/etc/
    ssh -t -t $SSH_OPTS root@$node "apt-get update"
    rsync -e "ssh $SSH_OPTS" -az /etc/environment $node:/etc/
    ssh -t -t $SSH_OPTS root@$node "source /etc/environment"
done
wait

chmod a+x /root/spark-euca/copy-dir

echo "Deploying all /etc/hadoop configuration to slaves..."
/root/spark-euca/copy-dir /etc/hadoop

echo "Deploying hosts-configuration to slaves..."
/root/spark-euca/copy-dir /etc/hosts

echo "Configuring HDFS on `hostname`..."
echo "Creating Namenode directories on master..."

#Create hdfs name node directories on masters
for node in $MASTERS; do
    echo $node

    #Stop namenode to avoid Incompatible clusterIDs error
    ssh -t -t $SSH_OPTS root@$node "service hadoop-hdfs-datanode stop"

    ssh -t -t $SSH_OPTS root@$node "chmod u+x /root/spark-euca/cloudera-hdfs/*"
    ssh -t -t $SSH_OPTS root@$node "/root/spark-euca/cloudera-hdfs/create-namenode-dirs.sh"
    ssh -t -t $SSH_OPTS root@$node "/root/spark-euca/cloudera-hdfs/create-log-dirs.sh"
done
wait

echo "Creating Datanode directories on slaves..."
for node in $SLAVES; do
    echo $node
    #Stop datanode to avoid Incompatible clusterIDs error
    ssh -t -t $SSH_OPTS root@$node "service hadoop-hdfs-datanode stop"

    ssh -t -t $SSH_OPTS root@$node "chmod u+x /root/spark-euca/cloudera-hdfs/*; "
    ssh -t -t $SSH_OPTS root@$node "/root/spark-euca/cloudera-hdfs/create-datanode-dirs.sh"
    ssh -t -t $SSH_OPTS root@$node "/root/spark-euca/cloudera-hdfs/create-log-dirs.sh"
done
wait

#Necessary ungly hack: - Stop zookeeper daemon running on emi before deploying the new configuration
if [[ $NUM_ZOOS != 0 ]]; then
    echo "Stopping old zooKeeper daemons running on emi..."
    for zoo in $ZOOS; do
        #ssh $SSH_OPTS $zoo "/root/mesos/third_party/zookeeper-*/bin/zkServer.sh start </dev/null >/dev/null" & sleep 0.1
        #Creating dirs on masters and other_masters even if it is not not needed when not co-hosting instances
        #Creating zookeeper configuration directories
        ssh -t -t $SSH_OPTS root@$zoo "mkdir -p /mnt/zookeeper/dataDir; mkdir -p /mnt/zookeeper/dataLogDir; mkdir -p /mnt/zookeeper/log mkdir -p /mnt/zookeeper/run; chown -R zookeeper:zookeeper /mnt/zookeeper/; chmod -R g+w /mnt/zookeeper/; chown -R zookeeper:zookeeper /mnt/zookeeper/log; chown -R zookeeper:zookeeper /mnt/zookeeper/run"
        ssh -t -t $SSH_OPTS root@$zoo "service zookeeper-server force-stop" #Zoo on the 1st of the servers cannot be stopped normally.
        ssh -t -t $SSH_OPTS root@$node "cp /etc/default-custom/zookeeper /etc/default/"
        echo "Deleting zoo logs from emi to avoid confusion..."
        ssh -t -t $SSH_OPTS root@$node "rm -rf /var/log/zookeeper/zookeeper.log"
        ssh -t -t $SSH_OPTS root@$node "rm -rf /var/log/zookeeper/zookeeper.out"
    done
    wait

fi

#Ungly hack because zookeeper is on the emi
#Disable zookeeper service from /etc/init.d if masters are not hosting zookeeper service
if [ "$cohost" == "False" ]; then
    for node in $MASTERS; do
        echo "Removing zookeeper daemon from node: $node"
        ssh -t -t $SSH_OPTS root@$node "update-rc.d -f zookeeper-server remove"
    done
    wait
fi


if [[ $NUM_ZOOS != 0 ]]; then

    echo "Adding zookeeper hostnames and ports to configuration file..."
    zid=1
    for zoo in $ZOOS; do
        echo "Adding configuration for zoo: $zoo"
        echo "" >> /etc/zookeeper/conf.dist/zoo.cfg
        echo "server.$zid=$zoo:2888:3888" >> /etc/zookeeper/conf.dist/zoo.cfg
        zid=$(($zid+1))
        #echo "Sending log4j properties file to other zoos..."
        #rsync -e "ssh $SSH_OPTS" -az /etc/zookeeper/conf.dist/log4j.properties $zoo:/etc/zookeeper/conf.dist/
    done
    wait

    echo "RSYNC'ing config dirs and spark-euca dir to ZOOs and OTHER_MASTERS..."
    #TODO: At the moment deploy everything but should clean up later - Probably only dirs: zookeeper, kafka and files: crontab and hosts are needed

    if [ "$cohost" == "True" ]; then
        NODES="$ZOOS"
    else
        NODES="$ZOOS $OTHER_MASTERS"
    fi

    for node in $NODES; do
    echo $node
    rsync -e "ssh $SSH_OPTS" -az /root/spark $node:/root
    rsync -e "ssh $SSH_OPTS" -az /root/spark-euca $node:/root
    rsync -e "ssh $SSH_OPTS" -az /etc/zookeeper $node:/etc
    rsync -e "ssh $SSH_OPTS" -az /etc/kafka $node:/etc
    rsync -e "ssh $SSH_OPTS" -az /etc/hosts $node:/etc
    rsync -e "ssh $SSH_OPTS" -az /etc/crontab $node:/etc
    rsync -e "ssh $SSH_OPTS" -az /etc/hadoop $node:/etc
    done
    wait

    #Add HDFS backup to S3  to main server
    echo "30 00 	* * *	root 	/root/spark-euca/backup/backup-to-s3.sh" >> /etc/crontab


    echo "Starting up zookeeper ensemble..."
    zid=1
    for zoo in $ZOOS; do
    echo "Starting zookeeper on node $zoo ..."
    ssh -t -t $SSH_OPTS root@$zoo "service zookeeper-server init --myid=$zid --force"  & sleep 0.3
    ssh -t -t $SSH_OPTS root@$zoo "service zookeeper-server start"  & sleep 0.3

    zid=$(($zid+1))

    done
    wait
fi

echo "Checking that zookeeper election finished and quorum is running..."
for zoo in $ZOOS; do
    #ssh $SSH_OPTS $zoo "/root/mesos/third_party/zookeeper-*/bin/zkServer.sh start </dev/null >/dev/null" & sleep 0.1
    ssh -t -t $SSH_OPTS root@$zoo "echo srvr | nc localhost 2181 | grep Mode"
done
wait


#Initialize the HA state - run the command in one of the namenodes
echo "Initializing the HA state on zookeeper from $NAMENODE..."
ssh -t -t $SSH_OPT root@$NAMENODE "hdfs zkfc -formatZK"  & sleep 0.3
wait

echo "Installing journal nodes..."
journals_no=1
for node in $MASTERS; do
    echo "Installing and starting journal node on: $node"
    ssh -t -t $SSH_OPTS root@$node "apt-get --yes --force-yes install hadoop-hdfs-journalnode; wait"
    ssh -t -t $SSH_OPTS root@$node "cp /etc/default-custom/hadoop-hdfs-journalnode /etc/default/"
    #ssh -t -t $SSH_OPTS root@$node "service hadoop-hdfs-journalnode start"
    journals_no=$(($journals_no+1))
done
wait


if [ "$journals_no" -lt "3" ]
then
    echo "ERROR: You need at least 3 journal daemonds to run namenode with HA!"
    exit
fi

#Checking that journal nodes are up
for node in $MASTERS; do
    echo "Running jps on node $node ..."
    ssh -t -t $SSH_OPT root@$node "jps"
done
wait


echo "Formatting namenode $NAMENODE ..."
ssh -t -t $SSH_OPTS root@$NAMENODE "sudo -u hdfs hdfs namenode -format -force"
wait

echo "Starting namenode $NAMENODE..."
ssh -t -t $SSH_OPTS root@$NAMENODE "cp /etc/default-custom/hadoop-hdfs-namenode /etc/default/"
ssh -t -t $SSH_OPT root@$NAMENODE "service hadoop-hdfs-namenode start"
wait

echo "Formatting and starting standby namenode $STANDBY_NAMENODE..."
#Run only for the standby namenode
ssh -t -t $SSH_OPTS root@$STANDBY_NAMENODE "sudo -u hdfs hdfs namenode -bootstrapStandby -force"
wait
ssh -t -t $SSH_OPTS root@$STANDBY_NAMENODE "cp /etc/default-custom/hadoop-hdfs-namenode /etc/default/"
ssh -t -t $SSH_OPTS root@$STANDBY_NAMENODE "service hadoop-hdfs-namenode start"
wait


echo "Starting up datanodes..."
for node in $SLAVES; do
    echo $node
    ssh -t -t $SSH_OPTS root@$node "service hadoop-0.20-mapreduce-tasktracker stop" #Making sure there is not tasktracker left running on the EMI
    ssh -t -t $SSH_OPTS root@$node "cp /etc/default-custom/hadoop-hdfs-datanode /etc/default/"
    ssh -t -t $SSH_OPTS root@$node "service hadoop-hdfs-datanode start"
done
wait


echo "Starting Zookeeper failover controller on namenodes..."
for node in $NAMENODE $STANDBY_NAMENODE; do
    echo $node
    ssh -t -t $SSH_OPTS root@$node "apt-get --yes --force-yes install hadoop-hdfs-zkfc; wait"
    ssh -t -t $SSH_OPTS root@$node "cp /etc/default-custom/hadoop-hdfs-zkfc /etc/default/"
    #wait
    #ssh -t -t $SSH_OPTS root@$node "service hadoop-hdfs-zkfc start"
done
wait

#Checking that all services are up
for node in $MASTERS; do
    echo "Running jps on node $node ..."
    ssh -t -t $SSH_OPT root@$node "jps"
done
wait

echo "Creating tmp dir on HDFS..."
sudo -u hdfs hadoop fs -mkdir hdfs://$CLUSTER_NAME/tmp
sudo -u hdfs hadoop fs -chmod -R 1777 hdfs://$CLUSTER_NAME/tmp

echo "Creating necessary dir for HA on jobtracker..."
sudo -u mapred hadoop fs -mkdir -p hdfs://$CLUSTER_NAME/jobtracker/jobsinfo

for node in $MASTERS; do
    echo "Removing old job tracker from node $node ..."
    ssh -t -t $SSH_OPTS root@$node "service hadoop-0.20-mapreduce-jobtracker stop"
    ssh -t -t $SSH_OPTS root@$node "apt-get --yes --force-yes remove hadoop-0.20-mapreduce-jobtracker"
done

#sudo -u mapred hadoop mrhaadmin -transitionToActive -forcemanual jt1

echo "Adding HA on the jobtracker..."
for node in $NAMENODE $STANDBY_NAMENODE; do
    echo $node
    echo "Installing HA jobtracker on node $node ..."
    ssh -t -t $SSH_OPTS root@$node "apt-get --yes --force-yes install hadoop-0.20-mapreduce-jobtrackerha; wait"
    ssh -t -t $SSH_OPTS root@$node "service hadoop-0.20-mapreduce-jobtrackerha stop"
    ssh -t -t $SSH_OPTS root@$node "cp /etc/default-custom/hadoop-0.20-mapreduce-jobtrackerha /etc/default/"

    echo "Installing the failover controller package on node $node ..."
    ssh -t -t $SSH_OPTS root@$node "apt-get --yes --force-yes install hadoop-0.20-mapreduce-zkfc; wait"
    ssh -t -t $SSH_OPTS root@$node "service hadoop-0.20-mapreduce-zkfc stop"
    ssh -t -t $SSH_OPTS root@$node "cp /etc/default-custom/hadoop-0.20-mapreduce-zkfc /etc/default/"
done
wait


echo "Initialize the HA State in Zookeeper"...
#service hadoop-0.20-mapreduce-zkfc init
sudo -u mapred hadoop mrzkfc -formatZK -force


echo "Starting jobtracker HA services..."
for node in $NAMENODE $STANDBY_NAMENODE; do
    echo $node
    echo "Starting ZK daemon on node $node ..."
    ssh -t -t $SSH_OPTS root@$node "service hadoop-0.20-mapreduce-zkfc start"
    echo "Starting jobtracker on node $node..."
    ssh -t -t $SSH_OPTS root@$node "service hadoop-0.20-mapreduce-jobtrackerha start"
    wait
    ssh -t -t $SSH_OPTS root@$node "jps | grep Tracker"
done
wait


echo "Cleaning up instance from old logs on default dirs..."

for node in $ALL_NODES; do

    ssh -t -t $SSH_OPTS root@$node "rm -rf /var/log/hadoop-hdfs/*"

done
wait


echo "RSYNC'ing /root/mesos-installation to other cluster nodes..."
for node in $SLAVES $OTHER_MASTERS; do
    echo $node
    rsync -e "ssh $SSH_OPTS" -az /root/mesos-installation $node:/root
done
wait


echo "Adding master startup script to /etc/init.d and starting Mesos-master..."
for node in $MASTERS; do
    echo $node
    ssh $SSH_OPTS root@$node "chmod +x /root/mesos-installation/mesos-master.sh"
    ssh $SSH_OPTS root@$node "cd /etc/init.d/; ln -s /root/mesos-installation/mesos-master.sh mesos-master; update-rc.d mesos-master defaults; service mesos-master start"
done
wait


echo "Adding slave startup script to /etc/init.d and starting Mesos-slave..."
for node in $SLAVES; do
    echo $node
    ssh $SSH_OPTS root@$node "export LD_LIBRARY_PATH=/root/mesos-installation/lib/"
    ssh $SSH_OPTS root@$node "chmod +x /root/mesos-installation/mesos-slave.sh; cd /etc/init.d/; ln -s /root/mesos-installation/mesos-slave.sh mesos-slave; update-rc.d mesos-slave defaults; service mesos-slave start"
done
wait


echo "Setting up installation environment for OTHER_MASTERS ..."
for node in $OTHER_MASTERS; do
    for module in $MODULES; do
        echo "Transfering dir $module to $node ..."

        if [[ -e /etc/$module ]]; then
            rsync -e "ssh $SSH_OPTS" -az /etc/$module $node:/etc
            wait
        fi

    done
    wait

    #Env variables required for installation
    source /etc/environment
done
wait

for node in $MASTERS; do
    echo "Initializing modules on node $node ..."
    # Install / Init module
    for module in $MODULES; do
        if [[ -e $module/init.sh ]]; then
            echo "Initializing $module"
            ssh $SSH_OPTS root@$node "source /root/spark-euca/$module/init.sh"
        fi
        cd /root/spark-euca  # guard against setup.sh changing the cwd
    done

    echo "Setting up modules on node $node ..."
    # Setup each module
    for module in $MODULES; do
        echo "Setting up $module"
        ssh $SSH_OPTS root@$node "source /root/spark-euca/$module/setup.sh"
        sleep 1
        cd /root/spark-euca  # guard against setup.sh changing the cwd
    done

    echo "Starting up modules..."
    #Startup each module
    for module in $MODULES; do
        if [[ -e $module/startup.sh ]]; then
            echo "Starting up $module"
            ssh $SSH_OPTS root@$node "source /root/spark-euca/$module/startup.sh"
            sleep 1
        fi
    done

done
wait

    cd /root/spark-euca/

    # Test modules

    echo "Testing modules..."
    #echo "run_tests=$run_tests"
    if [ "$run_tests" == "True" ]; then

    # Add test code
    for module in $MODULES; do
        echo "Adding test code & running tests for $module"
        if [[ -e $module/test.sh ]]; then
            source $module/test.sh
            sleep 1
        fi
        cd /root/spark-euca  # guard against setup-test.sh changing the cwd
    done
    fi


echo "Installing monit to every node..."
for node in $MASTERS $SLAVES; do
    rsync -e "ssh $SSH_OPTS" -az /etc/monit $node:/etc
done

#TODO: Check type of node inside script with env variable instead of doing this 3 times
echo "Setting up monit for master..."
source /root/spark-euca/monit/init.sh
source /root/spark-euca/monit/setup.sh master
source /root/spark-euca/monit/startup.sh

echo "Setting up monit for other masters..."
for node in $OTHER_MASTERS; do
    ssh $SSH_OPTS root@$node "source /root/spark-euca/monit/init.sh"
    ssh $SSH_OPTS root@$node "source /root/spark-euca/monit/setup.sh other-master"
    ssh $SSH_OPTS root@$node "source /root/spark-euca/monit/startup.sh"
done

echo "Setting up monit for slaves..."
for node in $SLAVES; do
    ssh $SSH_OPTS root@$node "source /root/spark-euca/monit/init.sh"
    ssh $SSH_OPTS root@$node "source /root/spark-euca/monit/setup.sh slave"
    ssh $SSH_OPTS root@$node "source /root/spark-euca/monit/startup.sh"
done


#echo "Transfering module dirs to other masters..."
#for module in $MODULES; do
#    for node in $OTHER_MASTERS; do
#        echo "Transfering dir $module to $node ..."
#        if [[ -e /root/$module ]]; then
#            rsync -e "ssh $SSH_OPTS" -az /root/$module $node:/root
#            wait
#        fi
#        if [[ -e /etc/$module ]]; then
#            rsync -e "ssh $SSH_OPTS" -az /etc/$module $node:/etc
#            wait
#        fi
#    done
#done
#wait

#Some modules setups (Kafka - Storm) modifies the configuration files on /etc/ and modules on /root dir.
#So this makes sure that instances have identical file structures
#echo "Copying master files to other masters..."
#for node in $OTHER_MASTERS; do
#echo $node
#rsync -e "ssh $SSH_OPTS" -az /root/ $node:/
#rsync -e "ssh $SSH_OPTS" -az /etc/init.d/ $node:/etc/

#rsync -e "ssh $SSH_OPTS" -az --exclude "/etc/hostname" /etc $node:/

#rsync -e "ssh $SSH_OPTS" -az /mnt $node:/
#done


echo "Checking if services are up..."
for node in $MASTERS; do
echo $node
echo "Running ps -ef | grep storm on node $node ..."
ssh $SSH_OPTS root@$node "ps -ef | grep storm"

echo "Running ps -ef | grep kafka on node $node ..."
ssh $SSH_OPTS root@$node "ps -ef | grep kafka"

echo "Running ps -ef | grep zoo on node $node ..."
ssh $SSH_OPTS root@$node "ps -ef | grep zoo"

echo "Running ps -ef | grep mesos on node $node ..."
ssh $SSH_OPTS root@$node "ps -ef | grep mesos"

echo "Running jps on node $node ..."
ssh $SSH_OPTS root@$node "jps"
done






