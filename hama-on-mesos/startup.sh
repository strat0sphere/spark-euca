#!/bin/bash

pushd /root

cd hama

./bin/hama-daemon.sh start bspmaster

echo "HOSTNAME=$HOSTNAME"

echo "cat /mnt/hama/logs/hama-root-bspmaster-$HOSTNAME.log"
cat /mnt/hama/logs/hama-root-bspmaster-$HOSTNAME.log

echo "cat /mnt/hama/logs/hama-root-bspmaster-$HOSTNAME.out"
cat /mnt/hama/logs/hama-root-bspmaster-$HOSTNAME.out

popd