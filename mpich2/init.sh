#~/bin/bash

wget http://www.mpich.org/static/downloads/1.2/mpich2-1.2.tar.gz
tar xvfz mpich2-1.2.tar.gz
rm mpich2-1.2.tar.gz
cd mpich2-1.2/

./configure --prefix=/root/mpich2-install 2>&1 | tee c.txt
make 2>&1 | tee m.txt
make install 2>&1 | tee mi.txt

#Also put this on /etc/environment
PATH=/root/mpich2-install/bin:$PATH ; export PATH

#-> Create .mpd conf file in home directory:
echo "secretword=nil" > /etc/mpd.conf
chmod 600 /etc/mpd.conf

#Copy /mpich2-install to all machines
/root/spark-euca/copy-dir /root/mpich2-install


