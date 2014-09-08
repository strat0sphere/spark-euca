#!/bin/bash

pushd /root

if [ -d "mesos" ]; then
echo "Mesos seems to be installed. Exiting."
return 0
fi
echo "Initializing $MESOS_VERSION"
MESOS_VERSION=$MESOS_VERSION
wget http://archive.apache.org/dist/mesos/$MESOS_VERSION/mesos-$MESOS_VERSION.tar.gz
echo "Unpacking Mesos"
tar xvzf mesos-$MESOS_VERSION.tar.gz > /tmp/spark-euca_mesos.log
rm mesos-$MESOS_VERSION.tar.gz
mv mesos-$MESOS_VERSION/ mesos/

/root/spark-euca/copy-dir /root/mesos
popd
