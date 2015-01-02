#!/bin/bash

pushd /root

cd kafka
echo "Creating Kafka topic..."
echo "Executing ./bin/kafka-topics.sh --create --zookeeper $ACTIVE_MASTER_PRIVATE:2181 --replication-factor 1 --partition 1 --topic test"
./bin/kafka-topics.sh --create --zookeeper $ACTIVE_MASTER_PRIVATE:2181 --replication-factor 1 --partition 1 --topic test

echo "Executing ./bin/kafka-topics.sh --list --zookeeper $ACTIVE_MASTER_PRIVATE:2181"
./bin/kafka-topics.sh --list --zookeeper $ACTIVE_MASTER_PRIVATE:2181


cd /root

#Storm tests with Kafka
git clone https://github.com/strat0sphere/storm-kafka-0.8-plus-test.git
cd storm-kafka-0.8-plus-test
mvn clean package -P cluster

#Submit Storm topology
/root/storm-mesos-0.9.2-incubating/bin/storm jar /root/storm-kafka-0.8-plus-test/target/storm-kafka-0.8-plus-test-0.2.0-SNAPSHOT-jar-with-dependencies.jar storm.kafka.KafkaSpoutTestTopology $ACTIVE_MASTER_PRIVATE sentences $ACTIVE_MASTER_PRIVATE

#Manual tests-TODO: Automate 
#Run producer
#java -cp /root/storm-kafka-0.8-plus-test/target/storm-kafka-0.8-plus-test-0.2.0-SNAPSHOT-jar-with-dependencies.jar storm.kafka.tools.StormProducer $ACTIVE_MASTER_PRIVATE:9092

#Run consumer
#/root/kafka/bin/kafka-console-consumer.sh --zookeeper $ACTIVE_MASTER_PRIVATE:2181 --from-beginning --topic storm-sentence

#Tesk Spark-Streaming with Kafka

#Run producer
#/root/spark/bin/spark-submit --class testingsparkwithscala.KafkaWordCountProducer --master mesos://$CLUSTER_URL_PRIVATE_IP ~/test-code/simple-project-assembly_2.10-1.0.jar $ACTIVE_MASTER_PRIVATE:9092 test-sentence 2 10

#Run consumer
#/root/spark/bin/spark-submit --class testingsparkwithscala.KafkaWordCount --master mesos://$CLUSTER_URL_PRIVATE_IP ~/test-code/simple-project-assembly_2.10-1.0.jar $ACTIVE_MASTER_PRIVATE spark-group test-sentence 1

popd