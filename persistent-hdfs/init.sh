#!/bin/bash

pushd /root

if [ -d "persistent-hdfs" ]; then
  echo "Persistent HDFS seems to be installed. Exiting."
  return 0
fi

case "$HADOOP_MAJOR_VERSION" in
  1)
    wget http://s3.amazonaws.com/spark-related-packages/hadoop-1.0.4.tar.gz
    #wget https://archive.apache.org/dist/hadoop/core/hadoop-1.0.4/hadoop-1.0.4.tar.gz
    echo "Unpacking Hadoop"
    tar xvzf hadoop-1.0.4.tar.gz > /tmp/spark-euca_hadoop.log
    rm hadoop-*.tar.gz
    mv hadoop-1.0.4/ persistent-hdfs/
    ;;
  2)
   wget http://s3.amazonaws.com/spark-related-packages/hadoop-2.0.0-cdh4.2.0.tar.gz
   #wget --output-document="hadoop-2.0.0-cdh4.2.0.tar.gz" http://archive.cloudera.com/cdh4/cdh/4/bigtop-jsvc-1.0.10-cdh4.2.0.tar.gz
    echo "Unpacking Hadoop"
    tar xvzf hadoop-*.tar.gz > /tmp/spark-euca_hadoop.log
    rm hadoop-*.tar.gz
    mv hadoop-2.0.0-cdh4.2.0/ persistent-hdfs/

    # Have single conf dir
    rm -rf /root/persistent-hdfs/etc/hadoop/
    ln -s /root/persistent-hdfs/conf /root/persistent-hdfs/etc/hadoop
    ;;

  *)
     echo "ERROR: Unknown Hadoop version"
     return -1
esac
cp /root/hadoop-native/* /root/persistent-hdfs/lib/native/
/root/spark-euca/copy-dir /root/persistent-hdfs
popd
