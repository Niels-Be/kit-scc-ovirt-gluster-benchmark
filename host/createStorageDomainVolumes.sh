#!/bin/bash
set -e

SCRIPT_DIR=$(dirname $(readlink -f $0))


GLUSTER_IPS=(
  141.52.214.24
  141.52.214.25
  141.52.214.26
)


function echoBricks {
  local i s
  for i in $(seq $1); do
    for s in "${!GLUSTER_IPS[@]}" ; do
      echo -n "$s:/rhgs/brick$i/$2 "
    done
  done
  echo
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


createVolume rhv_data $SCIPRT_DIR/gluster-opts-optimized replica 3 $(echoBricks 4 rhv_data)
gluster volume start rhv_data

createVolume rhv_iso $SCIPRT_DIR/gluster-opts-optimized replica 3 $(echoBricks 4 rhv_iso)
gluster volume start rhv_iso

createVolume rhv_export $SCIPRT_DIR/gluster-opts-optimized replica 3 $(echoBricks 4 rhv_export)
gluster volume start rhv_export
