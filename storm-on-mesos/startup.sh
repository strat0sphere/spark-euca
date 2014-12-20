#!/bin/bash

nohup /root/storm-mesos-${STORM_RELEASE}/bin/storm-mesos nimbus &
nohup /root/storm-mesos-${STORM_RELEASE}/bin/storm-mesos ui &
