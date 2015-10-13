#!/bin/bash

NODE_TYPE=$1

echo "Copying custom monitrc for $NODE_TYPE to default..."
mv /etc/monit/monitrc.custom.$NODE_TYPE /etc/monit/monitrc
chmod 600 /etc/monit/monitrc
echo "Checking control file /etc/monitrc for errors..."
monit -t
mkdir /mnt/monit