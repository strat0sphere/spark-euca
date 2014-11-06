#/bin/bash

pushd /root

cd hama

#Build with 2.3.0-cdh5.1.2 even if your version is 2.3.0-mr1-cdh5.1.2 otherwise you will have to do the following:
#On pom.xml under the "build for Hadoop 2.x properties" change hadoop-common, hadoop-hdfs, hadoop-hdfs with classifer tests, hadoop-mapreduce-client-core and hadoop-auth to 2.3.0-cdh5.1.2 instead of hadoop.version

echo "Copying Hama configuration..."
cp /etc/hama/conf/* conf/

echo "Deleting Hama configuration dir on /etc"
echo "Copying Hama configuration..."
rm -rf /etc/hama/conf/

echo "Building hama... mvn clean install -Phadoop2 -Dhadoop.version=2.3.0-cdh5.1.2 -Dmesos.version=0.20.0"
mvn clean install -Phadoop2 -Dhadoop.version=2.3.0-cdh5.1.2 -Dmesos.version=0.20.0 -DskipTests


#For hama-0.64 commons-collections jar is missing --> cp ~/hama/lib/commons-collections-3.2.1.jar ~/hama-0.6.4/dist/target/hama-0.6.4/hama-0.6.4/lib/

#Make scripts executable
#chmod +x /bin/* --> not needed if you take jar from the /dist directory

#Case1: --- Rebuilding hama ----
echo "Putting hama-0.7.0-SNAPSHOT.tar.gz to HDFS..."
hadoop fs -put dist/target/hama-0.7.0-SNAPSHOT.tar.gz /hama.tar.gz
hadoop fs -ls /

#Case2: ---- Resume operation from emi  ----
#pushd /root
#mkdir /executor_tars
#wget -P /executor_tars http://php.cs.ucsb.edu/spark-related-packages/executor_tars/hama-0.6.4-hadoop-2.3.0-mr1-cdh5.1.2-mesos-0.20.0.tar.gz

#Rename tar file because hama is expecting hama directory when it untars the file!
#cd /executor_tars
#mv hama-0.6.4-hadoop-2.3.0-mr1-cdh5.1.2-mesos-0.20.0.tar.gz hama.tar.gz

#chown -R hdfs:hadoop /executor_tars

#echo "Putting hama-0.6.4-hadoop-2.3.0-mr1-cdh5.1.2-mesos-0.20.0.tar.gz to HDFS..."
#/executor_tars directory already exists on the emi
#hadoop fs -put /executor_tars/hama.tar.gz /

#delete to save some space if necessary
#rm /executor_tars/hama.tar.gz

popd
