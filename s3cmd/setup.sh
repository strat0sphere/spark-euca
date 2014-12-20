#!/bin/bash

pushd /root

cd s3cmd
apt-get install python-dateutil
python setup.py install

popd