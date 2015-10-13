#!/bin/bash
echo "Installing hadoop-hdfs-namenode ..."
mv /etc/zookeeper/conf.dist/zoo.cfg /tmp/zoo.cfg
mv /etc/zookeeper/conf.dist/log4j.properties /tmp/log4j.properties

apt-get -qq --yes --force-yes -o Dpkg::Options::=--force-confdef install hadoop-hdfs-namenode

#Ungly hack to avoid prompt for chosing configuration file
mv /tmp/zoo.cfg /etc/zookeeper/conf.dist/zoo.cfg
mv /tmp/log4j.properties /etc/zookeeper/conf.dist/log4j.properties

echo "Running: update-rc.d hadoop-hdfs-namenode defaults"
update-rc.d hadoop-hdfs-namenode defaults