#bin/bash

pushd /root


if [ -d "hama" ]; then
echo "hama seems to be installed. Exiting."
return
fi

#wget http://www.interior-dsgn.com/apache/hama/hama-0.6.4/hama-0.6.4-src.tar.gz
#tar xvfz hama-0.6.4-src.tar.gz
#rm hama-0.6.4-src.tar.gz
#mv hama-0.6.4 hama


git clone https://github.com/jfenc91/hama.git

echo "Removing previous hama executors from HDFS..."

hadoop fs -rm /hama.tar.gz
hadoop fs -put dist/target/hama-0.7.0-SNAPSHOT.tar.gz /hama.tar.gz


popd