#!/bin/bash

apt-get --yes --force-yes install build-essential
#apt-get --yes --force-yes install openjdk-6-jdk
apt-get --yes --force-yes install python-dev python-boto
apt-get --yes --force-yes install libcurl4-nss-dev
apt-get --yes --force-yes install libsasl2-dev
apt-get --yes --force-yes install maven

download_method=$1
if [[ "$DOWNLOAD_METHOD" == "git" ]] ; then
apt-get --yes --force-yes install autoconf
apt-get --yes --force-yes install libtool
fi



#Building Mesos
# Change working directory.
cd mesos

# Bootstrap (***Skip this if you are not building from git repo***).
#./bootstrap

# Configure and build.
mkdir build
cd build
../configure
make

# Run test suite -- Also builds example frameworks
#make check

# Install (***Optional***).
mkdir /root/mesos-installation/
make install --prefix /root/mesos-installation/

/root/spark-euca/copy-dir /root/mesos
/root/spark-euca/copy-dir /root/mesos-installation/