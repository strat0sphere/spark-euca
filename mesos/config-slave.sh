#ATTENTION: User the IP used on the file /usr/local/var/mesos/deploy/slaves  and .../masters
#nohup /root/mesos-installation/sbin/mesos-slave --log_dir=/mnt/mesos-logs --master=euca-128-111-179-167.eucalyptus.race.cs.ucsb.edu:5050 </dev/null >/dev/null 2>&1 &
export LD_LIBRARY_PATH=/root/mesos-$MESOS_VERSION/build/src/.libs/
#with zookeper
nohup /root/mesos-installation/sbin/mesos-slave --log_dir=/mnt/mesos-logs --master=zk://10.2.7.122:2181/mesos </dev/null >/dev/null 2>&1 &

#HACK: Modify the script called internally from mesos to target hadoop
#This is not needed if a cloudera version is used
#TODO Create the command hadoop to target on the existing hdfs installation
#cat "#/bin/bash" >> /usr/bin/hadoop
#cat 'exec /root/ephemeral-hdfs/bin/hadoop "$@"'>> /usr/bin/hadoop

## OR: nohup /usr/local/sbin/mesos-slave start --log_dir=/mnt/mesos-logs --master=10.2.175.248:5050


#Options to consider
# --hadoop_home=VALUE
#Where to find Hadoop installed (for fetching framework executors from HDFS) (no default, look for HADOOP_HOME in environment or find hadoop on PATH) (default: )

#--isolation=VALUE #Isolation mechanism, may be one of: process, cgroups (default: process)

#--work_dir=VALUE                           #Where to place framework work directories (default: /tmp/mesos)

#For Mesos 0.20.0 with Zookeeper
nohup /mesos-installation/sbin/mesos-slave --log_dir=/mnt/mesos-logs --work_dir=/mnt/mesos-work-dir/ --master=zk://10.2.24.25:2181/mesos </dev/null >/dev/null 2>&1 &