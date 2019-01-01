#!/bin/bash
# expect NODE_NAME to take backup

set -o errexit
set -o xtrace

BACKUP_DIR=${BACKUP_DIR:-/backup/$NODE_NAME-$(date +%F-%H-%M)}
mkdir -p "$BACKUP_DIR"
cd "$BACKUP_DIR" || exit

echo "Backup to $BACKUP_DIR started"
ncat --recv-only "$NODE_NAME" 3307  > xtrabackup.stream
echo "Backup finished"

stat xtrabackup.stream
md5sum xtrabackup.stream | tee md5sum.txt
