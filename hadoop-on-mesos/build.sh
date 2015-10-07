#!/bin/bash

echo "Making sure maven is installed..."
apt-get -qq --yes --force-yes install maven

echo "Removing hadoop-2.3.0-cdh5.1.2.tar.gz if exists..."
rm hadoop-2.3.0-cdh5.1.2.tar.gz

echo "Getting hadoop-2.3.0-cdh5.1.2.tar.gz..."
wget http://archive.cloudera.com/cdh5/cdh/5/hadoop-2.3.0-cdh5.1.2.tar.gz

echo "Untarring hadoop-2.3.0-cdh5.1.2.tar.gz..."
tar zxf hadoop-2.3.0-cdh5.1.2.tar.gz

echo "Deleting tar file..."
rm hadoop-2.3.0-cdh5.1.2.tar.gz

echo "Cloning Hadoop-on-mesos..."
rm hadoopOnMesos
git clone https://github.com/strat0sphere/hadoop.git hadoopOnMesos
cd /root/hadoopOnMesos

echo "Running mvn package..."
mvn package
cp target/hadoop-mesos-0.0.8.jar /usr/lib/hadoop-0.20-mapreduce/lib/
cp target/hadoop-mesos-0.0.8.jar /root/hadoop-2.3.0-cdh5.1.2/share/hadoop/common/lib/

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

echo "Moving hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz to /executor_tars"
mv hadoop-2.3.0-cdh5.1.2-mesos.0.21.1.tar.gz /executor_tars

echo "Listing executor_tars files:"
ls /executor_tars


