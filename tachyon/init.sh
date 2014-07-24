#!/bin/bash

pushd /root

if [ -d "tachyon" ]; then
  echo "Tachyon seems to be installed. Exiting."
  return 0
fi

TACHYON_VERSION=0.4.1

# Github tag:
if [[ "$TACHYON_VERSION" == *\|* ]]
then
  # Not yet supported
  echo ""
# Pre-package tachyon version
else
  case "$TACHYON_VERSION" in
    0.3.0)
      wget http://php.cs.ucsb.edu/spark-related-packages/tachyon-0.3.0-bin.tar.gz
      ;;
    0.4.0)
      wget http://php.cs.ucsb.edu/spark-related-packages/tachyon-0.4.0-bin.tar.gz
      ;;
    0.4.1)
	wget http://php.cs.ucsb.edu/spark-related-packages/tachyon-0.4.1-bin.tar.gz
	#wget https://s3.amazonaws.com/Tachyon/tachyon-0.4.1-bin.tar.gz
      	#wget --output-document="tachyon-0.4.1-bin.tar.gz" https://github.com/amplab/tachyon/archive/v0.4.1.tar.gz
      ;;
    0.5.0)
	#file already in directory
      ;;
    *)
      echo "ERROR: Unknown Tachyon version"
      return -1
  esac

  echo "Unpacking Tachyon"
  tar xvzf tachyon-*.tar.gz > /tmp/spark-euca_tachyon.log
  rm tachyon-*.tar.gz
  mv `ls -d tachyon-*` tachyon
fi

popd
