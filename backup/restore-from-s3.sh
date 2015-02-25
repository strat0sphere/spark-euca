#!/bin/bash

#Create the backup dirs
mkdir -p /mnt/hdfs-backup
chown -R hdfs:hadoop /mnt/hdfs-backup

date >> /mnt/hdfs-backup-logs/restore.log
echo "Geting files from S3 bucket $CLUSTER_NAME/..." | tee -a /mnt/hdfs-backup-logs/restore.log 1>&2
#Get the file from S3
s3cmd -c /etc/s3cmd/s3cfg get --recursive --disable-multipart s3://$CLUSTER_NAME/hdfs-backup/ /mnt/hdfs-backup/ 2>> /mnt/hdfs-backup-logs/restore.log

tail /mnt/hdfs-backup-logs/restore.log
echo "Done!"

echo "Putting files on HDFS..." | tee -a /mnt/hdfs-backup-logs/restore.log 1>&2
sudo -u hdfs hadoop fs -put /mnt/hdfs-backup/* /
echo "Done!" | tee -a /mnt/hdfs-backup-logs/restore.log 1>&2

rm -rf /mnt/hdfs-backup #delete previous backups
mkdir -p /mnt/hdfs-backup
chown -R hdfs:hadoop /mnt/hdfs-backup

#  --delete-after-fetch  Delete remote objects after fetching to local file
