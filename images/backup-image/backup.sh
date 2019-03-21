#!/bin/bash

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
    if [ $(stat -c%s xtrabackup.stream) = 0 ]; then
        exit 1
    fi
    md5sum xtrabackup.stream | tee md5sum.txt
}

function backup_s3() {
    AWS_S3_BUCKET_PATH=${AWS_S3_BUCKET_PATH:-$NODE_NAME-$(date +%F-%H-%M)-xtrabackup.stream}

    echo "Backup to s3://$AWS_S3_BUCKET/$AWS_S3_BUCKET_PATH started"
    mc -C /tmp/mc config host add dest "${AWS_ENDPOINT_URL:-https://s3.amazonaws.com}" "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY"
    ncat --recv-only "$NODE_NAME" 3307 \
        | mc -C /tmp/mc pipe "dest/$AWS_S3_BUCKET/$AWS_S3_BUCKET_PATH"
    echo "Backup finished"

    mc -C /tmp/mc stat "dest/$AWS_S3_BUCKET/$AWS_S3_BUCKET_PATH"
    s3_size=$(mc -C /tmp/mc stat "dest/$AWS_S3_BUCKET/$AWS_S3_BUCKET_PATH" | grep "^Size" | awk '{print$3}')
    if [ $s3_size = "0B" ]; then
        exit 1
    fi
}

if [ -n "$AWS_S3_BUCKET" ]; then
    backup_s3
else
    backup_volume
fi
