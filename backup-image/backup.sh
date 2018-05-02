#!/bin/bash
# expect NODE_NAME to take backup

backupdir=${NODE_NAME}-`date +%F-%H-%M`
mkdir -p /backup/$backupdir
echo "Backup to $backupdir started"
ncat --recv-only $NODE_NAME 3307  > /backup/$backupdir/xtrabackup.stream
echo "Backup finished"

