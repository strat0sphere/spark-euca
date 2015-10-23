#!/bin/bash

VOL='vol1'
cd /root/

#echo "Copying Mahout distribution to root dir..."
#cp /$VOL/BigDataBenchGenerator/BigDataBench_V3.1_Hadoop_Hive-cluster/E-commerce/mahout-distribution-0.6.tar.gz /test-code/
#echo "Decompressing mahout..."
#tar -xvf /test-code/mahout-distribution-0.6.tar.gz
#rm /test-code/mahout-distribution-0.6.tar.gz

#echo "Copying test-code dir..."
#cp -r /$VOL/test-code /root

#echo "Copy spark model..."
for i in 1 5 15
do
hadoop fs -mkdir /Bayes-$i/spark-model
hadoop fs -put /$VOL/BigDataBenchGenerator/BigDataBench_V3.1.1_Spark/E-commerce/Bayes/data-naivebayes/model/* /Bayes-$i/spark-model/
done


