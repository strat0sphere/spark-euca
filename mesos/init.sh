#!/bin/bash

pushd /root
MESOS_SETUP_VERSION='0.27.2'
MESOS_LOCATION='/mnt'

if [ -d "mesos-$MESOS_SETUP_VERSION" ]; then
echo "Mesos seems to be installed. Exiting."
return 0
fi
echo "Moving to $MESOS_LOCATION for more free space..."
cd $MESOS_LOCATION
echo "Initializing $MESOS_SETUP_VERSION"
wget http://archive.apache.org/dist/mesos/$MESOS_SETUP_VERSION/mesos-$MESOS_SETUP_VERSION.tar.gz
echo "Unpacking Mesos"
tar xvzf mesos-$MESOS_SETUP_VERSION.tar.gz > /tmp/spark-euca_mesos.log
rm mesos-$MESOS_SETUP_VERSION.tar.gz
#mv mesos-$MESOS_SETUP_VERSION/ mesos/
echo "Done!"

popd
