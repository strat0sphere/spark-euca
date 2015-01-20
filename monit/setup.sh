#!/bin/bash


echo "Copying custom monitrc to default..."
mv /etc/monit/monitrc.custom /etc/monit/monitrc
echo "Checking control file /etc/monitrc for errors..."
monit -t
mkdir /mnt/monit