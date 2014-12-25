#!/bin/nash

echo "Executing: 's3cmd -c /etc/s3cmd/s3cfg ls' ..."
echo "A list with S3 available buckets should be listed..."
s3cmd -c /etc/s3cmd/s3cfg ls /