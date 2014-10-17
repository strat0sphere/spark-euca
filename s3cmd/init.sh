#!/bin/bash

pushd /root

if [ -d "/etc/s3cmd" ]; then
echo "c3cmd seems to be installed. Exiting."
return
fi

git clone https://github.com/eucalyptus/s3cmd
cd s3cmd
apt-get install python-dateutil
python setup.py install
cd ..

popd
