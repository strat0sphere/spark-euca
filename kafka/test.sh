#!/bin/bash

pushd /root

cd kafka_${KAFKA_SCALA_BINARY}
echo "Creating Kafka topic..."
echo "Executing ./bin/kafka-topics.sh --create --zookeeper $ACTIVE_MASTER_PRIVATE:2181 --replication-factor 1 --partition 1 --topic test"
./bin/kafka-topics.sh --create --zookeeper $ACTIVE_MASTER_PRIVATE:2181 --replication-factor 1 --partition 1 --topic test

echo "Executing ./bin/kafka-topics.sh --list --zookeeper $ACTIVE_MASTER_PRIVATE:2181"
./bin/kafka-topics.sh --list --zookeeper $ACTIVE_MASTER_PRIVATE:2181

popd