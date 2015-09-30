#!/bin/bash
echo "Installing hadoop-hdfs-datanode..."
sudo apt-get --yes --force-yes install hadoop-hdfs-datanode
echo "Installing hadoop-client..."
sudo apt-get --yes --force-yes install hadoop-client
echo "Running: update-rc.d hadoop-hdfs-datanode defaults"
update-rc.d hadoop-hdfs-datanode defaults