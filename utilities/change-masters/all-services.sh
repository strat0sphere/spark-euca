#!/bin/bash

service zookeeper-server $1
service hadoop-hdfs-namenode $1
service hadoop-hdfs-zkfc $1
service hadoop-0.20-mapreduce-zkfc $1
service hadoop-0.20-mapreduce-jobtrackerha $1
service hadoop-hdfs-journalnode $1
