#!/bin/bash

pushd /root

cd hama

echo "DEBUG: Print env variables"
env
export LD_LIBRARY_PATH=/root/mesos-installation/lib/
./bin/hama-daemon.sh start bspmaster

echo "HOSTNAME=$HOSTNAME"

echo "cat /mnt/hama/logs/hama-root-bspmaster-$HOSTNAME.log"
cat /mnt/hama/logs/hama-root-bspmaster-$HOSTNAME.log

echo "cat /mnt/hama/logs/hama-root-bspmaster-$HOSTNAME.out"
cat /mnt/hama/logs/hama-root-bspmaster-$HOSTNAME.out

popd