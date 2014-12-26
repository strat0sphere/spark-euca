#!/bin/bash


#Actual scripts located at /etc/storm
service storm-nimbus-start
sleep 10
service storm-ui-start
sleep 10
tail /mnt/storm-logs/nimbus.out