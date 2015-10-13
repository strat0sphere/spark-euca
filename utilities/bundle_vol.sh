#!/bin/bash

NAME=$1
DIR="/vol2/bundle_vol/"
BUCKET_NAME="mesos"

echo "Running with parameters: NAME=$NAME, DIR=$DIR, BUCKET_NAME=$BUCKET_NAME"
echo "Creating directory $DIR"
mkdir $DIR
. /root/credentials/eucarc

euca-bundle-vol -u -0 -k /root/credentials/euca2-admin-cd349995-pk.pem -c /root/credentials/euca2-admin-cd349995-cert.pem -p $NAME -d $DIR -e /mnt,/vol1,/vol2,/vol3 --kernel eki-8F5C3A7E --ramdisk eri-4CB339EB -r x86_64

echo "Files extraxted on $DIR"

euca-upload-bundle -b $BUCKET_NAME -m $DIR/$NAME.manifest.xml

euca-register $BUCKET_NAME/$NAME.manifest.xml -n $NAME
