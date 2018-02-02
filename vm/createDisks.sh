#!/bin/bash
set -e

DISKS=($(echo /dev/sd{b,c,d,e,f,g,h,i,j,k,l,m}))
NAMES=(
test_disperse_2
test_disperse_4
test_disperse_opt_2
test_disperse_opt_4
test_replica_1
test_replica_2
test_replica_3
test_replica_4
test_replica_opt_1
test_replica_opt_2
test_replica_opt_3
test_replica_opt_4
)

MOUNT_ROOT=/mnt

for i in "${!DISKS[@]}"; do
  disk=${DISKS[$i]}
  name=${NAMES[$i]}
  echo $i $disk $name
  parted $disk mklabel gpt
  parted $disk mkpart primary xfs "0%" "100%"
  parted $disk name 1 $name
  mkfs -t xfs -f ${disk}1
  mkdir -p $MOUNT_ROOT/$name
  mount ${disk}1 $MOUNT_ROOT/$name
done
