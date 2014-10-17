#!/bin/bash

pushd /root

git clone https://github.com/eucalyptus/s3cmd
cd s3cmd
apt-get install python-dateutil
python setup.py install
cd ..

popd
