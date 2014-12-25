#!/bin/bash

nohup /root/storm-mesos-{{storm_release}}/bin/storm ui > /mnt/storm-logs/ui.out 2>&1 &