#!/bin/bash

pushd /root

cd hama

#Necessary to export LD_LIBRARY_PATH since the ssh session of setting it is on /etc/enf is not finished yet. Otherwise the following error occurs: java.io.IOException: Call to euca-10-2-112-26.eucalyptus.internal/10.2.112.26:40000 failed on local exception: java.io.IOException: Connection reset by peer

export LD_LIBRARY_PATH=/root/mesos-installation/lib/


./bin/hama-daemon.sh start bspmaster

echo "HOSTNAME=$HOSTNAME"

echo "cat /mnt/hama/logs/hama-root-bspmaster-$HOSTNAME.log"
cat /mnt/hama/logs/hama-root-bspmaster-$HOSTNAME.log

echo "cat /mnt/hama/logs/hama-root-bspmaster-$HOSTNAME.out"
cat /mnt/hama/logs/hama-root-bspmaster-$HOSTNAME.out

popd