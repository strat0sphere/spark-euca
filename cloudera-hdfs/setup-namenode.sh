#!/bin/bash
echo "Installing hadoop-hdfs-namenode ..."
mv /etc/zookeeper/conf.dist/zoo.cfg /etc/zookeeper/conf.dist/zoo.cfg.bk
mv /etc/zookeeper/conf.dist/log4j.properties /etc/zookeeper/conf.dist/log4j.properties.bk

apt-get -q --yes --force-yes -o Dpkg::Options::=--force-confdef install hadoop-hdfs-namenode

#Ungly hack to avoid prompt for chosing configuration file
mv /etc/zookeeper/conf.dist/zoo.cfg.bk /etc/zookeeper/conf.dist/zoo.cfg
mv /etc/zookeeper/conf.dist/log4j.properties.bk /etc/zookeeper/conf.dist/log4j.properties

echo "Running: update-rc.d hadoop-hdfs-namenode defaults"
update-rc.d hadoop-hdfs-namenode defaults