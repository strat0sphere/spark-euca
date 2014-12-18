#!/bin/bash

pushd root

cd kafka_2.9.2-0.8.1.1
./bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partition 1 --topic test
./bin/kafka-topics.sh --list --zookeeper localhost:2181

popd