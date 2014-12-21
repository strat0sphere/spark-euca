#!/bin/bash

/root/kafka_{{kafka_scala_binary}}/bin/kafka-server-start.sh /root/kafka_{{kafka_scala_binary}}/config/server.properties > /mnt/kafka-logs/kafka.out 2>&1 &