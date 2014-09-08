#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from __future__ import with_statement

import base64
import logging
import os
import pipes
import random
import shutil
import subprocess
import sys
import tempfile
import time
import urllib2
from optparse import OptionParser
from sys import stderr
import boto
from boto.ec2.blockdevicemapping import BlockDeviceMapping, EBSBlockDeviceType
from boto import ec2

from boto.ec2.regioninfo import RegionInfo


class UsageError(Exception):
  pass

# A URL prefix from which to fetch AMI information
AMI_PREFIX = "https://raw.github.com/mesos/spark-euca/v2/ami-list"

# Configure and parse our command-line arguments
def parse_args():
  parser = OptionParser(usage="mesos-euca [options] <action> <cluster_name>"
      + "\n\n<action> can be: launch, destroy, login, stop, start, get-master",
      add_help_option=False)
  parser.add_option("-h", "--help", action="help",
                    help="Show this help message and exit")
  parser.add_option("-s", "--slaves", type="int", default=1,
      help="Number of slaves to launch (default: 1)")
  parser.add_option("-w", "--wait", type="int", default=120,
      help="Seconds to wait for nodes to start (default: 120)")
  parser.add_option("-k", "--key-pair",
      help="Key pair to use on instances")
  parser.add_option("-i", "--identity-file",
      help="SSH private key file to use for logging into instances")
  parser.add_option("-t", "--instance-type", default="m1.large",
      help="Type of instance to launch (default: m1.large). " +
           "WARNING: must be 64-bit; small instances won't work")
  parser.add_option("-m", "--master-instance-type", default="",
      help="Master instance type (leave empty for same as instance-type)")
  parser.add_option("-r", "--region", default="cs270",
      help="EC2 region zone to launch instances in")
  parser.add_option("-z", "--zone", default="",
      help="Availability zone to launch instances in, or 'all' to spread " +
           "slaves across multiple (an additional $0.01/Gb for bandwidth" +
           "between zones applies)")
  parser.add_option("-a", "--ami", help="Amazon Machine Image ID to use")
  parser.add_option("-v", "--spark-version", default="1.0.1",
      help="Version of Spark to use: 'X.Y.Z' or a specific git hash")
  parser.add_option("--spark-git-repo",
      default="https://github.com/apache/spark",
      help="Github repo from which to checkout supplied commit hash")
  parser.add_option("--hadoop-major-version", default="1",
      help="Major version of Hadoop (default: 0.18.2)")
  parser.add_option("--mesos-version", default="0.18.2",
      help="Major version of Hadoop (default: 1)")
  parser.add_option("-D", metavar="[ADDRESS:]PORT", dest="proxy_port",
      help="Use SSH dynamic port forwarding to create a SOCKS proxy at " +
            "the given local address (for use with login)")
  parser.add_option("--resume", action="store_true", default=False,
      help="Resume installation on a previously launched cluster " +
           "(for debugging)")
  parser.add_option("--ebs-vol-size", metavar="SIZE", type="int", default=0,
      help="Attach a new EBS volume of size SIZE (in GB) to each node as " +
           "/vol. The volumes will be deleted when the instances terminate. " +
           "Only possible on EBS-backed AMIs.")
  parser.add_option("--vol-size", metavar="SIZE", type="int", default=0,
      help="Attach a new volume of size SIZE (in GB) to each node as " +
           "/vol.")
  parser.add_option("--swap", metavar="SWAP", type="int", default=1024,
      help="Swap space to set up per node, in MB (default: 1024)")
  parser.add_option("--spot-price", metavar="PRICE", type="float",
      help="If specified, launch slaves as spot instances with the given " +
            "maximum price (in dollars)")
  parser.add_option("--ganglia", action="store_true", default=True,
      help="Setup Ganglia monitoring on cluster (default: on). NOTE: " +
           "the Ganglia page will be publicly accessible")
  parser.add_option("--no-ganglia", action="store_false", dest="ganglia",
      help="Disable Ganglia monitoring for the cluster")
  parser.add_option("-u", "--user", default="root",
      help="The SSH user you want to connect as (default: root)")
  parser.add_option("--delete-groups", action="store_true", default=False,
      help="When destroying a cluster, delete the security groups that were created")
  parser.add_option("--use-existing-master", action="store_true", default=False,
      help="Launch fresh slaves, but use an existing stopped master if possible")
  parser.add_option("--worker-instances", type="int", default=1,
      help="Number of instances per worker: variable SPARK_WORKER_INSTANCES (default: 1)")
  parser.add_option("--master-opts", type="string", default="",
      help="Extra options to give to master through SPARK_MASTER_OPTS variable (e.g -Dspark.worker.timeout=180)")
  parser.add_option("--user-data", type="string", default="",
      help="User data to pass to the instances created")
  parser.add_option("--user-data-file", type="string", default="",
      help="User data-file to pass to the instances created")
  parser.add_option("--os-type", type="string", default="",
      help="Type of the OS (ubuntu/ centos)"),
  parser.add_option("--installation-type", type="string", default="spark-standalone",
      help="Type of installation (spark-standalone /  mesos)"),
  parser.add_option("-f", "--ft", metavar="NUM_MASTERS", default="1", 
      help="Number of masters to run. Default is 1. Greater values " + 
           "make Mesos run in fault-tolerant mode with ZooKeeper.")



  (opts, args) = parser.parse_args()
  if len(args) != 2:
    parser.print_help()
    sys.exit(1)
  (action, cluster_name) = args

  # Boto config check
  # http://boto.cloudhackers.com/en/latest/boto_config_tut.html
  home_dir = os.getenv('HOME')
  if home_dir == None or not os.path.isfile(home_dir + '/.boto'):
    if not os.path.isfile('/etc/boto.cfg'):
      if os.getenv('AWS_ACCESS_KEY_ID') == None:
        print >> stderr, ("ERROR: The environment variable AWS_ACCESS_KEY_ID " +
                          "must be set")
        sys.exit(1)
      if os.getenv('AWS_SECRET_ACCESS_KEY') == None:
        print >> stderr, ("ERROR: The environment variable AWS_SECRET_ACCESS_KEY " +
                          "must be set")
        sys.exit(1)
      if os.getenv('EC2_USER_ID') == None:
           print >> stderr, ("ERROR: The environment variable EC2_USER_ID " +
                          "must be set")
           sys.exit(1)
  return (opts, action, cluster_name)


