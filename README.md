Scripts on this repo are under current development and constantly change - Might not work for your system!

Has been tested with boto version 2.31.1
Eucalyptus private cloud is API compatible with Amazon EC2. The scripts on this repo are a modified version of the spark-ec2 tools that you can find here: https://github.com/mesos/spark-ec2
The current git repo might contain code from the original spark tools that is not currently used for the installation Eucalyptus.

spark-euca
=========

This repository contains the set of scripts used to setup a Spark cluster on
Eucalyptus.  It requires that Eycaluptus is already installed and then creates the instances to run your cluster according to the EMI you specify.

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
