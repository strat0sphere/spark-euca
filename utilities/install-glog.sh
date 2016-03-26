#!/bin/bash

git clone https://github.com/google/glog
cd glog
./install_cmake.sh

#Fix to avoid error as described here: https://github.com/google/glog/issues/52
mkdir build && cd build
export CXXFLAGS="-fPIC" && cmake .. && make VERBOSE=1

./configure --prefix=/usr
make
make check
make install
