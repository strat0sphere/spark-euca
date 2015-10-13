#!/bin/bash

pushd /root

echo "Setting up Kafka..."

tar -xzf kafka_${KAFKA_SCALA_BINARY}.tgz
rm kafka_${KAFKA_SCALA_BINARY}.tgz
mv kafka_${KAFKA_SCALA_BINARY} kafka
cd kafka

#Add zookeepers in server.properties in the expected format
ZOOS_PRIVATE=`cat /root/spark-euca/zoos_private`

zookeeper_connect='zookeeper.connect='
zoo_string=""
zoo_num=0
for zoo in $ZOOS_PRIVATE; do
#echo $zoo
if [ $zoo_num != 0 ] ; then
zoo_string="$zoo_string,$zoo:2181"
else
zoo_string="$zoo:2181"
fi
zoo_num=$(($zoo_num+1))
done

echo "$zookeeper_connect$zoo_string" >> /etc/kafka/config/server.properties

cp /etc/kafka/config/server.properties ./config/

#add command to init.d
cp /root/spark-euca/kafka/kafka-server.sh ./bin

chmod +x bin/kafka-server.sh
ln -s /root/kafka/bin/kafka-server.sh /etc/init.d/kafka-server
update-rc.d kafka-server defaults

#creating log dir
mkdir /mnt/kafka-logs/

popd