# Get the EC2 security group of the given name, creating it if it doesn't exist
def get_or_make_group(conn, name):
  groups = conn.get_all_security_groups()
  group = [g for g in groups if g.name == name]
  if len(group) > 0:
    return group[0]
  else:
    print "Creating security group " + name
    return conn.create_security_group(name, "Mesos EC2 group")


# Wait for a set of launched instances to exit the "pending" state
# (i.e. either to start running or to fail and be terminated)
def wait_for_instances(conn, instances):
  while True:
    for i in instances:
      i.update()
    if len([i for i in instances if i.state == 'pending']) > 0:
      time.sleep(5)
    else:
      return


# Check whether a given EC2 instance object is in a state we consider active,
# i.e. not terminating or terminated. We count both stopping and stopped as
# active since we can restart stopped clusters.
def is_active(instance):
  return (instance.state in ['pending', 'running', 'stopping', 'stopped'])

# Return correct versions of Spark and Shark, given the supplied Spark version
def get_spark_shark_version(opts):
  spark_shark_map = {"0.7.3": "0.7.1", "0.8.0": "0.8.0", "0.8.1": "0.8.1", "0.9.0": "0.9.0", 
    "0.9.1": "0.9.1", "1.0.0": "1.0.0", "1.0.1":"1.0.1", "1.0.2":"1.0.2"}
  version = opts.spark_version.replace("v", "")
  if version not in spark_shark_map:
    print >> stderr, "Don't know about Spark version: %s" % version
    sys.exit(1)
  return (version, spark_shark_map[version])

# Attempt to resolve an appropriate AMI given the architecture and
# region of the request.
def get_ami(opts):
  instance_types = {
    "m1.small":    "pvm",
    "m1.medium":   "pvm",
    "m1.large":    "pvm",
    "m1.xlarge":   "pvm",
    "t1.micro":    "pvm",
    "c1.medium":   "pvm",
    "c1.xlarge":   "pvm",
    "m2.xlarge":   "pvm",
    "m2.2xlarge":  "pvm",
    "m2.4xlarge":  "pvm",
    "cc1.4xlarge": "hvm",
    "cc2.8xlarge": "hvm",
    "cg1.4xlarge": "hvm",
    "hs1.8xlarge": "hvm",
    "hi1.4xlarge": "hvm",
    "m3.xlarge":   "hvm",
    "m3.2xlarge":  "hvm",
    "cr1.8xlarge": "hvm",
    "i2.xlarge":   "hvm",
    "i2.2xlarge":  "hvm",
    "i2.4xlarge":  "hvm",
    "i2.8xlarge":  "hvm",
    "c3.large":    "pvm",
    "c3.xlarge":   "pvm",
    "c3.2xlarge":  "pvm",
    "c3.4xlarge":  "pvm",
    "c3.8xlarge":  "pvm"
  }
  if opts.instance_type in instance_types:
    instance_type = instance_types[opts.instance_type]
  else:
    instance_type = "pvm"
    print >> stderr,\
        "Don't recognize %s, assuming type is pvm" % opts.instance_type

  ami_path = "%s/%s/%s" % (AMI_PREFIX, opts.region, instance_type)
  print "ami_path = ", ami_path
  try:
    ami = urllib2.urlopen(ami_path).read().strip()
    print "Spark AMI: " + ami
  except:
    print >> stderr, "Could not resolve AMI at: " + ami_path
    sys.exit(1)

  return ami

