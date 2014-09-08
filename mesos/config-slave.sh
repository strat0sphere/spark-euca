#ATTENTION: User the IP used on the file /usr/local/var/mesos/deploy/slaves  and .../masters
nohup /usr/local/sbin/mesos-slave --log_dir=/mnt/mesos-logs --master=euca-128-111-179-167.eucalyptus.race.cs.ucsb.edu:5050 </dev/null >/dev/null 2>&1 &
## OR: nohup /usr/local/sbin/mesos-slave start --log_dir=/mnt/mesos-logs --master=10.2.175.248:5050


#Options to consider
# --hadoop_home=VALUE
#Where to find Hadoop installed (for fetching framework executors from HDFS) (no default, look for HADOOP_HOME in environment or find hadoop on PATH) (default: )

#--isolation=VALUE #Isolation mechanism, may be one of: process, cgroups (default: process)

#--work_dir=VALUE                           #Where to place framework work directories (default: /tmp/mesos)
