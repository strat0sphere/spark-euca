#!/bin/bash

cd /root/hadoopOnMesos
cp target/hadoop-mesos-0.0.8.jar /usr/lib/hadoop-0.20-mapreduce/lib/
/root/spark-euca/copy-dir-generic /usr/lib/hadoop-0.20-mapreduce/lib/ masters

cd /root/hadoopOnMesos
echo "Creating jar file..."
cp target/hadoop-mesos-0.0.8.jar /root/hadoop-2.3.0-cdh5.1.2/share/hadoop/common/lib/
echo "Copying hadoop lib to masters..."
/root/spark-euca/copy-dir-generic /root/hadoop-2.3.0-cdh5.1.2/share/hadoop/common/lib/ masters

cd /root
echo "Removing old jar file.."
rm hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz
tar cvfz hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz hadoop-2.3.0-cdh5.1.2
rm /executor_tars/hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz
mv hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz /executor_tars
chown -R hdfs:hadoop /executor_tars/hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz
hadoop fs -rm -r -f /hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz

echo "Putting to HDFS..."
sudo -u hdfs hadoop fs -put /executor_tars/hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz /
rm /executor_tars/hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz
hadoop fs -chown hdfs:hadoop /hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz
hadoop fs -ls /
