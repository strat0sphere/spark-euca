#!/bin/bash

pushd /root

if [ -d "mesos-$MESOS_SETUP_VERSION" ]; then
echo "Mesos seems to be installed. Exiting."
return 0
fi

#Remove old installed version
echo "Removing old mesos-installation"
rm -rf mesos-installation

echo "Initializing $MESOS_SETUP_VERSION"
MESOS_SETUP_VERSION=$MESOS_SETUP_VERSION
wget http://archive.apache.org/dist/mesos/$MESOS_SETUP_VERSION/mesos-$MESOS_SETUP_VERSION.tar.gz
echo "Unpacking Mesos"
tar xvzf mesos-$MESOS_SETUP_VERSION.tar.gz > /tmp/spark-euca_mesos.log
rm mesos-$MESOS_SETUP_VERSION.tar.gz
#mv mesos-$MESOS_SETUP_VERSION/ mesos/

popd
