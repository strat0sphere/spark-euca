#bin/bash

/root/spark/bin/spark-submit --class WordCount3 --master mesos://zk://$ACTIVE_MASTER_PRIVATE/mesos ~/test-code/simple-project_2.10-1.0.jar $ACTIVE_MASTER_PRIVATE