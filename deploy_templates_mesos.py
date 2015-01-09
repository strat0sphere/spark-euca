#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import with_statement

import os
import sys

# Deploy the configuration file templates in the spark-euca/templates directory
# to the root filesystem, substituting variables such as the master hostname,
# ZooKeeper URL, etc as read from the environment.

# Find system memory in KB and compute Spark's default limit from that
mem_command = "cat /proc/meminfo | grep MemTotal | awk '{print $2}'"
cpu_command = "nproc"

master_ram_kb = int(
  os.popen(mem_command).read().strip())
# This is the master's memory. Try to find slave's memory as well
first_slave = os.popen("cat /root/spark-euca/slaves | head -1").read().strip()

slave_mem_command = "ssh -t -o StrictHostKeyChecking=no %s %s" %\
        (first_slave, mem_command)

slave_cpu_command = "ssh -t -o StrictHostKeyChecking=no %s %s" %\
        (first_slave, cpu_command)

slave_ram_kb = int(os.popen(slave_mem_command).read().strip())

slave_cpus = int(os.popen(slave_cpu_command).read().strip())

system_ram_kb = min(slave_ram_kb, master_ram_kb)

system_ram_mb = system_ram_kb / 1024
# Leave some RAM for the OS, Hadoop daemons, and system caches
if system_ram_mb > 100*1024:
  spark_mb = system_ram_mb - 15 * 1024 # Leave 15 GB RAM
elif system_ram_mb > 60*1024:
  spark_mb = system_ram_mb - 10 * 1024 # Leave 10 GB RAM
elif system_ram_mb > 40*1024:
  spark_mb = system_ram_mb - 6 * 1024 # Leave 6 GB RAM
elif system_ram_mb > 20*1024:
  spark_mb = system_ram_mb - 3 * 1024 # Leave 3 GB RAM
elif system_ram_mb > 10*1024:
  spark_mb = system_ram_mb - 2 * 1024 # Leave 2 GB RAM
else:
  spark_mb = max(512, system_ram_mb - 1300) # Leave 1.3 GB RAM

# Make tachyon_mb as spark_mb for now.
tachyon_mb = spark_mb

worker_instances = int(os.getenv("SPARK_WORKER_INSTANCES", 1)) #Unecessary for Mesos
# Distribute equally cpu cores among worker instances
worker_cores = max(slave_cpus / worker_instances, 1)

#get local IP address
#/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
#get hostname
#hostname
#get fqdn hostname
#hostname --fqdn


#TODO: some of the following are not needed
#print "masters: " + os.getenv("MASTERS")
#print "master_dns_mapping: " + os.getenv("MASTERS_DNS_MAPPINGS")

def dirNeedsConfig(local_dir, config_dirs):
    for dir in config_dirs:
        if dir in local_dir:
            return True
    return False

template_vars = {
  "master_list": os.getenv("MASTERS"),
  "active_master": os.getenv("MASTERS").split("\n")[0],
  "active_master_private": os.getenv("ACTIVE_MASTER_PRIVATE"),
  "slave_list": os.getenv("SLAVES"),
  "zoo_list": os.getenv("ZOOS"),
  "zoo_list_private_ip": os.getenv("ZOOS_PRIVATE_IP"),
  "namenode": os.getenv("NAMENODE"),
  "standby_namenode": os.getenv("STANDBY_NAMENODE"),
  "journal_url": os.getenv("JOURNAL_URL"),
  "cluster_url": os.getenv("CLUSTER_URL"),
  "cluster_url_private_ip": os.getenv("CLUSTER_URL_PRIVATE_IP"),
  "masters_dns_mappings": os.getenv("MASTERS_DNS_MAPPINGS"),
  "slaves_dns_mappings": os.getenv("SLAVES_DNS_MAPPINGS"),
  "masters_dns_mappings_public": os.getenv("MASTERS_DNS_MAPPINGS_PUBLIC"),
  "slaves_dns_mappings_public": os.getenv("SLAVES_DNS_MAPPINGS_PUBLIC"),
  "zoo_dns_mappings": os.getenv("ZOO_DNS_MAPPINGS"),
  "zoo_dns_mappings_public": os.getenv("ZOO_DNS_MAPPINGS_PUBLIC"),
  "mesos_setup_version": os.getenv("MESOS_SETUP_VERSION"),
  "java_home": os.getenv("JAVA_HOME"),
  "cluster_name": os.getenv("CLUSTER_NAME"),
  "aws_access_key": os.getenv("AWS_ACCESS_KEY"),
  "aws_secret_key": os.getenv("AWS_SECRET_KEY"),
  "walrus_ip": os.getenv("WALRUS_IP"),
  "mesos_source_dir": os.getenv("MESOS_SOURCE_DIR"),
  "mesos_build_dir": os.getenv("MESOS_BUILD_DIR"), 
  "python_path": os.getenv("PYTHON_PATH"),
  "python_egg_postfix": os.getenv("PYTHON_EGG_POSTFIX"),
  "python_egg_purepy_postfix": os.getenv("PYTHON_EGG_PUREPY_POSTFIX"),
  "storm_release": os.getenv("STORM_RELEASE"),
  "kafka_scala_binary": os.getenv("KAFKA_SCALA_BINARY")
}

template_dir="/root/spark-euca/templates"

#config_dirs contains all the directories that might need some configuration. This includes the modules that are installed by 
#the script (which are all located under /root) plus the directories under /etc or any other dirs requiring configuration

#If MPI enabled "mesos-0.20" should be added on the config_dirs
config_dirs = ["etc", "spark", "hadoop", "s3cmd", "backup", "storm", "kafka"]


for path, dirs, files in os.walk(template_dir):
  #print "template_dir" + template_dir  
  
  if path.find(".svn") == -1:
    dest_dir = os.path.join('/', path[len(template_dir):])
    if not os.path.exists(dest_dir):
      if not dirNeedsConfig(dest_dir, config_dirs):
          continue
      else:
       print "Creating: " + dest_dir 
       os.makedirs(dest_dir)
       
    print "DEBUG: Configuring dest_dir " + dest_dir
       
    for filename in files:
      if filename[0] not in '#.~' and filename[-1] != '~':
        dest_file = os.path.join(dest_dir, filename)
        with open(os.path.join(path, filename)) as src:
          with open(dest_file, "w") as dest:
            print "DEBUG: Configuring " + dest_file
            text = src.read()
            for key in template_vars:
              #print "DEBUG: key: " + key
              if (template_vars[key] != None):  
                   #print "Replacing " +key+ " with: " + template_vars[key]
                   text = text.replace("{{" + key + "}}", template_vars[key])
              else:
                  print "WARNING: Key " + key + " has no value!!!"
            dest.write(text)
            dest.close()

