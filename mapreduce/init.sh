#!/bin/bash

pushd /root
case "$HADOOP_MAJOR_VERSION" in
  1)
    echo "Nothing to initialize for MapReduce in Hadoop 1"
    ;;
  2) 
    wget http://php.cs.ucsb.edu/spark-related-packages/mr1-2.0.0-mr1-cdh4.2.0.tar.gz 
    tar -xvzf mr1-*.tar.gz > /tmp/spark-euca_mapreduce.log
    rm mr1-*.tar.gz
    mv hadoop-2.0.0-mr1-cdh4.2.0/ mapreduce/
    ;;

  *)
     echo "ERROR: Unknown Hadoop version"
     return -1
esac
/root/spark-euca/copy-dir /root/mapreduce
popd
