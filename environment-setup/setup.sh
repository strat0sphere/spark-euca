#!/bin/bash
apt-get update
apt-get --yes --force-yes install git
apt-get --yes --force-yes install openjdk-7-jdk
mv /usr/lib/jvm/java-7-openjdk-amd64 /usr/lib/jvm/java-1.7.0
wget http://downloads.typesafe.com/scala/2.11.1/scala-2.11.1.tgz
tar xvf scala-2.11.1.tgz
mv scala-2.11.1 scala
rm scala-2.11.1.tgz

apt-get --yes --force-yes install libgfortran3


