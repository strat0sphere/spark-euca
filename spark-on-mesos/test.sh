#bin/bash

pushd /root

echo "I love UCSB" > /tmp/file0
chown hdfs:hadoop /tmp/file0

hadoop fs -mkdir -p /user/foo/data
hadoop fs -put /tmp/file0 /user/foo/data


echo "Getting sample test code from server..."
rm /root/test-code/simple-project_2.10-1.0.jar
s3cmd -c /etc/s3cmd/s3cfg get --recursive --disable-multipart s3://mesos-repo/test-code/simple-project-assembly_2.10-1.0.jar /root/test-code

#With HA CLUSTER_NAME is the name of the naming-service
echo "Executing /root/spark/bin/spark-submit --class WordCount3 --master mesos://$CLUSTER_URL_PRIVATE_IP ~/test-code/simple-project_2.10-1.0.jar hdfs://$CLUSTER_NAME"
/root/spark/bin/spark-submit --class WordCount3 --master mesos://$CLUSTER_URL_PRIVATE_IP ~/test-code/simple-project-assembly_2.10-1.0.jar hdfs://$CLUSTER_NAME

#Requires Kafka to be already installed
#echo "Testing spark streaming with Kafka..."

#echo "Starting producer..."
#echo "Executing /root/spark/bin/spark-submit --class testingsparkwithscala.KafkaWoCountProducer --master mesos://$CLUSTER_URL_PRIVATE_IP ~/test-code/simple-project-assembly_2.10-1.0.jar $ACTIVE_MASTER_PRIVATE:9092 test-sentence 2 10"

#nohup /root/spark/bin/spark-submit --class testingsparkwithscala.KafkaWordCountProducer --master mesos://$CLUSTER_URL_PRIVATE_IP ~/test-code/simple-project-assembly_2.10-1.0.jar $ACTIVE_MASTER_PRIVATE:9092 test-sentence 2 10 &


#echo "Starting consumer..."
#echo "Executing /root/spark/bin/spark-submit --class testingsparkwithscala.KafkaWordCount --master mesos://$CLUSTER_URL_PRIVATE_IP ~/test-code/simple-project-assembly_2.10-1.0.jar $ACTIVE_MASTER_PRIVATE spark-group test-sentence 1"

#/root/spark/bin/spark-submit --class testingsparkwithscala.KafkaWordCount --master mesos://$CLUSTER_URL_PRIVATE_IP ~/test-code/simple-project-assembly_2.10-1.0.jar $ACTIVE_MASTER_PRIVATE spark-group test-sentence 1

popd