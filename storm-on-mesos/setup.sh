#!/bin/bash

pushd /root

cd storm-mesos-git/

bin/build-release.sh downloadStormRelease
STORM_RELEASE=`grep -1 -A 0 -B 0 '<version>' pom.xml | head -n 1 | awk '{print $1}' | sed -e 's/.*<version>//' | sed -e 's/<\/version>.*//'`
bin/build-release.sh apache-storm-${RELEASE}.zip
hadoop fs -put storm-mesos-${RELEASE}.tgz /
cp storm-mesos-${STORM_RELEASE}.tgz /root/
cd storm-mesos-${STORM_RELEASE}

#copy configuration template
cp /etc/storm-mesos/storm.yaml ./conf
cp /etc/storm-mesos/logback ./logback

#nohup bin/storm-mesos nimbus  > nimbus.out &
#nohup bin/storm-mesos ui  > ui.out &

#Adding soft links to automatically start services on reboot
ln -s /root/storm-on-mesos/start-nimbus.sh storm-nimbus-start
update-rc.d storm-nimbus-start defaults

ln -s /root/storm-on-mesos/start-storm-ui.sh storm-ui-start
update-rc.d storm-ui-start defaults

popd