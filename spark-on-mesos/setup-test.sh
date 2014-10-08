#!/bin/bash

echo "I love racelab" > /tmp/file0
hadoop fs -mkdir -p /user/foo/data
hadoop fs -put /tmp/file0 /user/foo/data