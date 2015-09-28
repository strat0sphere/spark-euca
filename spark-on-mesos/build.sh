#!/bin/bash

wget http://d3kbcqa49mib13.cloudfront.net/spark-1.2.1.tgz
tar zxfv spark-1.2.1.tgz
cd spark-1.2.1

./make-distribution.sh --tgz -Dhadoop.version=2.3.0-mr1-cdh5.1.2

tar czfv spark-1.2.1-bin-2.3.0-mr1-cdh5.1.2.tgz spark-1.2.1
mv spark-1.2.1-bin-2.3.0-mr1-cdh5.1.2.tgz /executor_tars/
mv spark-1.2.1 spark
