#!/bin/bash

apt-get update
#apt-get --yes --force-yes install wget
apt-get --yes --force-yes install git
apt-get --yes --force-yes install openjdk-7-jdk
apt-get --yes --force-yes install scala
wget https://archive.apache.org/dist/hadoop/core/hadoop-1.0.4/hadoop-1.0.4.tar.gz
mv /usr/lib/jvm/java-7-openjdk-amd64/ /usr/lib/jvm/java-1.7.0/
#echo export http_proxy=http_proxy_option >> ~/.bash_profile
#echo 'export JAVA_HOME=/usr/lib/jvm/java-1.7.0'  >> ~/.bash_profile
#echo 'export SCALA_HOME=/root/scala' >> ~/.bash_profile
#echo 'export PATH=$PATH:/root/scala/bin:/usr/lib/jvm/java-1.7.0/bin' >> ~/.bash_profile
#cp /home/ubuntu/.bash_profile /root/.bash_profile
#source /root/.bash_profile
#source /root/.profile
