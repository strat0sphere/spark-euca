#!/bin/bash

pushd /root
tar -xzf kafka_${KAFKA_SCALA_BINARY}.tgz
rm kafka_${KAFKA_SCALA_BINARY}.tgz
mv kafka_${KAFKA_SCALA_BINARY} kafka

cp /etc/kafka/config/server.properties ./config/

#add command to init.d
chmod +x kafka/kafka-server.sh
ln -s /root/kafka/kafka-server.sh /etc/init.d/kafka-server
update-rc.d kafka-server defaults

#add restart command to init.d with lower priority
chmod +x kafka/kafka-restart.sh
ln -s /root/kafka/kafka-restart.sh /etc/init.d/kafka-restart
update-rc.d kafka-restart defaults 91

#creating log dir
mkdir /mnt/kafka-logs/

popd

