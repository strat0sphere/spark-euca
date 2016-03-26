#!/bin/bash
apt-get update
apt-get install -y autoconf libtool
apt-get -y install build-essential python-dev python-boto libcurl4-nss-dev libsasl2-dev libsasl2-modules maven libapr1-dev libsvn-dev
chmod +x install-modules-prereq.sh
./install-modules-prereq.sh
MESOS_SETUP_VERSION='0.27.2'
MESOS_LOCATION="/mnt"
echo "MESOS_SETUP_VERSION = $MESOS_SETUP_VERSION"
#apt-get -qq --yes --force-yes install build-essential
#apt-get -qq --yes --force-yes install python-dev python-boto
#apt-get -qq --yes --force-yes install libcurl4-nss-dev
#apt-get -qq --yes --force-yes install libsasl2-dev
#apt-get -qq --yes --force-yes install maven
#apt-get -qq --yes --force-yes install build-essential
#apt-get -qq --yes --force-yes install libapr1-dev
#apt-get -qq --yes --force-yes install libsvn-dev

#Building Mesos
# Change working directory.
cd $MESOS_LOCATION/mesos-$MESOS_SETUP_VERSION

# Bootstrap (***Skip this if you are not building from git repo***).
#./bootstrap

# Configure and build.
mkdir /root/mesos-installation/
chmod +x /root/mesos-installation/
mkdir build
cd build
echo "Running configure..."
../configure --with-glog=/usr/local --with-protobuf=/usr --with-boost=/usr/local --prefix=/root/mesos-installation --disable-python

echo "Running make..."
make -j 4 V=0

# Install (***Optional***).

echo "Installing..."
make -j 4 V=0 install

#TODO: SET LD_LIBRARY_PATH CORRECTLY ON EMI
#delete previous LD_LIBRARY_PATH
sed -i '/LD_LIBRARY_PATH=/d'  /etc/environment
echo "LD_LIBRARY_PATH=/root/mesos-installation/lib" >> /etc/environment
export LD_LIBRARY_PATH=/root/mesos-installation/lib/

#echo "Removing mesos-0.27.1"
#rm -rf /root/mesos-0.27.1
#echo "Done!"
# Run test suite -- Also builds example frameworks
#make check #Run make check at the end because some tests fail (VERSION 0.18.1)

echo "Copy mesos-config"
cp /root/mesos-config/* /root/mesos-installation/

#echo "Removing mesos-config directory..."
#rm -rf /root/mesos-config