# Launch a cluster of the given name, by setting up its security groups,
# and then starting new instances in them.
# Returns a tuple of EC2 reservation objects for the master and slaves
# Fails if there already instances running in the cluster's groups.
def launch_cluster(conn, opts, cluster_name):
  if opts.identity_file is None:
    print >> stderr, "ERROR: Must provide an identity file (-i) for ssh connections."
    sys.exit(1)
  if opts.key_pair is None:
    print >> stderr, "ERROR: Must provide a key pair name (-k) to use on instances."
    sys.exit(1)
  print "Setting up security groups..."
  master_group = get_or_make_group(conn, cluster_name + "-master")
  master_group.owner_id = os.getenv('EC2_USER_ID')
  slave_group = get_or_make_group(conn, cluster_name + "-slaves")
  slave_group.owner_id = os.getenv('EC2_USER_ID')
  zoo_group = get_or_make_group(conn, cluster_name + "-zoo")
  zoo_group.owner_id = os.getenv('EC2_USER_ID')
  
  if master_group.rules == []: # Group was just now created
    master_group.authorize(src_group=master_group)
    master_group.authorize(src_group=slave_group)
    master_group.authorize(src_group=zoo_group)
    master_group.authorize('tcp', 22, 22, '0.0.0.0/0')
    master_group.authorize('tcp', 8080, 8081, '0.0.0.0/0')
    master_group.authorize('tcp', 19999, 19999, '0.0.0.0/0')
    master_group.authorize('tcp', 50030, 50030, '0.0.0.0/0')
    master_group.authorize('tcp', 50070, 50070, '0.0.0.0/0')
    master_group.authorize('tcp', 60070, 60070, '0.0.0.0/0')
    master_group.authorize('tcp', 38090, 38090, '0.0.0.0/0')
    master_group.authorize('tcp', 4040, 4045, '0.0.0.0/0')
    if opts.ganglia:
      master_group.authorize('tcp', 5080, 5080, '0.0.0.0/0')
  if slave_group.rules == []: # Group was just now created
    slave_group.authorize(src_group=master_group)
    slave_group.authorize(src_group=slave_group)
    master_group.authorize(src_group=zoo_group)
    slave_group.authorize('tcp', 22, 22, '0.0.0.0/0')
    slave_group.authorize('tcp', 8080, 8081, '0.0.0.0/0')
    slave_group.authorize('tcp', 50060, 50060, '0.0.0.0/0')
    slave_group.authorize('tcp', 50075, 50075, '0.0.0.0/0')
    slave_group.authorize('tcp', 60060, 60060, '0.0.0.0/0')
    slave_group.authorize('tcp', 60075, 60075, '0.0.0.0/0')
  
  if zoo_group.rules == []: # Group was just now created
      zoo_group.authorize(src_group=master_group)
      zoo_group.authorize(src_group=slave_group)
      zoo_group.authorize(src_group=zoo_group)
      zoo_group.authorize('tcp', 22, 22, '0.0.0.0/0')
      zoo_group.authorize('tcp', 2181, 2181, '0.0.0.0/0')
      zoo_group.authorize('tcp', 2888, 2888, '0.0.0.0/0')
      zoo_group.authorize('tcp', 3888, 3888, '0.0.0.0/0')   
   


  # Check if instances are already running in our groups
  existing_masters, existing_slaves, existing_zoos = get_existing_cluster(conn, opts, cluster_name,
                                                           die_on_error=False)
  if existing_slaves or (existing_masters and not opts.use_existing_master):
    print >> stderr, ("ERROR: There are already instances running in " +
        "group %s or %s" % (master_group.name, slave_group.name, zoo_group.name))
    sys.exit(1)

  # Figure out Spark AMI
  if opts.ami is None:
    opts.ami = get_ami(opts)
  print "Launching instances..."

  try:
    image = conn.get_all_images(image_ids=[opts.ami])[0]
  except:
    print >> stderr, "Could not find AMI " + opts.ami
    sys.exit(1)

  # Create block device mapping so that we can add an EBS volume if asked to
  logging.debug( "Calling boto BlockDeviceMapping()...")
  block_map = BlockDeviceMapping()
  logging.debug(" Printing block_map..") 
  #print block_map
  if opts.ebs_vol_size > 0:
    logging.debug("Calling boto EBSBlockDeviceType()...")
    device = EBSBlockDeviceType()
    #print "device: ", device
    device.size = opts.ebs_vol_size
    device.delete_on_termination = True
    device.ephemeral_name = "ephemeral0"
    #block_map["/dev/sdv"] = device
    #block_map["/dev/sdv"] = device
    block_map["/dev/vdb"] = device
    
  if opts.user_data_file != None:
      user_data_file = open(opts.user_data_file)
      try:
          opts.user_data = user_data_file.read()
          #print "user data (encoded) = ", opts.user_data
      finally:
          user_data_file.close()
  
  # Launch non-spot instances
  zones = get_zones(conn, opts)    
  num_zones = len(zones)
  i = 0
  slave_nodes = []
  for zone in zones:
    num_slaves_this_zone = get_partition(opts.slaves, num_zones, i)
    if num_slaves_this_zone > 0:
        slave_res = image.run(key_name = opts.key_pair,
                              security_groups = [slave_group],
                              instance_type = opts.instance_type,
                              placement = zone,
                              min_count = num_slaves_this_zone,
                              max_count = num_slaves_this_zone,
                              block_device_map = block_map,
                              user_data = opts.user_data)
        slave_nodes += slave_res.instances
        print "Launched %d slaves in %s, regid = %s" % (num_slaves_this_zone,
                                                        zone, slave_res.id)
    i += 1  

  # Launch or resume masters
  if existing_masters:
    print "Starting master..."
    for inst in existing_masters:
      if inst.state not in ["shutting-down", "terminated"]:  
        inst.start()
    master_nodes = existing_masters
  else:
    master_type = opts.master_instance_type
    if master_type == "":
      master_type = opts.instance_type
    if opts.zone == 'all':
      opts.zone = random.choice(conn.get_all_zones()).name
    master_res = image.run(key_name = opts.key_pair,
                           security_groups = [master_group],
                           instance_type = master_type,
                           placement = opts.zone,
                           min_count = 1,
                           max_count = 1,
                           block_device_map = block_map,
                           user_data = opts.user_data)
    master_nodes = master_res.instances
    print "Launched master in %s, regid = %s" % (zone, master_res.id)
    
  # Launch ZooKeeper nodes if required
  if int(opts.ft) > 1:
    print "Running " + opts.ft + " zookeepers"
    zoo_res = image.run(key_name = opts.key_pair,
                        security_groups = [zoo_group],
                        instance_type = opts.instance_type,
                        placement = opts.zone,
                        min_count = 3,
                        max_count = 3,
                        block_device_map = block_map,
                        user_data = opts.user_data)
    zoo_nodes = zoo_res.instances
    print "Launched zoo, regid = " + zoo_res.id
  else:
    zoo_nodes = []

  # Return all the instances
  return (master_nodes, slave_nodes, zoo_nodes)


