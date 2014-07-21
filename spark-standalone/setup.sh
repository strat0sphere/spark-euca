#!/bin/bash

BIN_FOLDER="/root/spark/sbin"

if [[ "0.7.3 0.8.0 0.8.1" =~ $SPARK_VERSION ]]; then
  BIN_FOLDER="/root/spark/bin"
fi

# Copy the slaves to spark conf
cp /root/spark-euca/slaves /root/spark/conf/
/root/spark-euca/copy-dir /root/spark/conf

# Set cluster-url to standalone master
echo "spark://""`cat /root/spark-euca/masters`"":7077" > /root/spark-euca/cluster-url
/root/spark-euca/copy-dir /root/spark-euca

# The Spark master seems to take time to start and workers crash if
# they start before the master. So start the master first, sleep and then start
# workers.

# Stop anything that is running
$BIN_FOLDER/stop-all.sh

sleep 2

# Start Master
$BIN_FOLDER/start-master.sh

# Pause
sleep 20

# Start Workers
$BIN_FOLDER/start-slaves.sh
