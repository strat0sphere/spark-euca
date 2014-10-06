#!/usr/bin/env bash

# This file is sourced when running various Spark programs.
# Copy it as spark-env.sh and edit that to configure Spark for your site.

export MESOS_NATIVE_LIBRARY=/root/mesos-installation/lib/libmesos.so
export SPARK_EXECUTOR_URI=hdfs://{{active_master_private}}:9000/spar
