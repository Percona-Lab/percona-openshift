#!/bin/bash

sed -i "s/admin:admin/admin:$PROXY_ADMIN_PASSWORD/g"                               /etc/proxysql/proxysql.cnf
sed -i "s/cluster_username=\"admin\"/cluster_username=\"admin\"/g"                 /etc/proxysql/proxysql.cnf
sed -i "s/cluster_password=\"admin\"/cluster_password=\"$PROXY_ADMIN_PASSWORD\"/g" /etc/proxysql/proxysql.cnf
sed "s/PROXYSQL_USERNAME='admin'/PROXYSQL_USERNAME='admin'/g"                      /etc/proxysql-admin.cnf 1<> /etc/proxysql-admin.cnf
sed "s/PROXYSQL_PASSWORD='admin'/PROXYSQL_PASSWORD='$PROXY_ADMIN_PASSWORD'/g"      /etc/proxysql-admin.cnf 1<> /etc/proxysql-admin.cnf
sed "s/CLUSTER_USERNAME='admin'/CLUSTER_USERNAME='root'/g"                         /etc/proxysql-admin.cnf 1<> /etc/proxysql-admin.cnf
sed "s/CLUSTER_PASSWORD='admin'/CLUSTER_PASSWORD='$MYSQL_ROOT_PASSWORD'/g"         /etc/proxysql-admin.cnf 1<> /etc/proxysql-admin.cnf
sed "s/MONITOR_USERNAME='monitor'/MONITOR_USERNAME='monitor'/g"                    /etc/proxysql-admin.cnf 1<> /etc/proxysql-admin.cnf
sed "s/MONITOR_PASSWORD='monitor'/MONITOR_PASSWORD='$MONITOR_PASSWORD'/g"          /etc/proxysql-admin.cnf 1<> /etc/proxysql-admin.cnf

exec "$@"
