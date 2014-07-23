#!/bin/bash

echo 'exclude=pam*' >> /etc/yum.conf;yum update
yum -y install wget
yum -y install git
yum -y java-1.7.0-openjdk
#wget https://archive.apache.org/dist/hadoop/core/hadoop-1.0.4/hadoop-1.0.4.tar.gz
mv /usr/lib/jvm/java-1.7.0-openjdk-1.7.0.65.x86_64/ /usr/lib/jvm/java-1.7.0/
wget http://downloads.typesafe.com/scala/2.11.1/scala-2.11.1.tgz
tar xvf scala-2.11.1.tgz
mv scala-2.11.1 scala
#echo export http_proxy=http_proxy_option >> ~/.bash_profile
#echo 'export JAVA_HOME=/usr/lib/jvm/java-1.7.0'  >> ~/.bash_profile
#echo 'export SCALA_HOME=/root/scala' >> ~/.bash_profile
#echo 'export PATH=$PATH:/root/scala/bin:/usr/lib/jvm/java-1.7.0/bin' >> ~/.bash_profile
#cp /home/ubuntu/.bash_profile /root/.bash_profile
#source /root/.bash_profile
#source /root/.profile
