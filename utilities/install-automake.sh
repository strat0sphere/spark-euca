#!/bin/bash
cd /mnt
wget http://ftp.gnu.org/gnu/automake/automake-1.15.tar.gz
tar -xvzf automake-1.15.tar.gz
cd /mnt/automake-1.15/
./configure
make
make install
rm -rf automake-1.15 automake-1.15.tar.gz
