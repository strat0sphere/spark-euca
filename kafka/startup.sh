#/bin/bash

service kafka-server start
sleep 10
tail /mnt/kafka-logs/kafka.out
ps -ef | grep kafka
