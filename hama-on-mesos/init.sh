#bin/bash

pushd /root
wget http://www.interior-dsgn.com/apache/hama/hama-0.6.4/hama-0.6.4-src.tar.gz
tar xvfz hama-0.6.4-src.tar.gz
rm hama-0.6.4-src.tar.gz
mv hama-0.6.4 hama

popd /root