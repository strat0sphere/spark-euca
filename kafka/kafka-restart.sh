#!/bin/bash

#To avoid bug of Kafka on boot we first stop kafka and then start
service kafka-server stop
sleep 10
service kafka-server start
