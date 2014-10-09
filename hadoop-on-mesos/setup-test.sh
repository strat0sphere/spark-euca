#!/bin/bash
pushd /root

echo "I love racelab" > /tmp/file0
echo "Do you love racelab?" > /tmp/file1
chown hdfs:hadoop /tmp/file0
chown hdfs:hadoop /tmp/file1

hadoop fs -mkdir -p /user/foo/data
hadoop fs -put /tmp/file? /user/foo/data

popd /root
