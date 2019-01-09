#!/bin/bash
set -x

_PROXY_ADMIN_USER="${PROXY_ADMIN_USER:-admin}"
_PROXY_ADMIN_PASSWORD=$(echo "${PROXY_ADMIN_PASSWORD:-admin}" | tr -cd '[:print:]')
_PROXY_ADMIN_PORT="${PROXY_ADMIN_PORT:-6032}"

sed -i "s/admin:admin/$_PROXY_ADMIN_USER:$_PROXY_ADMIN_PASSWORD/g" /etc/proxysql/proxysql.cnf &>>/tmp/sed
sed -i "s/0.0.0.0:6032/0.0.0.0:$_PROXY_ADMIN_PORT/g" /etc/proxysql/proxysql.cnf &>>/tmp/sed
sed "s/PROXYSQL_USERNAME='admin'/PROXYSQL_USERNAME='$_PROXY_ADMIN_USER'/g" /etc/proxysql-admin.cnf 1<> /etc/proxysql-admin.cnf
sed "s/PROXYSQL_PASSWORD='admin'/PROXYSQL_PASSWORD='$_PROXY_ADMIN_PASSWORD'/g" /etc/proxysql-admin.cnf 1<> /etc/proxysql-admin.cnf 
sed "s/CLUSTER_USERNAME='admin'/CLUSTER_USERNAME='root'/g" /etc/proxysql-admin.cnf 1<> /etc/proxysql-admin.cnf
sed "s/CLUSTER_PASSWORD='admin'/CLUSTER_PASSWORD='$MYSQL_ROOT_PASSWORD'/g" /etc/proxysql-admin.cnf 1<> /etc/proxysql-admin.cnf

#cp /etc/proxysql.cnf /tmp

function add_peers {
 /usr/bin/peer-list -on-start="/usr/bin/add_cluster_nodes.sh" -service="$PXCSERVICE"
# TODO: for replicaset we need to use "-on-change" 
}

add_peers &

exec /usr/bin/proxysql -f -c /etc/proxysql/proxysql.cnf