# Get the EC2 instances in an existing cluster if available.
# Returns a tuple of lists of EC2 instance objects for the masters and slaves
def get_existing_cluster(conn, opts, cluster_name, die_on_error=True):
  print "Searching for existing cluster " + cluster_name + "..."
  
  reservations = conn.get_all_reservations()
  master_nodes = []
  slave_nodes = []
  zoo_nodes = []
  for res in reservations:
    #print "res.groups", res.groups
    #print "res.groups.name", res.groups[0].name
    active = [i for i in res.instances if is_active(i)]
    for inst in active:
      group_name = res.groups[0].name
      if group_name == cluster_name + "-master":
        master_nodes.append(inst)
      elif group_name == cluster_name + "-slaves":
        slave_nodes.append(inst)
      elif group_name == cluster_name + "-zoo":
        zoo_nodes.append(inst)
                  
  if any((master_nodes, slave_nodes, zoo_nodes)):
    print ("Found %d master(s), %d slaves, %d zookeeper nodes" %
           (len(master_nodes), len(slave_nodes), len(zoo_nodes)))
  if master_nodes != [] or not die_on_error:
    return (master_nodes, slave_nodes, zoo_nodes)
  else:
    if master_nodes == [] and slave_nodes != []:
      print >> sys.stderr, "ERROR: Could not find master in group " + cluster_name + "-master"
    else:
      print >> sys.stderr, "ERROR: Could not find any existing cluster"
    sys.exit(1)


