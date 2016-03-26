#!/bin/bash

#apt-get install software-properties-common
#add-apt-repository --yes ppa:george-edison55/cmake-3.x
#apt-get --yes --force-yes update
#apt-get install cmake

#wget http://www.cmake.org/files/v3.5/cmake-3.5.0.tar.gz
#tar xfvz cmake-3.5.0.tar.gz
#cd cmake-3.5.0
#./configure
#make
#make install

apt-get remove cmake cmake-data
./bootstrap --prefix=/usr
make
make install


