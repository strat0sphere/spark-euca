#!/bin/bash

pushd /root
tar -xzf kafka_2.9.2-0.8.1.1.tgz
cd kafka_2.9.2-0.8.1.1
#bin/kafka-server-start.sh config/server.properties

#add command to init.d
chmod +x /etc/kafka/start-kafka.sh
ln -s /etc/kafka/start-kafka.sh /etc/init.d/kafka-start
update-rc.d kafka-start defaults

popd

