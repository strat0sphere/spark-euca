#/bin/bash

#Create spark-submit command
echo '#!/bin/bash' >> /usr/bin/spark-submit
echo 'exec /root/spark/bin/spark-submit "$@"' >> /usr/bin/spark-submit

chmod 755 /usr/bin/spark-submit