# Deploy configuration files and run setup scripts on a newly launched
# or started EC2 cluster.
def setup_cluster(conn, master_nodes, slave_nodes, zoo_nodes, opts, deploy_ssh_key):
  master = master_nodes[0].public_dns_name
  if deploy_ssh_key:
    print "Generating cluster's SSH key on master..."
    key_setup = """
      [ -f ~/.ssh/id_rsa ] ||
        (ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa &&
         cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys)
    """
    ssh(master, opts, key_setup)
    dot_ssh_tar = ssh_read(master, opts, ['tar', 'c', '.ssh'])
    print "Transferring cluster's SSH key to slaves..."
    for slave in slave_nodes:
      print slave.public_dns_name
      ssh_write(slave.public_dns_name, opts, ['tar', 'x'], dot_ssh_tar)

  #modules = ['spark', 'shark', 'ephemeral-hdfs', 'persistent-hdfs', 'mapreduce', 'spark-standalone', 'tachyon']

  modules = ['ephemeral-hdfs', 'persistent-hdfs']

  if opts.hadoop_major_version == "1":
    modules = filter(lambda x: x != "mapreduce", modules)

  if opts.installation_type == "mesos":
      modules.append('mesos')
  
  if opts.ganglia:
    modules.append('ganglia')
    
  if opts.os_type == "ubuntu":
      pkg_mngr = "apt-get --yes --force-yes"
  elif opts.os_type == "centos":
      pkg_mngr = "yum --assumeyes"
     

  #ssh(master, opts, "sudo su")
  #ssh(master, opts, "sudo cp /home/ubuntu/.ssh/authorized_keys /root/.ssh")
  #Fixing issue with disallowing logins after updateing pam
  if opts.os_type == "centos":
      #ssh(master, opts, "echo 'exclude=pam*' >> /etc/yum.conf")
      ssh(master, opts, "setenforce 0") #turns off selinux without a reboot
      
  ssh(master, opts, pkg_mngr + " update")
  #ssh(master, opts, pkg_mngr + " install wget")
  ssh(master, opts, pkg_mngr + " install git")
  
  if opts.os_type == "ubuntu":
      ssh(master, opts, pkg_mngr + " install openjdk-7-jdk")
      ssh(master, opts, "mv /usr/lib/jvm/java-7-openjdk-amd64/ /usr/lib/jvm/java-1.7.0/")
  elif opts.os_type == "centos":
      ssh(master, opts, pkg_mngr + " install java-1.7.0-openjdk")
      ssh(master, opts, "mv /usr/lib/jvm/java-1.7.0-openjdk-1.7.0.65.x86_64/ /usr/lib/jvm/java-1.7.0/")
      ssh(master, opts, pkg_mngr + " install wget")
      
  ssh(master, opts, "wget http://downloads.typesafe.com/scala/2.11.1/scala-2.11.1.tgz")
  ssh(master, opts, "tar xvf scala-2.11.1.tgz")
  ssh(master, opts, "mv scala-2.11.1 scala")
  ssh(master, opts, "rm scala-2.11.1.tgz")
  
  ssh(master, opts, "echo JAVA_HOME='/usr/lib/jvm/java-1.7.0'  >> /etc/environment")
  ssh(master, opts, "echo SCALA_HOME='/root/scala' >> /etc/environment")
  ssh(master, opts, "echo PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/root/scala/bin:/usr/lib/jvm/java-1.7.0/bin' >> /etc/environment")
       
  #Download packages needed by the setup scripts on the spark-euca directory - Normally downloaded from s3.amazonaws.com
  #:q
  #ssh(master, opts, "wget https://archive.apache.org/dist/hadoop/core/hadoop-1.0.4/hadoop-1.0.4.tar.gz")
  #ssh(master, opts, "wget https://archive.apache.org/dist/hive/hive-0.9.0/hive-0.9.0.tar.gz") # shark 0.8.* needs hive and the shark/setup.sh script tries to rsync hive* regardless of the version used
  
  # *****  Required packets to run MLlib ******
  #ssh(master, opts, pkg_mngr + " install gfortran")
  #ssh(master, opts, pkg_mngr + " install libgfortran3")
  #ssh(master, opts, pkg_mngr + " libatlas3gf-base libopenblas-base")
  #ssh(master, opts, "update-alternatives --config libblas.so.3gf --skip-auto")
  #ssh(master, opts, "update-alternatives --config liblapack.so.3gf --skip-auto")
  
  
  # ****** Required configurations for Apache Mesos ******
   # Install build tools.
   # $ sudo apt-get install build-essential
   
   # Install devel python.
   #$ sudo apt-get install python-dev python-boto
   
   # Install devel libcurl
   #$ sudo apt-get install libcurl4-nss-dev

   # Install devel libsasl (***Only required for Mesos 0.14.0 or newer***).
   #$ sudo apt-get install libsasl2-dev

   # Install Maven (***Only required for Mesos 0.18.1 or newer***).
   #$ sudo apt-get install maven
  
  #If we want to format the attached volume with xfs the following should not be in comments & prepare-slaves.sh should be modified as well
  #if opts.vol_size > 0:
  #    ssh(master, opts, pkg_mngr + " install xfsprogs")
  
  # NOTE: We should clone the repository before running deploy_files to
  # prevent ec2-variables.sh from being overwritten
  ssh(master, opts, "rm -rf spark-euca && git clone -b mesos https://github.com/strat0sphere/spark-euca.git")
  
  print "Deploying files to master..."
  deploy_files(conn, "deploy.generic", opts, master_nodes, slave_nodes, zoo_nodes, modules)

  print "Running setup on master..."
  ssh(master, opts, "echo '****************'; ls -al")
  
  print "opts.installation_type: " + opts.installation_type
  if(opts.installation_type == "mesos"):
      setup_mesos_cluster(master, opts)
  elif(opts.installation_type == "spark-standalone"):
      setup_spark_standalone_cluster(master, opts)
  
  print "Done!"

def setup_spark_standalone_cluster(master, opts):
  #ssh(master, opts, "chmod u+x ~/spark-testing/setup.sh")
  #ssh(master, opts, "~/spark-testing/setup.sh") #Run everything needed to prepare the slaves instances
  ssh(master, opts, "chmod u+x spark-euca/setup.sh")
  ssh(master, opts, "spark-euca/setup.sh " + opts.os_type)
  ssh(master, opts, "echo 'Starting-all...'")
  ssh(master, opts, "/root/spark/sbin/start-all.sh")
  #ssh(master, opts, "/root/spark-1.0.0-bin-hadoop1/sbin/start-all.sh")

  print "Spark standalone cluster started at http://%s:8080" % master

  if opts.ganglia:
    print "Ganglia started at http://%s:5080/ganglia" % master

def setup_mesos_cluster(master, opts):
  #ssh(master, opts, "chmod u+x ~/spark-testing/setup.sh")
  #ssh(master, opts, "~/spark-testing/setup.sh") #Run everything needed to prepare the slaves instances
  ssh(master, opts, "chmod u+x spark-euca/setup-mesos.sh")
  #Define configuration files - Set masters and slaves in order to call cluster scripts and automatically sstart the cluster
  #ssh(master, opts, "spark-euca/setup %s %s %s %s" % (opts.os, opts.download, opts.branch, opts.swap))
  ssh(master, opts, "spark-euca/setup-mesos.sh " + opts.os_type)
  #ssh(master, opts, "echo 'Starting-all...'")
  #ssh(master, opts, "/root/spark/sbin/start-all.sh")
  #ssh(master, opts, "/root/spark-1.0.0-bin-hadoop1/sbin/start-all.sh")

  print "Mesos cluster started at http://%s:5050" % master

  if opts.ganglia:
    print "Ganglia started at http://%s:5080/ganglia" % master


