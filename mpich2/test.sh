#!/bin/bash

#Test installation
#Download helloworld code
mpicc -o helloworld helloworld.c

/mnt/mesos/mpi/mpiexec-mesos.py zk://euca-10-2-248-74.eucalyptus.internal:2181/mesos ./helloworld