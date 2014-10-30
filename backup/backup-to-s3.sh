#!/bin/bash

rm -rf /mnt/hdfs-backup #delete previous backups
mkdir -p /mnt/hdfs-backup
mkdir -p /mnt/hdfs-backup-logs
chown -R hdfs:hadoop /mnt/hdfs-backup

echo "Copying files from HDFS..." >> /mnt/hdfs-backup-logs/backup.log

hadoop fs -get / /mnt/hdfs-backup/ #copy everything from HDFS to local dirs

echo "Rsyncing files to S3..." >> /mnt/hdfs-backup-logs/backup.log
#Rsyncing the file. For more options check here: http://s3tools.org/usage
s3cmd -c /etc/s3cmd/s3cfg --disable-multipart --delete-removed --delete-after --skip-existing sync /mnt/hdfs-backup s3://$CLUSTER_NAME/#will skip files that already exist on the destination but will first check the md5 checksums

echo "backup completed" >> /mnt/hdfs-backup-logs/backup.log
### Alternative ways to backup ###

#Faster but more prune to error
#s3cmd -c /etc/s3cmd/s3cfg --disable-multipart --delete-removed --no-check-md5 --dry-run sync /mnt/hdfs-backup s3://$CLUSTER_NAME/ #Will not upload a file with the same name and size -- might lose some changes

#Putting the file
#s3cmd -c /etc/s3cmd/s3cfg --disable-multipart --recursive put /mnt/hdfs-backup/ s3://$CLUSTER_NAME/hdfs-backup/

#With the following you have to allow big chunk size - otherwise use with --disable-multipart option
#s3cmd -c /etc/s3cmd/s3cfg  --recursive put /mnt/hdfs-backup s3://$CLUSTER_NAME/hdfs-backup/




