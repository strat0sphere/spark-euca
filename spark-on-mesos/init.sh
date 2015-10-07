#!/bin/bash
#TODO: Install s3cmd if not included in modules because it is a dependecy for this script to work
pushd /root

echo "Copying configuration from spark-config to spark"
cp -r /root/spark-config/* /root/spark/

echo "Deleting spark-config"
rm -rf /root/spark-config

#delete to save some space if necessary
rm /executor_tars/spark-1.2.1-bin-2.3.0-mr1-cdh5.1.2.tgz

popd