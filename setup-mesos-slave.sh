#!/bin/bash

# Make sure we are in the spark-euca directory
cd /root/spark-euca

source ec2-variables.sh

# Set hostname based on EC2 private DNS name, so that it is set correctly
# even if the instance is restarted with a different private DNS name
#PRIVATE_DNS=`wget -q -O - http://instance-data.ec2.internal/latest/meta-data/local-hostname`
#hostname $PRIVATE_DNS
PRIVATE_DNS=hostname
echo $PRIVATE_DNS > /etc/hostname
HOSTNAME=$PRIVATE_DNS  # Fix the bash built-in hostname variable too

echo "Setting up slave on `hostname`..."


# Mount options to use for ext3 and xfs disks (the ephemeral disks
# are ext3, but we use xfs for EBS volumes to format them faster)
XFS_MOUNT_OPTS="defaults,noatime,nodiratime,allocsize=8m"
EXT3_MOUNT_OPTS=""

# Format and mount EBS volume (/dev/vdb) as /vol if the device exists
if [[ -e /dev/vdb ]]; then
    echo "/dev/vdb exists!"
    # Check if /dev/vdb is already formatted
    if ! blkid /dev/vdb; then
        echo "/dev/vdb not formatted - Formatting..."
        mkdir /vol
        if mkfs.ext3 -q /dev/vdb; then
            echo "Mounting /dev/vdb to /vol"
            #mount -o $XFS_MOUNT_OPTS /dev/vdb /vol
            e2label /dev/vdb /attached_vol
            mount -L /attached_vol /vol
            chmod -R a+w /vol
        else
            # mkfs.xfs is not installed on this machine or has failed;
            # delete /vol so that the user doesn't think we successfully
            # mounted the EBS volume
            echo "deleting vol"
            rmdir /vol
        fi
    else
        echo "Volume exists and already formatted"
        # EBS volume is already formatted. Mount it if its not mounted yet.
        if ! grep -qs '/vol' /proc/mounts; then
            echo "Creating /vol and mounting /dev/vdb"
            mkdir /vol
            #mount -o $XFS_MOUNT_OPTS /dev/vdb /vol
            e2label /dev/vdb /attached_vol
            mount -L /attached_vol /vol
            chmod -R a+w /vol
        fi
    fi
fi

# Set up Hadoop and Mesos directories in /mnt
#create_hadoop_dirs /mnt
#mkdir -p /mnt/ephemeral-hdfs/logs
#mkdir -p /mnt/persistent-hdfs/logs
#mkdir -p /mnt/hadoop-logs
#mkdir -p /mnt/mesos-logs
#mkdir -p /mnt/mesos-work

# Make data dirs writable by non-root users, such as CDH's hadoop user
chmod -R a+w /mnt*

# Remove ~/.ssh/known_hosts because it gets polluted as you start/stop many
# clusters (new machines tend to come up under old hostnames)
rm -f /root/.ssh/known_hosts

# Create swap space on /mnt
/root/spark-euca/create-swap.sh $SWAP_MB

# Allow memory to be over committed. Helps in pyspark where we fork
echo 1 > /proc/sys/vm/overcommit_memory

# Add github to known hosts to get git@github.com clone to work
# TODO(shivaram): Avoid duplicate entries ?
cat /root/spark-euca/github.hostkey >> /root/.ssh/known_hosts

