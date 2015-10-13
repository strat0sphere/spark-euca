#!/bin/bash

pushd /root

#wget http://downloads.mesosphere.io/storm/storm-starter-0.0.1-SNAPSHOT.jar
cd storm-mesos-${STORM_RELEASE}
/root/storm-mesos-0.9.2-incubating/bin/storm jar /root/storm-mesos-0.9.2-incubating/examples/storm-starter/storm-starter-topologies-0.9.2-incubating.jar storm.starter.WordCountTopology WordCount
#./bin/storm jar ../storm-starter-0.0.1-SNAPSHOT.jar storm.starter.WordCountTopology WordCount
sleep 30.0
#Print sth to prove its working
tail /mnt/storm-logs/nimbus.log
/root/storm-mesos-0.9.2-incubating/bin/storm kill WordCount

popd