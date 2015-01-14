#!/bin/bash

nohup /root/storm-mesos-{{storm_release}}/bin/storm-mesos nimbus > /mnt/storm-logs/nimbus.out 2>&1 &
