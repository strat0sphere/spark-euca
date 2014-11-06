#bin/bash

pushd /root

echo "I love UCSB" > /tmp/file0
chown hdfs:hadoop /tmp/file0

hadoop fs -mkdir -p /user/foo/data
hadoop fs -put /tmp/file0 /user/foo/data


echo "Getting sample test code from server..."
rm /root/test-code/simple-project_2.10-1.0.jar
wget -P /root/test-code http://php.cs.ucsb.edu/spark-related-packages/test-code/simple-project_2.10-1.0.jar

echo "Executing /root/spark/bin/spark-submit --class WordCount3 --master mesos://zk://$ACTIVE_MASTER_PRIVATE:2181/mesos ~/test-code/simple-project_2.10-1.0.jar $ACTIVE_MASTER_PRIVATE"
/root/spark/bin/spark-submit --class WordCount3 --master mesos://zk://$ACTIVE_MASTER_PRIVATE:2181/mesos ~/test-code/simple-project_2.10-1.0.jar $ACTIVE_MASTER_PRIVATE

popd