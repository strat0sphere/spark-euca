#!/bin/bash

pushd /root
tar -xzf kafka_${KAFKA_SCALA_BINARY}.tgz
rm kafka_${KAFKA_SCALA_BINARY}.tgz
cd kafka_${KAFKA_SCALA_BINARY}

cp /etc/kafka/config/server.properties ./config/

#add command to init.d
chmod +x /etc/kafka/start-kafka.sh
ln -s /etc/kafka/start-kafka.sh /etc/init.d/kafka-start
update-rc.d kafka-start defaults

#creating log dir
mkdir /mnt/kafka-logs/

popd

