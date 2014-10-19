#!/bin/bash

if [[ "$RESTORE" == "True" ]]; then
./restore-from-s3.sh #run restore script
fi
