#!/bin/bash

#echo 'exclude=pam*' >> /etc/yum.conf;yum update
exclude=pam; yum update
yum -y install wget
yum -y install git
yum -y java-1.7.0-openjdk
mv /usr/lib/jvm/java-1.7.0-openjdk-1.7.0.65.x86_64/ /usr/lib/jvm/java-1.7.0/
wget http://downloads.typesafe.com/scala/2.11.1/scala-2.11.1.tgz
tar xvf scala-2.11.1.tgz
mv scala-2.11.1 scala
rm scala-2.11.1.tgz
