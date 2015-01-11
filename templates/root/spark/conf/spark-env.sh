#!/usr/bin/env bash

# This file is sourced when running various Spark programs.
# Copy it as spark-env.sh and edit that to configure Spark for your site.

export MESOS_NATIVE_LIBRARY=/root/mesos-installation/lib/libmesos.so
export SPARK_EXECUTOR_URI=hdfs://{{cluster_name}}/spark-1.1.0-bin-2.3.0.tgz
export HADOOP_CONF_DIR=/etc/hadoop/conf.mesos-cluster/

export HADOOP_HOME=/usr/lib/hadoop

#Addressing worning for hadoop native library issue - None of the bellow work!
#export SPARK_DAEMON_JAVA_OPTS=-Djava.library.path=$HADOOP_HOME/lib/native/
#export SPARK_WORKER_OPTS=-Djava.library.path=$HADOOP_HOME/lib/native/
#export JAVA_LIBRARY_PATH=$HADOOP_HOME/lib/native/:$JAVA_LIBRARY_PATH
#export SPARK_EXECUTOR_OPTS=-Djava.library.path=$HADOOP_HOME/lib/native/
