#!/bin/bash

pushd /root

wget http://downloads.mesosphere.io/storm/storm-starter-0.0.1-SNAPSHOT.jar
cd storm-mesos-${STORM_RELEASE}
./bin/storm jar ../storm-starter-0.0.1-SNAPSHOT.jar storm.starter.WordCountTopology WordCount
sleep 30.0
#Print sth to prove its working
./bin/storm kill WordCount

popd