# Wait for a whole cluster (masters, slaves and ZooKeeper) to start up
def wait_for_cluster(conn, wait_secs, master_nodes, slave_nodes, zoo_nodes):
  print "Waiting for instances to start up..."
  time.sleep(5)
  wait_for_instances(conn, master_nodes)
  wait_for_instances(conn, slave_nodes)
  if zoo_nodes != []:
    wait_for_instances(conn, zoo_nodes)
  print "Waiting %d more seconds..." % wait_secs
  time.sleep(wait_secs)


# Get number of local disks available for a given EC2 instance type.
def get_num_disks(instance_type):
  # From http://docs.amazonwebservices.com/AWSEC2/latest/UserGuide/index.html?InstanceStorage.html
  disks_by_instance = {
    "m1.small":    1,
    "m1.medium":   1,
    "m1.large":    2,
    "m1.xlarge":   4,
    "t1.micro":    1,
    "c1.medium":   1,
    "c1.xlarge":   4,
    "m2.xlarge":   1,
    "m2.2xlarge":  1,
    "m2.4xlarge":  2,
    "cc1.4xlarge": 2,
    "cc2.8xlarge": 4,
    "cg1.4xlarge": 2,
    "hs1.8xlarge": 24,
    "cr1.8xlarge": 2,
    "hi1.4xlarge": 2,
    "m3.xlarge":   0,
    "m3.2xlarge":  0,
    "i2.xlarge":   1,
    "i2.2xlarge":  2,
    "i2.4xlarge":  4,
    "i2.8xlarge":  8,
    "c3.large":    2,
    "c3.xlarge":   2,
    "c3.2xlarge":  2,
    "c3.4xlarge":  2,
    "c3.8xlarge":  2
  }
  if instance_type in disks_by_instance:
    return disks_by_instance[instance_type]
  else:
    print >> stderr, ("WARNING: Don't know number of disks on instance type %s; assuming 1"
                      % instance_type)
    return 1


# Deploy the configuration file templates in a given local directory to
# a cluster, filling in any template parameters with information about the
# cluster (e.g. lists of masters and slaves). Files are only deployed to
# the first master instance in the cluster, and we expect the setup
# script to be run on that instance to copy them to other nodes.
def deploy_files(conn, root_dir, opts, master_nodes, slave_nodes, zoo_nodes, modules):
  active_master = master_nodes[0].public_dns_name

  num_disks = get_num_disks(opts.instance_type)
  hdfs_data_dirs = "/mnt/ephemeral-hdfs/data"
  mapred_local_dirs = "/mnt/hadoop/mrlocal"
  spark_local_dirs = "/mnt/spark"
  if num_disks > 1:
    for i in range(2, num_disks + 1):
      hdfs_data_dirs += ",/mnt%d/ephemeral-hdfs/data" % i
      mapred_local_dirs += ",/mnt%d/hadoop/mrlocal" % i
      spark_local_dirs += ",/mnt%d/spark" % i

  if zoo_nodes != []:
    zoo_list = '\n'.join([i.public_dns_name for i in zoo_nodes])
    cluster_url = "zoo://" + ",".join(
        ["%s:2181/mesos" % i.public_dns_name for i in zoo_nodes])
  else:
    zoo_list = "NONE"
    
  cluster_url = "master@%s:5050" % active_master

  if "." in opts.spark_version:
    # Pre-built spark & shark deploy
    (spark_v, shark_v) = get_spark_shark_version(opts)
  else:
    # Spark-only custom deploy
    spark_v = "%s|%s" % (opts.spark_git_repo, opts.spark_version)
    shark_v = ""
    modules = filter(lambda x: x != "shark", modules)
   
  template_vars = {
    "master_list": '\n'.join([i.public_dns_name for i in master_nodes]),
    "active_master": active_master,
    "slave_list": '\n'.join([i.public_dns_name for i in slave_nodes]),
    "zoo_list": zoo_list,
    "cluster_url": cluster_url,
    "hdfs_data_dirs": hdfs_data_dirs,
    "mapred_local_dirs": mapred_local_dirs,
    "spark_local_dirs": spark_local_dirs,
    "swap": str(opts.swap),
    "modules": '\n'.join(modules),
    "spark_version": spark_v,
    "shark_version": shark_v,
    "hadoop_major_version": opts.hadoop_major_version,
    "spark_worker_instances": "%d" % opts.worker_instances,
    "spark_master_opts": opts.master_opts,
    "mesos_version": opts.mesos_version
  }


  # Create a temp directory in which we will place all the files to be
  # deployed after we substitue template parameters in them
  tmp_dir = tempfile.mkdtemp()
  for path, dirs, files in os.walk(root_dir):
    if path.find(".svn") == -1:
      dest_dir = os.path.join('/', path[len(root_dir):])
      local_dir = tmp_dir + dest_dir
      if not os.path.exists(local_dir):
        os.makedirs(local_dir)
      for filename in files:
        if filename[0] not in '#.~' and filename[-1] != '~':
          dest_file = os.path.join(dest_dir, filename)
          local_file = tmp_dir + dest_file
          with open(os.path.join(path, filename)) as src:
            with open(local_file, "w") as dest:
              text = src.read()
              for key in template_vars:
                text = text.replace("{{" + key + "}}", template_vars[key])
              dest.write(text)
              dest.close()
  
  #subprocess.check_call("sudo su")
  # rsync the whole directory over to the master machine
  command = [
      'rsync', '-rv',
      '-e', stringify_command(ssh_command(opts)),
      "%s/" % tmp_dir,
      "%s@%s:/" % (opts.user, active_master)
    ]
  subprocess.check_call(command)
  # Remove the temp directory we created above
  shutil.rmtree(tmp_dir)


