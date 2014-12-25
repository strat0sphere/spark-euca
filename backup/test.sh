#!bin/bash

echo "Putting file on backup folder"
mkdir -p /mnt/hdfs-backup
touch /mnt/hdfs-backup/test.txt

echo "Backup dry run: 's3cmd -c /etc/s3cmd/s3cfg  --dry-run --disable-multipart --delete-removed --delete-after --skip-existing sync /mnt/hdfs-backup s3://$CLUSTER_NAME/'"

s3cmd -c /etc/s3cmd/s3cfg --dry-run --disable-multipart --delete-removed --delete-after --skip-existing sync /mnt/hdfs-backup s3://$CLUSTER_NAME/

echo "Cleaning up..."
rm -rf /mnt/hdfs-backup