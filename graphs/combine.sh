#!/bin/bash

if [ -z $1 ]; then
  echo "usage: $(basename $0) <result_dir>"
  exit 1
fi

dir=$1
if ! [ -d $dir ]; then
  echo "$dir not a directory"
  exit 1
fi

re='(.*)_(.*).json'
for file in $dir/*.json ; do
  name=$(basename $file)
  [[ $name =~ $re ]]
  setup=${BASH_REMATCH[1]}
  test=${BASH_REMATCH[2]}
  if ! cat $file | jq '{ test: "'$test'", setup: "'$setup'", jobs: .jobs }'; then
    echo $name >&2
  fi
done | jq -s .



