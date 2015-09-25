#/bin/bash

service kafka-server start
sleep 5.0
echo "Printing kafka.out content..."
tail /mnt/kafka-logs/kafka.out

echo "Executing 'ps -ef | grep kafka' ..."
ps -ef | grep kafka
