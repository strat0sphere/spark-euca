#!/bin/bash
pushd /root
tar -xzf kafka_2.9.2-0.8.1.1.tgz
cd kafka_2.9.2-0.8.1.1
#bin/kafka-server-start.sh config/server.properties

ln -s /root/kafka-on-mesos/kafka-server-start.sh kafka-start
update-rc.d kafka-start defaults

popd

