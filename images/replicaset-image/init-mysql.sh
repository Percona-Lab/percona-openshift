#!/bin/bash
set -ex

# Generate mysql server-id from pod ordinal index.
[[ `hostname` =~ -([0-9]+)$ ]] || exit 1
ordinal=${BASH_REMATCH[1]}
echo [mysqld] > /etc/mysql/conf.d/server-id.cnf

# Add an offset to avoid reserved server-id=0 value.
echo server-id=$((100 + $ordinal)) >> /etc/mysql/conf.d/server-id.cnf
DIR=/mnt/config-map

# copy all extra cnf files
shopt -s nullglob
if [ -d "$DIR" ]; then
  for i in $DIR/*.cnf
  do
    cp $i /etc/mysql/conf.d/
  done
fi
