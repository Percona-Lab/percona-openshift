#!/bin/bash 
#
# Script to listen on a slave request and perform xtrabackup copy
#

set -ex
cd /var/lib/mysql

MASTERPOS=""
# Determine binlog position of cloned data, if any.
if [[ -s xtrabackup_slave_info ]]; then
  # XtraBackup already generated a partial "CHANGE MASTER TO" query
  # because we're cloning from an existing slave.
  MASTERPOS=$(cat xtrabackup_slave_info | tr -d ';')
  echo "Read from xtrabackup_slave_info $MASTERPOS"
  rm xtrabackup_slave_info
elif [[ -f xtrabackup_binlog_info ]]; then
  # We're cloning directly from master. Parse binlog position.
  [[ `cat xtrabackup_binlog_info` =~ ^(.*?)[[:space:]]+(.*?)$ ]] || exit 1
  rm xtrabackup_binlog_info
  MASTERPOS="CHANGE MASTER TO MASTER_LOG_FILE='${BASH_REMATCH[1]}',\
        MASTER_LOG_POS=${BASH_REMATCH[2]}"
  echo "Read from xtrabackup_binlog_info $MASTERPOS"
fi

# Check if we need to complete a clone by starting replication.
if [[ ! -z $MASTERPOS ]]; then
  echo "Waiting for mysqld to be ready (accepting connections)"
  until mysql -h 127.0.0.1 -uroot -p$MYSQL_ROOT_PASSWORD -e "SELECT 1"; do sleep 1; done

[[ `hostname` =~ ^(.*?)-([0-9]+)$ ]] || exit 1
ordinal=${BASH_REMATCH[2]}
rsname=${BASH_REMATCH[1]}
servicename=$(hostname -f | cut -d"." -f2)

  echo "Initializing replication from clone position"
  # In case of container restart, attempt this at-most-once.
  MYSQL_PWD=$MYSQL_ROOT_PASSWORD mysql -h 127.0.0.1 -uroot <<EOF
  STOP SLAVE;
  $MASTERPOS,
  MASTER_HOST='${rsname}-0.${servicename}',
  MASTER_USER='root',
  MASTER_PASSWORD='$MYSQL_ROOT_PASSWORD',
  MASTER_CONNECT_RETRY=10;
START SLAVE;
EOF
fi

ncat --listen --keep-open --send-only --max-conns=1 3307 -c \
            "xtrabackup --backup --slave-info --stream=xbstream --host=127.0.0.1 --user=xtrabackup --password=$XTRABACKUP_PASSWORD"
