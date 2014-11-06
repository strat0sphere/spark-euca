#/bin/bash

echo "I love UCSB" > /tmp/file0
echo "Do you love UCSB?" > /tmp/file1
chown hdfs:hadoop /tmp/file0
chown hdfs:hadoop /tmp/file1

hadoop fs -mkdir -p /user/foo/data
hadoop fs -put /tmp/file? /user/foo/data

echo "Executing: hadoop jar /usr/lib/hadoop-0.20-mapreduce/hadoop-examples-2.3.0-mr1-cdh5.1.2.jar wordcount /user/foo/data /user/foo/out"

hadoop jar /usr/lib/hadoop-0.20-mapreduce/hadoop-examples-2.3.0-mr1-cdh5.1.2.jar wordcount /user/foo/data /user/foo/out
hadoop fs -ls /user/foo/out
hadoop fs -cat /user/foo/out/part*