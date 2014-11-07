#!bin/bash

echo "Backup dry run: 's3cmd -c /etc/s3cmd/s3cfg  --dry-run --disable-multipart --delete-removed --delete-after --skip-existing sync /mnt/hdfs-backup s3://$CLUSTER_NAME/'"

s3cmd -c /etc/s3cmd/s3cfg --dry-run --disable-multipart --delete-removed --delete-after --skip-existing sync /mnt/hdfs-backup s3://$CLUSTER_NAME/