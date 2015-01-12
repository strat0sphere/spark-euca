#!/bin/bash

pushd /root

echo "Setting up Storm on Mesos..."
cd storm-mesos-git/

bin/build-release.sh downloadStormRelease
STORM_RELEASE=`grep -1 -A 0 -B 0 '<version>' pom.xml | head -n 1 | awk '{print $1}' | sed -e 's/.*<version>//' | sed -e 's/<\/version>.*//'`

bin/build-release.sh apache-storm-${STORM_RELEASE}.zip
hadoop fs -put storm-mesos-${STORM_RELEASE}.tgz /
cp storm-mesos-${STORM_RELEASE}.tgz /root/
cd /root
tar xzf storm-mesos-${STORM_RELEASE}.tgz
rm storm-mesos-${STORM_RELEASE}.tgz
cd /root/storm-mesos-${STORM_RELEASE}


#Add zookeepers in storm.yaml in the expected format
ZOOS_PRIVATE=`cat /root/spark-euca/zoos_private`

echo ''  >> /etc/storm/storm.yaml
echo 'storm.zookeeper.servers:' >> /etc/storm/storm.yaml

for zoo in $ZOOS_PRIVATE; do
echo $zoo
echo '- "'$zoo'"' >> /etc/storm/storm.yaml
done

#copy configuration template
echo "Copying configurations..."
cp /etc/storm/storm.yaml ./conf
cp /etc/storm/logback/cluster.xml ./logback


#Adding soft links to automatically start services on reboot
chmod +x /etc/storm/start-nimbus.sh
ln -s /etc/storm/start-nimbus.sh /etc/init.d/storm-nimbus-start
update-rc.d storm-nimbus-start defaults

chmod +x /etc/storm/start-storm-ui.sh
ln -s /etc/storm/start-storm-ui.sh /etc/init.d/storm-ui-start
update-rc.d storm-ui-start defaults

#Create dir for logs
mkdir /mnt/storm-logs
mkdir /mnt/storm-local

#Avoid Failed to load native Mesos library from /usr/local/lib:/opt/local/lib:/usr/lib when calling from unix service command
cp /root/mesos-installation/lib/libmesos.so /usr/local/lib/


popd