def stringify_command(parts):
  if isinstance(parts, str):
    return parts
  else:
    return ' '.join(map(pipes.quote, parts))


def ssh_args(opts):
  parts = ['-o', 'StrictHostKeyChecking=no']
  if opts.identity_file is not None:
    parts += ['-i', opts.identity_file]
  return parts


def ssh_command(opts):
  return ['ssh'] + ssh_args(opts)


# Run a command on a host through ssh, retrying up to five times
# and then throwing an exception if ssh continues to fail.
def ssh(host, opts, command):
  tries = 0
  while True:
    try:
      return subprocess.check_call(
        ssh_command(opts) + ['-t', '-t', '%s@%s' % (opts.user, host), stringify_command(command)])
    except subprocess.CalledProcessError as e:
      if (tries > 5):
        # If this was an ssh failure, provide the user with hints.
        if e.returncode == 255:
          raise UsageError("Failed to SSH to remote host {0}.\nPlease check that you have provided the correct --identity-file and --key-pair parameters and try again.".format(host))
        else:
          raise e
      print >> stderr, "Error executing remote command, retrying after 30 seconds: {0}".format(e)
      time.sleep(30)
      tries = tries + 1


def ssh_read(host, opts, command):
  return subprocess.check_output(
      ssh_command(opts) + ['%s@%s' % (opts.user, host), stringify_command(command)])


def ssh_write(host, opts, command, input):
  tries = 0
  while True:
    proc = subprocess.Popen(
        ssh_command(opts) + ['%s@%s' % (opts.user, host), stringify_command(command)],
        stdin=subprocess.PIPE)
    proc.stdin.write(input)
    proc.stdin.close()
    status = proc.wait()
    if status == 0:
      break
    elif (tries > 5):
      raise RuntimeError("ssh_write failed with error %s" % proc.returncode)
    else:
      print >> stderr, "Error {0} while executing remote command, retrying after 30 seconds".format(status)
      time.sleep(30)
      tries = tries + 1


# Gets a list of zones to launch instances in
def get_zones(conn, opts):
  if opts.zone == 'all':
    zones = [z.name for z in conn.get_all_zones()]
  else:
    zones = [opts.zone]
  return zones


# Gets the number of items in a partition
def get_partition(total, num_partitions, current_partitions):
  num_slaves_this_zone = total / num_partitions
  if (total % num_partitions) - current_partitions > 0:
    num_slaves_this_zone += 1
  return num_slaves_this_zone

def attach_volumes(conn, nodes, vol_size, device_name="/dev/vdb"):
    for node in nodes:
        print "Creating volume with size ", vol_size, " in zone: ", node.placement
        vol = conn.create_volume(vol_size, node.placement)
        print "Attaching volume with id ", vol.id, " to instance with id: ", node.id
        time.sleep(10)
        status = conn.attach_volume(vol.id, node.id, device_name)
        time.sleep(10)
        print "Status = ", status

