#!/bin/bash

# Make sure we are in the spark-euca directory
cd /root/spark-euca

# Load the environment variables specific to this AMI
source /root/.bash_profile

# Load the cluster variables set by the deploy script
source ec2-variables.sh

# Set hostname based on EC2 private DNS name, so that it is set correctly
# even if the instance is restarted with a different private DNS name
#PRIVATE_DNS=`wget -q -O - http://instance-data.ec2.internal/latest/meta-data/local-hostname`
#PUBLIC_DNS=`wget -q -O - http://instance-data.ec2.internal/latest/meta-data/hostname`
#hostname $PRIVATE_DNS
PRIVATE_DNS=hostname
echo $PRIVATE_DNS > /etc/hostname
export HOSTNAME=$PRIVATE_DNS  # Fix the bash built-in hostname variable too

echo "Setting up Spark on `hostname`..."

# Set up the masters, slaves, etc files based on cluster env variables
echo "$MASTERS" > masters
echo "$SLAVES" > slaves

MASTERS=`cat masters`
NUM_MASTERS=`cat masters | wc -l`
OTHER_MASTERS=`cat masters | sed '1d'`
SLAVES=`cat slaves`
ZOOS=`cat zoo`

if [[ $ZOOS = *NONE* ]]; then
NUM_ZOOS=0
ZOOS=""
else
NUM_ZOOS=`cat zoo | wc -l`
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
source /root/spark-euca/setup-mesos-slave.sh

echo "SSH'ing to master machine(s) to approve key(s)..."
for master in $MASTERS; do
echo $master
ssh $SSH_OPTS $master "echo 'PUBLIC_DNS=$master' >> /etc/environment"
ssh $SSH_OPTS $master echo -n &
sleep 0.3

done
ssh $SSH_OPTS localhost echo -n &
ssh $SSH_OPTS `hostname` echo -n &
wait


if [[ $NUM_ZOOS != 0 ]] ; then
echo "SSH'ing to ZooKeeper server(s) to approve keys..."
zid=1
for zoo in $ZOOS; do
echo $zoo
ssh $SSH_OPTS $zoo echo -n \; mkdir -p /tmp/zookeeper \; echo $zid \> /tmp/zookeeper/myid &
zid=$(($zid+1))
sleep 0.3
done
fi

# Try to SSH to each cluster node to approve their key. Since some nodes may
# be slow in starting, we retry failed slaves up to 3 times.
TODO="$SLAVES $OTHER_MASTERS $ZOOS" # List of nodes to try (initially all)
TRIES="0"                          # Number of times we've tried so far
echo "SSH'ing to other cluster nodes to approve keys..."
while [ "e$TODO" != "e" ] && [ $TRIES -lt 4 ] ; do
NEW_TODO=
for slave in $TODO; do
echo $slave
ssh $SSH_OPTS $slave echo -n
if [ $? != 0 ] ; then
NEW_TODO="$NEW_TODO $slave"
fi
done
TRIES=$[$TRIES + 1]
if [ "e$NEW_TODO" != "e" ] && [ $TRIES -lt 4 ] ; then
sleep 15
TODO="$NEW_TODO"
echo "Re-attempting SSH to cluster nodes to approve keys..."
else
break;
fi
done

echo "RSYNC'ing /root/spark-euca to other cluster nodes..."
for node in $SLAVES $OTHER_MASTERS; do
echo $node
rsync -e "ssh $SSH_OPTS" -az /root/spark-euca $node:/root &
scp $SSH_OPTS ~/.ssh/id_rsa $node:.ssh &
sleep 0.3
done
wait

# NOTE: We need to rsync spark-euca before we can run setup-mesos-slave.sh
# on other cluster nodes
echo "Running slave setup script on other cluster nodes..."
for node in $SLAVES $OTHER_MASTERS $ZOOS; do
echo $node
ssh -t -t $SSH_OPTS root@$node "/root/spark-euca/setup-mesos-slave.sh" & sleep 0.3
done
wait

echo "Setting up Spark on `hostname`..."
#installing required packages to slave nodes
echo "Installing required packages to slave nodes..."
distribution=$1 #ubuntu or centos

for node in $SLAVES $OTHER_MASTERS; do
echo $node
ssh -t -t $SSH_OPTS root@$node "chmod u+x /root/spark-euca/prepare-slaves-$distribution.sh" & sleep 0.3
ssh -t -t $SSH_OPTS root@$node "/root/spark-euca/prepare-slaves-$distribution.sh" & sleep 0.3
ssh -t -t $SSH_OPTS root@$node "echo 'JAVA_HOME=/usr/lib/jvm/java-1.7.0' >> /etc/environment"
ssh -t -t $SSH_OPTS root@$node "echo 'SCALA_HOME=/root/scala' >> /etc/environment"
ssh -t -t $SSH_OPTS root@$node "echo 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/root/scala/bin:/usr/lib/jvm/java-1.7.0/bin' >> /etc/environment"
done
wait

# Always include 'scala' module if it's not defined as a work around
# for older versions of the scripts.
if [[ ! $MODULES =~ *scala* ]]; then
MODULES=$(printf "%s\n%s\n" "scala" $MODULES)
fi

# Install / Init module
for module in $MODULES; do
echo "Initializing $module"
if [[ -e $module/init.sh ]]; then
source $module/init.sh
fi
cd /root/spark-euca  # guard against init.sh changing the cwd
done

#TODO: Start zookeeper from wherever is actually located
if [[ $NUM_ZOOS != 0 ]]; then
echo "Starting ZooKeeper quorum..."
for zoo in $ZOOS; do
ssh $SSH_OPTS $zoo "/root/mesos/third_party/zookeeper-*/bin/zkServer.sh start </dev/null >/dev/null" & sleep 0.1
done
wait
sleep 5
fi

# Deploy templates
# TODO: Move configuring templates to a per-module ?
echo "Creating local config files..."
./deploy_templates.py

# Copy spark conf by default
echo "Deploying Spark config files..."
chmod u+x /root/spark/conf/spark-env.sh
/root/spark-euca/copy-dir /root/spark/conf

# Setup each module
for module in $MODULES; do
echo "Setting up $module"
source ./$module/setup.sh
sleep 1
cd /root/spark-euca  # guard against setup.sh changing the cwd
done
#echo "Running setup.sh from spark-testing/persistent-hdfs"
#source /root/spark-testing/persistent-hdfs/setup.sh
#cd /root/spark-euca  # guard against setup.sh changing the cwd
#sleep 1
