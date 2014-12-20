#!/bin/bash

pushd /root
tar -xzf kafka_${KAFKA_SCALA_BINARY}.tgz
rm kafka_${KAFKA_SCALA_BINARY}.tgz
cd kafka_${KAFKA_SCALA_BINARY}

cp /etc/kafka/config/server.properties ./config/
cp /etc/kafka/start-kafka.sh ./bin/

#add command to init.d
chmod +x ./bin/start-kafka.sh
ln -s /root/kafka_${KAFKA_SCALA_BINARY}/bin/start-kafka.sh /etc/init.d/kafka-start
update-rc.d kafka-start defaults

popd

