#!/bin/bash

#Test installation

echo "Testing if MPI commands are configured correctly... "
which mpiexec
which mpd
which mpirun

echo "Running mpdtrace to check if mpd ring is working... "
#mpd &
mpdtrace
#mpdallexit

echo "Compiling mpi helloworld code"
#Download helloworld code
mpicc -o helloworld helloworld.c

/root/mesos/mpi/mpiexec-mesos.in zk://$ACTIVE_MASTER_PRIVATE:2181/mesos ./helloworld