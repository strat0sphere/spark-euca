#!/bin/bash

#Create the backup dirs
mkdir -p /mnt/hdfs-backup
chown -R hdfs:hadoop /mnt/hdfs-backup


echo "Geting files from S3..."
#Get the file from S3
s3cmd -c /etc/s3cmd/s3cfg get --recursive --disable-multipart s3://$CLUSTER_NAME/hdfs-backup/ /mnt/hdfs-backup/

echo "Putting files on HDFS..."
sudo -u hdfs hadoop fs -put /mnt/hdfs-backup/* /

rm -rf /mnt/hdfs-backup #delete previous backups
mkdir -p /mnt/hdfs-backup
chown -R hdfs:hadoop /mnt/hdfs-backup

#  --delete-after-fetch  Delete remote objects after fetching to local file
