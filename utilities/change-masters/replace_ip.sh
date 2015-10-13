#!/bin/bash

#usage: replace_ip.sj 10.1.1.1 10.2.2.2. /etc
cd $3

find . -type f -exec sed -i 's/'$1'/'$2'/g' {} +
#find . -type f -exec sed -i 's/euca-10.2.31.179/euca-10-2-31-179/g' {} +
#find . -type f -exec sed -i 's/128.111.179.170/128.111.179.159/g' {} +
#find . -type f -exec sed -i 's/128-111-179-170/128-111-179-159/g' {} +
#find . -type f -exec sed -i 's/10.2.31.189/10.2.31.179/g' {} +
#find . -type f -exec sed -i 's/10-2-31-189/10-2-31-179/g' {} +
