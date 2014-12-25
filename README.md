Scripts on this repo are under current development and constantly change - Might not work for your system!

Has been tested with boto version 2.31.1
Eucalyptus private cloud is API compatible with Amazon EC2. The scripts on this repo are a modified version of the spark-ec2 tools that you can find here: https://github.com/mesos/spark-ec2. The scipts can be used unmodified with Eucalyptus. If you want to use Amazon you should copy the connector from the spark-ec2 repo. 
The current git repo might contain code from the original spark tools that is not currently used for the installation to Eucalyptus.

spark-euca
=========

This repository contains the set of scripts used to setup:
1) A Spark standalone cluster from scratch (emi or ami with Ubuntu 12.0.4) or 
2) A Mesos cluster with Spark, Spark-Streaming, MapReduce, Storm, Kafka and Hama running on Eucalyptus. The scripts require an emi (or similar an AWS ami) that has HDFS and Zookeeper pre-installed as long as compiled versions of Spark and Hadoop for Mesos. In the future I will extend the scripts to install all these with an empty emi as well.

In both cases I am assuming you already have a running eucalyptus cluster. The scripts require that Eycaluptus is already installed and then create the instances to run your cluster according to the EMI you specify.

### Usage

For case 1) all you need to do is run something like this: 
./spark-euca 
-i xxxx.pem 
-k xxxx 
-s n 
-emi-xyzzyzxy
-t x2.2xlarge 
--no-ganglia 
--os-type ubuntu
--user-data zzzz.sh  
launch spark-test

For case 2) all you need to do is run something like this:
./mesos-euca-emi -i xxxx.pem.pem
-k xxxx 
-s n
-emi-master emi-xyzzyzxy
-e emi-xyzzyzxy  
-t m2.2xlarge 
--no-ganglia 
-w 60 
--user-data-file zzzz.sh
--installation-type mesos-emi
--run-tests True
launch mesos-cluster-emi

Basically you could use the mesos-euca-emi to also install a Spark Standalone cluster by specifying the correct arguments but the spark-euca script will work just fine for Spark-standalone

*Check scripts for more options*

### Details


The Spark cluster setup is guided by the values set in `ec2-variables.sh`.`setup.sh`
first performs basic operations like enabling ssh across machines, mounting ephemeral
drives and also creates files named `/root/spark-euca/masters`, and `/root/spark-euca/slaves`.
Following that every module listed in `MODULES` is initialized. 

To add a new module, you will need to do the following:

  a. Create a directory with the module's name
  
  b. Optionally add a file named `init.sh`. This is called before templates are configured 
and can be used to install any pre-requisites.

  c. Add any files that need to be configured based on the cluster setup to `templates/`.
  The path of the file determines where the configured file will be copied to. Right now
  the set of variables that can be used in a template are
  
      {{master_list}}
      {{active_master}}
      {{slave_list}}
      {{zoo_list}}
      {{cluster_url}}
      {{hdfs_data_dirs}}
      {{mapred_local_dirs}}
      {{spark_local_dirs}}
      {{default_spark_mem}}
      {{spark_worker_instances}}
      {{spark_worker_cores}}
      {{spark_master_opts}}
      
   You can add new variables by modifying `deploy_templates.py`
   
   d. Add a file named `setup.sh` to launch any services on the master/slaves. This is called
   after the templates have been configured. You can use the environment variables `$SLAVES` to
   get a list of slave hostnames and `/root/spark-euca/copy-dir` to sync a directory across machines.
