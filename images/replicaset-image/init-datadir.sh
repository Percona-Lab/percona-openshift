#!/bin/bash
set -ex
if [ ! -z "$MYSQL_INIT_DATADIR" ]; then
   echo "Cleaning up /var/lib/mysql"
   rm -fr /var/lib/mysql/*
fi
# Skip the clone if data already exists.
[[ -d /var/lib/mysql/mysql ]] && exit 0
# Skip the clone on master (ordinal index 0).
[[ `hostname` =~ ^(.*?)-([0-9]+)$ ]] || exit 1
ordinal=${BASH_REMATCH[2]}
rsname=${BASH_REMATCH[1]}
servicename=$(hostname -f | cut -d"." -f2)
echo "Detected name: $rsname $servicename"
[[ $ordinal -eq 0 ]] && exit 0
# Clone data from previous peer.
ncat --recv-only ${rsname}-$(($ordinal-1)).${servicename} 3307 | xbstream -x -C /var/lib/mysql
# Prepare the backup.
xtrabackup --prepare --target-dir=/var/lib/mysql
ls -lah /var/lib/mysql
