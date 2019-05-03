#!/bin/bash

set -o errexit
set -o xtrace

ping -c1 $RESTORE_SRC_SERVICE || :
rm -rf /datadir/*
ncat $RESTORE_SRC_SERVICE 3307 | xbstream -x -C /datadir
xtrabackup --prepare --target-dir=/datadir ${XB_USE_MEMORY+--use-memory=$XB_USE_MEMORY}
