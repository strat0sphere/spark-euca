#!/bin/bash

service storm-nimbus start
sleep 10.0
echo "Executing ps -ef | grep storm..."
ps -ef | grep storm
echo "Printing nimbus.out..."
cat /mnt/storm-logs/nimbus.out
service storm-ui start
sleep 10.0
echo "Printing ui.out..."
tail /mnt/storm-logs/ui.log