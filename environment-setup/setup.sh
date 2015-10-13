#!/bin/bash
cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
apt-get -q update
apt-get -q --yes --force-yes install make
apt-get -q --yes --force-yes install git

apt-get -q --yes --force-yes install openjdk-7-jdk
mv /usr/lib/jvm/java-7-openjdk-amd64 /usr/lib/jvm/java-1.7.0
update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-1.7.0/jre/bin/java 2
update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-1.7.0/bin/javac 2

apt-get -q --yes --force-yes install openjdk-6-jdk
mv /usr/lib/jvm/java-6-openjdk-amd64 /usr/lib/jvm/java-1.6.0
update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-1.6.0/jre/bin/java 1
update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-1.6.0/bin/javac 2

update-alternatives --install /usr/bin/jps jps /usr/lib/jvm/java-1.7.0/bin/jps 1

wget http://downloads.typesafe.com/scala/2.11.1/scala-2.11.1.tgz
tar xvf scala-2.11.1.tgz
mv scala-2.11.1 scala
rm scala-2.11.1.tgz

apt-get -q --yes --force-yes install libgfortran3

echo "Adding groups..."
groupadd mapred; groupadd hdfs; groupadd hadoop
#Add users as they don't exist in case of the empty emi
echo "Adding users..."
useradd -g mapred mapred; useradd -g hdfs hdfs

echo "Appending users to groups..."
usermod -a -G hadoop mapred; usermod -a -G hadoop hdfs; usermod -a -G hadoop,mapred root

echo "Giving +x to all on root..."
chmod +x /root/


