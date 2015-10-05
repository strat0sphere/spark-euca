#!/bin/bash
apt-get -q update
apt-get -q --yes --force-yes install git

apt-get -q --yes --force-yes install openjdk-7-jdk
mv /usr/lib/jvm/java-7-openjdk-amd64 /usr/lib/jvm/java-1.7.0
update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-1.7.0/jre/bin/java 2
update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-1.7.0/bin/javac 2

apt-get -q --yes --force-yes install openjdk-6-jdk
mv /usr/lib/jvm/java-6-openjdk-amd64 /usr/lib/jvm/java-1.6.0
update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-1.6.0/jre/bin/java 1
update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-1.6.0/bin/javac 2

wget http://downloads.typesafe.com/scala/2.11.1/scala-2.11.1.tgz
tar xvf scala-2.11.1.tgz
mv scala-2.11.1 scala
rm scala-2.11.1.tgz

apt-get -q --yes --force-yes install libgfortran3


