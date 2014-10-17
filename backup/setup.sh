#!/bin/bassh

pushd /root

if [[ "$RESTORE" == "True"]; then
restore-from-s3.sh #run restore script
fi

popd