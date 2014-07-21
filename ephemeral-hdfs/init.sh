#!/bin/bash

pushd /root

if [ -d "ephemeral-hdfs" ]; then
  echo "Ephemeral HDFS seems to be installed. Exiting."
  return 0
fi

case "$HADOOP_MAJOR_VERSION" in
  1)
    wget https://archive.apache.org/dist/hadoop/core/hadoop-1.0.4/hadoop-1.0.4.tar.gz
    echo "Unpacking Hadoop"
    tar xvzf hadoop-1.0.4.tar.gz > /tmp/spark-euca_hadoop.log
    rm hadoop-*.tar.gz
    mv hadoop-1.0.4/ ephemeral-hdfs/
    sed -i 's/-jvm server/-server/g' /root/ephemeral-hdfs/bin/hadoop
    ;;
  2) 
    wget --output-document="hadoop-2.0.0-cdh4.2.0.tar.gz" http://archive.cloudera.com/cdh4/cdh/4/bigtop-jsvc-1.0.10-cdh4.2.0.tar.gz
    echo "Unpacking Hadoop"
    tar xvzf hadoop-*.tar.gz > /tmp/spark-euca_hadoop.log
    rm hadoop-*.tar.gz
    mv hadoop-2.0.0-cdh4.2.0/ ephemeral-hdfs/

    # Have single conf dir
    rm -rf /root/ephemeral-hdfs/etc/hadoop/
    ln -s /root/ephemeral-hdfs/conf /root/ephemeral-hdfs/etc/hadoop
    ;;

  *)
     echo "ERROR: Unknown Hadoop version"
     return -1
esac
cp /root/hadoop-native/* ephemeral-hdfs/lib/native/
/root/spark-euca/copy-dir /root/ephemeral-hdfs
popd
