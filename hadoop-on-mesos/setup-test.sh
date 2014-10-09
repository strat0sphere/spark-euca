#!/bin/bash

su mapred
echo "I love racelab" > /tmp/file0
echo "Do you love racelab?" > /tmp/file1
hadoop fs -mkdir -p /user/foo/data
hadoop fs -put /tmp/file? /user/foo/data

su root