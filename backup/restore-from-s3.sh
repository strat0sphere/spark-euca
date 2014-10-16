#!/bin/sh

#Create the backup dirs
mkdir -P /mnt/hdfs-backup
chown -R hdfs:hadoop /mnt/hdfs-backup



#Get the file from S3
s3cmd -c /etc/s3cmd/s3cfg get --recursive s3://$CLUSTER_NAME/hdfs-backup/

hadoop fs -put /mnt/hdfs-backup/* /

#  --delete-after-fetch  Delete remote objects after fetching to local file
