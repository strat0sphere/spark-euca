#!/bin/bash

pushd /root

if [ "$RESTORE" == "False"]; then
    s3cmd -c /etc/s3cmd/s3cfg mb s3://$CLUSTER_NAME #create the bucket
fi

popd