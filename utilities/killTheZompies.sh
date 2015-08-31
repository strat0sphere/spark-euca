#!/bin/sh
# Looks for /tmp/hsperfdata_* files leaved by unclean Java processes
# shutdowns and remove them.
# This should be executed by a user without sufficient rights to delete
# other users files...
 
for hsperfdata in /tmp/hsperfdata_*/*; do
  ps -p `basename ${hsperfdata}` &> /dev/null || rm -vf $hsperfdata
done

#if the above doesn't work try:
#rm -rf /tmp/hsperfdata_mapred/*
