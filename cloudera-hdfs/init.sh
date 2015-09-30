#!/bin/bash

update-alternatives --yes --force-yes --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.mesos-cluster 50
update-alternatives --yes --force-yes --set hadoop-conf /etc/hadoop/conf.mesos-cluster

wget http://archive.cloudera.com/cdh5/one-click-install/precise/amd64/cdh5-repository_1.0_all.deb
dpkg -i cdh5-repository_1.0_all.deb