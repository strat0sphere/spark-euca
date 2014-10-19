#!/bin/bash

pushd /root

if [[ "$RESTORE" == "False" ]]; then
    echo "Creating bucket S3://$CLUSTER_NAME ..."
    s3cmd -c /etc/s3cmd/s3cfg mb s3://$CLUSTER_NAME #create the bucket
    echo "Done!"
fi

popd