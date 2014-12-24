#/bin/bash

#start-up script at /etc/kafka
service kafka-server start
tail /mnt/kafka-logs/kafka.out

ps -ef | grep kafka