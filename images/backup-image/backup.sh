#!/bin/bash
# expect NODE_NAME to take backup

set -o errexit
set -o xtrace

function backup_volume() {
    BACKUP_DIR=${BACKUP_DIR:-/backup/$NODE_NAME-$(date +%F-%H-%M)}
    mkdir -p "$BACKUP_DIR"
    cd "$BACKUP_DIR" || exit

    echo "Backup to $BACKUP_DIR started"
    ncat --recv-only "$NODE_NAME" 3307 \
        > xtrabackup.stream
    echo "Backup finished"

    stat xtrabackup.stream
    md5sum xtrabackup.stream | tee md5sum.txt
}

function backup_s3() {
    ARGS=()
    if [ -n "$AWS_ENDPOINT_URL" ]; then
        ARRAY+=('--endpoint', "$AWS_ENDPOINT_URL")
    fi
    echo "Backup to $AWS_S3_BUCKET/$AWS_S3_BUCKET_PATH started"
    ncat --recv-only "$NODE_NAME" 3307 \
        | gof3r put --bucket "$AWS_S3_BUCKET" ${ARRAY[@]} --key $AWS_S3_BUCKET_PATH/$NODE_NAME-$(date +%F-%H-%M)-xtrabackup.stream
    echo "Backup finished"
}

if [ -n "$AWS_S3_BUCKET" ]; then
    backup_s3
else
    backup_volume
fi
