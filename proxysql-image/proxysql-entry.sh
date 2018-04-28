#!/bin/bash

# cleanup dir in case volume mounted from previous instance
rm -fr /var/lib/proxysql/*

/usr/bin/proxysql --initial -f -c /etc/proxysql.cnf 
