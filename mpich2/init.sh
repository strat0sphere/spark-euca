#~/bin/bash

pushd /root

echo "Downloading mpich2..."
wget http://www.mpich.org/static/downloads/1.2/mpich2-1.2.tar.gz
tar xvfz mpich2-1.2.tar.gz
rm mpich2-1.2.tar.gz

cd /root/mpich2-1.2/

echo "Configuring mpich2..."
./configure --prefix=/root/mpich2-install 2>&1 | tee c.txt
make 2>&1 | tee m.txt
make install 2>&1 | tee mi.txt

#Also put this on /etc/environment
sed -i '/^PATH=/s/$/:\/root\/mpich2-install\/bin/'
PATH=/root/mpich2-install/bin:$PATH ; export PATH

#-> Create mpd conf file in home directory:
echo "secretword=nil" > /etc/mpd.conf
chmod 600 /etc/mpd.conf

popd /root



