#!/bin/bash
set -e

SCRIPT_DIR=$(dirname $(readlink -f $0))

JOB_DIR=$SCRIPT_DIR/../tests
RESULT_DIR=$SCRIPT_DIR/../host_results
MOUNT_DIR=/mnt/testVolume

GLUSTER_IPS=(
  141.52.214.24
  141.52.214.25
  141.52.214.26
)

# runtime per tests
RUNTIME=900

#DELETE_VOLUMES=1

mkdir -p $JOB_DIR $RESULT_DIR $MOUNT_DIR

# cleanup
# sudo gluster volume info | awk '/Volume Name:/ { print $3 }' | xargs -L1 -i sudo bash -c 'yes | gluster volume stop {} && yes | gluster volume delete {}'

function echoBricks {
  local i s
  for i in $(seq $1); do
    for s in "${!GLUSTER_IPS[@]}" ; do
      echo -n "$s:/rhgs/brick$i/$2 "
    done
  done
  echo
}


function run {
  name=$1
  
  if ! gluster volume start $name ; then 
    echo "Volume $name could not be started"
    return 1
  fi
  if ! mount -t glusterfs localhost:/$name $MOUNT_DIR ; then 
    echo "Volume $name could not be mounted"
    return 1
  fi
  
  for jobfile in $JOB_DIR/*.job ; do
    job=$(basename -s .job $jobfile)
    echo "Running $job on $name"

    # setup env
    export JOB=$job
    export DIR=$MOUNT_DIR/fio-tests/$job
    export VOL=$name
    export RUNTIME=$RUNTIME
    
    rm -rf $DIR
    mkdir -p $DIR
    
    # flush cache
    echo 3 > /proc/sys/vm/drop_caches

    fio --output $RESULT_DIR/${name}_${job}.json --output-format=json $jobfile

    sync
    sleep 1
  done
  
  umount $MOUNT_DIR
  yes | gluster volume stop $name
  if [ "$DELETE_VOLUMES" == "1" ]; then
    yes | gluster volume delete $name
  fi
}

function createVolume {
  name=$1; shift
  optionsFile=$2; shift

  if gluster volume show $name >/dev/null; then
    echo "Volume $name already exists"
    return 0
  fi

  echo "Creating Volume $name"
  return gluster volume create $name $@ force && \
         cat $optionsFile | xargs -L1 gluster volume set $name
}
  


for i in {1,2,3,4} ; do
  createVolume test_disperse_$i $SCIPRT_DIR/gluster-opts-all disperse-data 4 redundancy 2 $(echoBricks $i bd$i) && \
  run test_disperse_$i || true
 
  createVolume test_replica_$i $SCIPRT_DIR/gluster-opts-all replica 3 $(echoBricks $i br$i) && \
  run test_replica_$i || true
  
  createVolume test_replica_opt_$i $SCIPRT_DIR/gluster-opts-optimized replica 3 $(echoBricks $i bo$i) && \
  run test_replica_opt_$i || true
  
  createVolume test_disperse_opt_$i $SCIPRT_DIR/gluster-opts-optimized disperse-data 4 redundancy 2 $(echoBricks $i bdo$i) && \
  run test_disperse_opt_$i || true
done

