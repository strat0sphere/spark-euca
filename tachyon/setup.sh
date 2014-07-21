#!/bin/bash

/root/spark-euca/copy-dir /root/tachyon

/root/tachyon/bin/tachyon format

sleep 1

/root/tachyon/bin/tachyon-start.sh all Mount
