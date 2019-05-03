#!/bin/bash

set -o errexit
set -o xtrace

mc -C /tmp/mc config host add dest "${AWS_ENDPOINT_URL:-https://s3.amazonaws.com}" "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY"
mc -C /tmp/mc ls dest/${S3_BUCKET_URL}
rm -rf /datadir/*
mc -C /tmp/mc cat dest/${S3_BUCKET_URL} | xbstream -x -C /datadir
xtrabackup --prepare --target-dir=/datadir ${XB_USE_MEMORY+--use-memory=$XB_USE_MEMORY}
