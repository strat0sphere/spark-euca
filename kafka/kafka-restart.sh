#!/bin/bash

#To avoid bug of Kafka on boot we first stop kafka and then start
echo "Restarting kafka..."
service kafka-server restart
tail /mnt/kafka-logs/kafka.out