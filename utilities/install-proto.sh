#!/bin/bash

git clone https://github.com/google/protobuf.git
apt-get --yes --force-yes install autoconf automake libtool curl
cd protobuf
./autogen.sh
./configure --prefix=/usr
make
make check
make install
ldconfig

#Install protobuf for python

apt-get --yes --force-yes install python-protobuf
