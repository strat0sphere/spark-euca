#!/bin/bash

if [[ "$RESTORE" == "True" ]]; then
    /root/spark-euca/backup/restore-from-s3.sh #run restore script
fi
