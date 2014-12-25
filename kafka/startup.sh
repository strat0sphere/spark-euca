#/bin/bash

service kafka-server start
tail /mnt/kafka-logs/kafka.out
ps -ef | grep kafka
