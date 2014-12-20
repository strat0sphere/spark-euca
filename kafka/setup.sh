#!/bin/bash

pushd /root
tar -xzf kafka_2.9.2-0.8.1.1.tgz
rm kafka_2.9.2-0.8.1.1.tgz
cd kafka_2.9.2-0.8.1.1

cp /etc/kafka/config/server.properties ./config/
cp /etc/kafka/start-kafka.sh ./bin/

#add command to init.d
chmod +x ./bin/start-kafka.sh
ln -s /root/kafka_2.9.2-0.8.1.1/bin/start-kafka.sh /etc/init.d/kafka-start
update-rc.d kafka-start defaults

popd

