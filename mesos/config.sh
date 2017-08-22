#!/bin/bash

echo "Copy mesos-config"
cp /root/mesos-config/* /root/mesos-installation/

echo "Removing mesos-config directory..."
rm -rf /root/mesos-config