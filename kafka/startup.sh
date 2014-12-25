#/bin/bash

#start-up script at /etc/kafka
service kafka-server start
sleep 10
tail /mnt/kafka-logs/kafka.out

ps -ef | grep kafka

/root/kafka/bin/kafka-server-start.sh /root/kafka/config/server.properties > /mnt/kafka-logs/kafka.out 2>&1 &

tail /mnt/kafka-logs/kafka.out

ps -ef | grep kafka