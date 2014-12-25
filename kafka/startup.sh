#/bin/bash

#start-up script at /etc/kafka
#echo "DEBUG: Starting kafka..."
#service kafka-server start
#echo "DEBUG: Sleeping..."
#sleep 10
#tail /mnt/kafka-logs/kafka.out

#ps -ef | grep kafka

echo "DEBUG: Starting kafka running: /root/kafka/bin/kafka-server-start.sh /root/kafka/config/server.properties > /mnt/kafka-logs/kafka.out 2>&1 & ..."

/root/kafka/bin/kafka-server-start.sh /root/kafka/config/server.properties > /mnt/kafka-logs/kafka.out 2>&1 &

sleep 10

tail /mnt/kafka-logs/kafka.out

ps -ef | grep kafka