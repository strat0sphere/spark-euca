#!/bin/bash
echo "Installing hadoop-hdfs-namenode ..."
sudo apt-get --yes --force-yes -o Dpkg::Options::=--force-confdef install hadoop-hdfs-namenode
echo "Running: update-rc.d hadoop-hdfs-namenode defaults"
update-rc.d hadoop-hdfs-namenode defaults