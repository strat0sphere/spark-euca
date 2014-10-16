#!/bin/sh

#Create the backup dirs
mkdir -p /mnt/hdfs-backup
chown -R hdfs:hadoop /mnt/hdfs-backup



#Get the file from S3
s3cmd -c /root/s3cmd/s3cfg get --recursive --disable-multipart s3://$CLUSTER_NAME/hdfs-backup/ /mnt/hdfs-backup/

hadoop fs -put /mnt/hdfs-backup/* /

#  --delete-after-fetch  Delete remote objects after fetching to local file
