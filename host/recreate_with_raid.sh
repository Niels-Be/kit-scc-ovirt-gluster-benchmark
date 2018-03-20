#!/bin/bash

# read and modify this file carefully before executing
exit 1

# stop any running vms before stoping any volumes

# tair down everything and setup raid5
# backup rhv-* voulmes inorder to restore them afterwards
# ensure to preserve file permissions

# clear gluster
gluster volume list | xargs -L1 -i bash -c "yes | gluster volume stop {}"
gluster volume list | xargs -L1 -i bash -c "yes | gluster volume delete {}"

systemctl stop glusterd.service

# remove mounts
umount /rhev/data-center/mnt/glusterSD/*
umount /rhgs/brick*

# clear vgs
yes y | vgremove vg{1,2,3,4}

# create partitions
for i in {b,c,d,e} ; do
    parted /dev/sd$i mklabel gpt
    parted /dev/sd$i mkpart primary 0% 50%
    parted /dev/sd$i mkpart primary 50% 100%
done

# create raid 5
mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3 /dev/sdb1 /dev/sdc1 /dev/sdd1 --spare-devices=1 /dev/sde1
mdadm --create --verbose /dev/md1 --level=5 --raid-devices=3 /dev/sdb2 /dev/sdc2 /dev/sdd2 --spare-devices=1 /dev/sde2

# use md1 for new gluster
mkfs.xfs /dev/md1
mkdir /rhgs/brickR
mount /dev/md1 /rhgs/brickR


systemctl start glusterd.service

# recreate volumes
gluster volume create rhv-data replica 3 141.52.214.24:/rhgs/brickR/rhv-data 141.52.214.25:/rhgs/brickR/rhv-data 141.52.214.26:/rhgs/brickR/rhv-data
gluster volume create rhv-export replica 3 141.52.214.24:/rhgs/brickR/rhv-export 141.52.214.25:/rhgs/brickR/rhv-export 141.52.214.26:/rhgs/brickR/rhv-export
gluster volume create rhv-iso replica 3 141.52.214.24:/rhgs/brickR/rhv-iso 141.52.214.25:/rhgs/brickR/rhv-iso 141.52.214.26:/rhgs/brickR/rhv-iso

gluster volume start rhv-data
gluster volume start rhv-export
gluster volume start rhv-iso

# restore backup

# note before running any benchmarks wait for RAID synchronization to compleate
# check: cat /proc/mdstat
