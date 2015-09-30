#!/bin/bash

wget http://archive.cloudera.com/cdh5/cdh/5/hadoop-2.3.0-cdh5.1.2.tar.gz
tar zxf hadoop-2.3.0-cdh5.1.2.tar.gz
/Users/stratos/Development/spark-euca/hadoop-on-mesos/build.sh
git clone https://github.com/strat0sphere/hadoop.git hadoopOnMesos
cd hadoopOnMesos
mvn package
cp target/hadoop-mesos-0.0.8.jar /usr/lib/hadoop-0.20-mapreduce/lib/
cp target/hadoop-mesos-0.0.8.jar hadoop-2.3.0-cdh5.1.2/share/hadoop/common/lib/

cd /root/hadoop-2.3.0-cdh5.1.2

#configure cdh5 to run map reduce 1 and not yarn
mv bin bin-mapreduce2
mv examples examples-mapreduce2
ln -s bin-mapreduce1 bin
ln -s examples-mapreduce1 examples

pushd etc
mv hadoop hadoop-mapreduce2
ln -s hadoop-mapreduce1 hadoop
popd

pushd share/hadoop
rm mapreduce
ln -s mapreduce1 mapreduce
popd

cd /root #make sure you are on root dir

#pack to be ready to upload to HDFS
echo "Packing hadoop-on-mesos..."
tar czf hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz hadoop-2.3.0-cdh5.1.2


