#!/usr/bin/env bash

#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# These variables are automatically filled in by the spark-euca script and most of them exist only for the current session. If it is needed to be permanent env variables consider adding to /etc/environment
export MASTERS="{{master_list}}"
export SLAVES="{{slave_list}}"
export ZOOS="{{zoo_list}}"
export MASTERS_PRIVATE_IP="{{master_list_private_ip}}"
export SLAVES_PRIVATE_IP="{{slave_list_private_ip}}"
export ZOOS_PRIVATE_IP="{{zoo_list_private_ip}}"
export ZOOS_PRIVATE_DNS_NAME="{{zoo_list_private_dns_name}}"
export CLUSTER_URL="{{cluster_url}}"
echo "CLUSTER_URL=$CLUSTER_URL" >> /etc/environment
export CLUSTER_URL_PRIVATE_IP="{{cluster_url_private_ip}}"
echo "CLUSTER_URL_PRIVATE_IP=$CLUSTER_URL_PRIVATE_IP" >> /etc/environment
export ZOO_STRING="{{zoo_string}}"
export ZOO_STRING_PRIVATE_IP="{{zoo_string_private_ip}}"
export ZOO_STRING_PRIVATE_IP_NO_PORT="{{zoo_string_private_ip_no_port}}"
export NAMENODE="{{namenode}}"
export NAMENODE_PRV_IP="{{namenode_prv_ip}}"
export STANDBY_NAMENODE="{{standby_namenode}}"
export STANDBY_NAMENODE_PRV_IP="{{standby_namenode_prv_ip}}"
export JOURNAL_URL="{{journal_url}}"
export JOURNAL_URL_PRV="{{journal_url_prv}}"
export NODES_NUMBER="{{nodes_number}}" #total number of master and slave nodes - used for mpdboot command
export HDFS_DATA_DIRS="{{hdfs_data_dirs}}"
export MAPRED_LOCAL_DIRS="{{mapred_local_dirs}}"
export MODULES="{{modules}}"
export MESOS_SETUP_VERSION="{{mesos_setup_version}}"
export SWAP_MB="{{swap}}"
export CLUSTER_NAME="{{cluster_name}}"
sed -i '/CLUSTER_NAME=/d' /etc/environment #delete previous value if it is a restore session
echo "CLUSTER_NAME=$CLUSTER_NAME" >> /etc/environment #Need this to startup mesos scripts on reboot
export ACTIVE_MASTER="{{active_master}}"
export ACTIVE_MASTER_PRIVATE="{{active_master_private}}"
sed -i '/ACTIVE_MASTER_PRIVATE=/d' /etc/environment
echo "ACTIVE_MASTER_PRIVATE=$ACTIVE_MASTER_PRIVATE" >> /etc/environment #Need this to startup mesos scripts on reboot

echo "Seding previous LD_LIBRARY_PATH value..."
sed -i '/LD_LIBRARY_PATH=/d' /etc/environment
echo 'LD_LIBRARY_PATH=/root/mesos-installation/lib/' >> /etc/environment

export MASTERS_DNS_MAPPINGS="{{masters_dns_mappings}}"
export MASTERS_DNS_MAPPINGS_PUBLIC="{{masters_dns_mappings_public}}"
export SLAVES_DNS_MAPPINGS="{{slaves_dns_mappings}}"
export SLAVES_DNS_MAPPINGS_PUBLIC="{{slaves_dns_mappings_public}}"
export ZOO_DNS_MAPPINGS="{{zoo_dns_mappings}}"
export ZOO_DNS_MAPPINGS_PUBLIC="{{zoo_dns_mappings_public}}"


#Backup specific variables
export AWS_ACCESS_KEY="{{aws_access_key}}"
export AWS_SECRET_KEY="{{aws_secret_key}}"
export WALRUS_IP="{{walrus_ip}}"

#MPI on Mesos specific variables
#TODO: Its OK to be hardcoded for the emi version but for building from scratch they have to be configurable
export MESOS_SOURCE_DIR="/root/mesos-0.21.1" #"{{mesos_source_dir}}"
export MESOS_BUILD_DIR="/root/mesos-0.21.1/build" #"{{mesos_build_dir}}"
export PYTHON_PATH="/usr/bin/python" #"{{python_path}}" - (which python)
export PYTHON_EGG_POSTFIX="py2.7-linux-x86_64" #"{{python_egg_postfix}}"
export PYTHON_EGG_PUREPY_POSTFIX="py2.7" #"{{python_egg_purepy_postfix}}"
export STORM_RELEASE="0.9.2-incubating"
echo STORM_RELEASE=$STORM_RELEASE >> /etc/environment
export KAFKA_VERSION="0.8.1.1"
echo KAFKA_VERSION=$KAFKA_VERSION >> /etc/environment
export KAFKA_SCALA_BINARY="2.9.2-$KAFKA_VERSION"
echo KAFKA_SCALA_BINARY=$KAFKA_SCALA_BINARY >> /etc/environment
echo "HADOOP_MAPRED_HOME=/usr/lib/hadoop-0.20-mapreduce/" >> /etc/environment
echo "HADOOP_HOME=/usr/lib/hadoop-0.20-mapreduce/" >> /etc/environment
echo "HADOOP_LIBEXEC_DIR=/usr/lib/hadoop/libexec/" >> /etc/environment
echo "HADOOP_MAPRED_HOME=/usr/lib/hadoop-0.20-mapreduce" >> /etc/environment
echo "MESOS_NATIVE_LIBRARY=/root/mesos-installation/lib/libmesos.so" >> /etc/environment

export DEBIAN_FRONTEND="noninteractive"