def real_main():
  (opts, action, cluster_name) = parse_args()
  try:
    euca_ec2_host="eucalyptus.race.cs.ucsb.edu" #TODO: Replace with opts.euca-ec2-host
    euca_id=os.getenv('AWS_ACCESS_KEY')
    euca_key=os.getenv('AWS_SECRET_KEY')
    euca_region = RegionInfo(name="eucalyptus", endpoint=euca_ec2_host)
    ec2conn = boto.connect_ec2(
        aws_access_key_id=euca_id,
        aws_secret_access_key=euca_key, 
        is_secure=False,
        port=8773, 
        path="/services/Eucalyptus", 
        region=euca_region)
    print ec2conn.get_all_zones()
    conn = ec2conn  
    #conn_ec2 = ec2.connect_to_region(opts.region)
  except Exception as e:
    print >> stderr, (e)
    sys.exit(1)

  # Select an AZ at random if it was not specified.
  if opts.zone == "":
    opts.zone = random.choice(conn.get_all_zones()).name

  if action == "launch":
    if opts.slaves <= 0:
      print >> sys.stderr, "ERROR: You have to start at least 1 slave"
      sys.exit(1)
    if opts.resume:
      (master_nodes, slave_nodes, zoo_nodes) = get_existing_cluster(
          conn, opts, cluster_name)
    else:
      (master_nodes, slave_nodes, zoo_nodes) = launch_cluster(conn, opts, cluster_name)
      wait_for_cluster(conn, opts.wait, master_nodes, slave_nodes, zoo_nodes)
      if opts.vol_size > 0:
          attach_volumes(conn, master_nodes, opts.vol_size)
          time.sleep(10)
          attach_volumes(conn, slave_nodes, opts.vol_size)
          time.sleep(10)
    setup_cluster(conn, master_nodes, slave_nodes, zoo_nodes, opts, True)

  elif action == "destroy":
    response = raw_input("Are you sure you want to destroy the cluster " +
        cluster_name + "?\nALL DATA ON ALL NODES WILL BE LOST!!\n" +
        "Destroy cluster " + cluster_name + " (y/N): ")
    if response == "y":
      (master_nodes, slave_nodes, zoo_nodes) = get_existing_cluster(
          conn, opts, cluster_name, die_on_error=False)
      print "Terminating master..."
      for inst in master_nodes:
        print "Terminating master instance... ", inst  
        inst.terminate()
      print "Terminating slaves..."
      for inst in slave_nodes:
        print "Terminating slave instance... ", inst   
        inst.terminate()
      print "Terminating zookeepers..."
      for inst in zoo_nodes:
          print "Terminating zoo instance...", inst
          inst.terminate()

      # Delete security groups as well
      if opts.delete_groups:
        print "Deleting security groups (this will take some time)..."
        group_names = [cluster_name + "-master", cluster_name + "-slaves"]

        attempt = 1;
        while attempt <= 3:
          print "Attempt %d" % attempt
          groups = [g for g in conn.get_all_security_groups() if g.name in group_names]
          success = True
          # Delete individual rules in all groups before deleting groups to
          # remove dependencies between them
          for group in groups:
            print "Deleting rules in security group " + group.name
            for rule in group.rules:
              for grant in rule.grants:
                  success &= group.revoke(ip_protocol=rule.ip_protocol,
                           from_port=rule.from_port,
                           to_port=rule.to_port,
                           src_group=grant)

          # Sleep for AWS eventual-consistency to catch up, and for instances
          # to terminate
          time.sleep(30)  # Yes, it does have to be this long :-(
          for group in groups:
            try:
              conn.delete_security_group(group.name)
              print "Deleted security group " + group.name
            except boto.exception.EC2ResponseError:
              success = False;
              print "Failed to delete security group " + group.name

          # Unfortunately, group.revoke() returns True even if a rule was not
          # deleted, so this needs to be rerun if something fails
          if success: break;

          attempt += 1

        if not success:
          print "Failed to delete all security groups after 3 tries."
          print "Try re-running in a few minutes."

  elif action == "login":
    (master_nodes, slave_nodes, zoo_nodes) = get_existing_cluster(
        conn, opts, cluster_name)
    master = master_nodes[0].public_dns_name
    print "Logging into master " + master + "..."
    proxy_opt = []
    if opts.proxy_port != None:
      proxy_opt = ['-D', opts.proxy_port]
    subprocess.check_call(
        ssh_command(opts) + proxy_opt + ['-t', '-t', "%s@%s" % (opts.user, master)])

  elif action == "get-master":
    (master_nodes, slave_nodes, zoo_nodes) = get_existing_cluster(conn, opts, cluster_name)
    print master_nodes[0].public_dns_name

  elif action == "stop":
    response = raw_input("Are you sure you want to stop the cluster " +
        cluster_name + "?\nDATA ON EPHEMERAL DISKS WILL BE LOST, " +
        "BUT THE CLUSTER WILL KEEP USING SPACE ON\n" +
        "AMAZON EBS IF IT IS EBS-BACKED!!\n" +
        "All data on spot-instance slaves will be lost.\n" +
        "Stop cluster " + cluster_name + " (y/N): ")
    if response == "y":
      (master_nodes, slave_nodes, zoo_nodes) = get_existing_cluster(
          conn, opts, cluster_name, die_on_error=False)
      print "Stopping master..."
      for inst in master_nodes:
        if inst.state not in ["shutting-down", "terminated"]:
          inst.stop()
      print "Stopping slaves..."
      for inst in slave_nodes:
        if inst.state not in ["shutting-down", "terminated"]:
          if inst.spot_instance_request_id:
            inst.terminate()
          else:
            inst.stop()

  elif action == "start":
    (master_nodes, slave_nodes, zoo_nodes) = get_existing_cluster(conn, opts, cluster_name)
    print "Starting slaves..."
    for inst in slave_nodes:
      if inst.state not in ["shutting-down", "terminated"]:
        inst.start()
    print "Starting master..."
    for inst in master_nodes:
      if inst.state not in ["shutting-down", "terminated"]:
        inst.start()
    if zoo_nodes != []:
      print "Starting zoo..."
      for inst in zoo_nodes:
        if inst.state not in ["shutting-down", "terminated"]:
          inst.start()
          
    wait_for_cluster(conn, opts.wait, master_nodes, slave_nodes, zoo_nodes)
    setup_cluster(conn, master_nodes, slave_nodes, zoo_nodes, opts, False)

  else:
    print >> stderr, "Invalid action: %s" % action
    sys.exit(1)


def main():
  try:
    real_main()
  except UsageError, e:
    print >> stderr, "\nError:\n", e
    sys.exit(1)


if __name__ == "__main__":
  logging.basicConfig()
  main()
