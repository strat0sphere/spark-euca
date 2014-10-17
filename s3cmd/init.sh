#!/bin/sh

pushd /root

if [ -d "s3cmd" ]; then
echo "c3cmd seems to be installed. Exiting."
return
fi

git clone https://github.com/s3tools/s3cmd.git

popd
