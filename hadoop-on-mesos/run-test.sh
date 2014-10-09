#/bin/bash

hadoop jar /usr/lib/hadoop-0.20-mapreduce/hadoop-examples-2.3.0-mr1-cdh5.1.2.jar wordcount /user/foo/data /user/foo/out
hadoop fs -ls /user/foo/out
hadoop fs -cat /user/foo/out/part*