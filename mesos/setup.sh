#!/bin/bash
MESOS_SETUP_VERSION='0.21.1'
echo "MESOS_SETUP_VERSION = $MESOS_SETUP_VERSION"
apt-get -qq --yes --force-yes install build-essential
apt-get -qq --yes --force-yes install python-dev python-boto
apt-get -qq --yes --force-yes install libcurl4-nss-dev
apt-get -qq --yes --force-yes install libsasl2-dev
apt-get -qq --yes --force-yes install maven
apt-get -qq --yes --force-yes install build-essential
apt-get -qq --yes --force-yes install libapr1-dev
apt-get -qq --yes --force-yes install libsvn-dev

#Building Mesos
# Change working directory.
cd /root/mesos-$MESOS_SETUP_VERSION

# Bootstrap (***Skip this if you are not building from git repo***).
#./bootstrap

# Configure and build.
mkdir /root/mesos-installation/
chmod +x /root/mesos-installation/
mkdir build
cd build
echo "Running configure..."
../configure --prefix=/root/mesos-installation/
echo "Running make..."
make -j 2

# Install (***Optional***).

echo "Installing..."
make -j 2 install

#TODO: SET LD_LIBRARY_PATH CORRECTLY ON EMI
#delete previous LD_LIBRARY_PATH
sed -i '/LD_LIBRARY_PATH=/d'  /etc/environment
echo "LD_LIBRARY_PATH=/root/mesos-installation/lib" >> /etc/environment
export LD_LIBRARY_PATH=/root/mesos-installation/lib/

echo "Removing mesos-0.21.1"
rm -rf /root/mesos-0.21.1
echo "Done!"
# Run test suite -- Also builds example frameworks
#make check #Run make check at the end because some tests fail (VERSION 0.18.1)

