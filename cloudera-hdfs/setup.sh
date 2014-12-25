echo "deb [arch=amd64] http://archive.cloudera.com/cdh4/ubuntu/precise/amd64/cdh precise-cdh4 contrib
deb-src http://archive.cloudera.com/cdh4/ubuntu/precise/amd64/cdh precise-cdh4 contrib" >> /etc/apt/sources.list.d/cloudera.list
sudo apt-get update; sudo apt-get install hadoop-0.20-mapreduce-jobtracker
sudo apt-get update; sudo apt-get install hadoop-hdfs-namenode