#!/bin/bash

SCRIPT_DIR=$(dirname $(readlink -f $0))

JOB_DIR=$SCRIPT_DIR/../tests
RESULT_DIR=$SCRIPT_DIR/../vm_results
MOUNT_DIR=/mnt

RUNTIME=900

function run {
  dir=$1
  name=$(basename $dir)
  
  for jobfile in $JOB_DIR/*.job ; do
    job=$(basename -s .job $jobfile)
    echo "Running $job on $name"
    # setup env
    export JOB=$job
    export DIR=$dir/fio-tests/$job
    export VOL=$name
    export RUNTIME=$RUNTIME

    rm -rf $DIR
    mkdir -p $DIR

    # flush cache
    echo 3 > /proc/sys/vm/drop_caches
    
    # run
    fio --output $RESULT_DIR/${name}_${job}.json --output-format=json $jobfile
    rm -rf $DIR
    sync
    sleep 1
  done
  
}


mkdir -p $RESULT_DIR
for d in $MOUNT_DIR/* ; do
  run $d
done

