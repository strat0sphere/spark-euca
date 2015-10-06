#!/bin/bash
apt-get -qq --yes --force-yes install maven
cd /root
mkdir /executor_tars
chown -R hdfs:hadoop /executor_tars

rm -rf /root/spark-1.2.1
rm -rf spark
rm spark-1.2.1.tgz

wget http://d3kbcqa49mib13.cloudfront.net/spark-1.2.1.tgz
echo "Untarring Spark..."
tar zxfv spark-1.2.1.tgz
rm spark-1.2.1.tgz
pushd /root/spark-1.2.1

echo "Setting JAVA_HOME to /usr/lib/jvm/java-1.6.0"
export JAVA_HOME=/usr/lib/jvm/java-1.6.0

./make-distribution.sh --tgz -Dhadoop.version=2.3.0-mr1-cdh5.1.2

popd

echo "Packing spark..."
cd /root
tar czfv spark-1.2.1-bin-2.3.0-mr1-cdh5.1.2.tgz spark-1.2.1
mv spark-1.2.1-bin-2.3.0-mr1-cdh5.1.2.tgz /executor_tars/
mv spark-1.2.1 spark

echo "Setting JAVA_HOME to /usr/lib/jvm/java-1.7.0"
export JAVA_HOME=/usr/lib/jvm/java-1.7.0
