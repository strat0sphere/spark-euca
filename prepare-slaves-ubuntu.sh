#!/bin/bash
apt-get update
apt-get --yes --force-yes install git
apt-get --yes --force-yes install openjdk-7-jdk
mv /usr/lib/jvm/java-7-openjdk-amd64 /usr/lib/jvm/java-1.7.0
wget http://downloads.typesafe.com/scala/2.11.1/scala-2.11.1.tgz
tar xvf scala-2.11.1.tgz
mv scala-2.11.1 scala
rm scala-2.11.1.tgz

#If we want to format the attached volume with xfs the following should not be in comments
#apt-get --yes --force-yes install xfsprogs

apt-get --yes --force-yes install libgfortran3
#apt-get install libatlas3-base libopenblas-base
#update-alternatives --config libblas.so.3
#update-alternatives --config liblapack.so.3

.~/spark-euca/mesos/setup.sh #FIX this. Change target dirs and just copy compiled files to slaves instead of running setup again

