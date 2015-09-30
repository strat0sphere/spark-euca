#!/bin/bash
echo "Installing hadoop-hdfs-namenode ..."
sudo apt-get --yes --force-yes install hadoop-hdfs-namenode
echo "Running: update-rc.d hadoop-hdfs-namenode defaults"
update-rc.d hadoop-hdfs-namenode defaults