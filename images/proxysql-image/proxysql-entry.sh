#!/bin/bash

set -o xtrace

function mysql_root_exec() {
  local server="$1"
  local query="$2"
  MYSQL_PWD=${MYSQL_ROOT_PASSWORD:-password} timeout 600 mysql -h${server} -uroot -s -NB -e "${query}"
}

function wait_for_mysql() {
    local h="$1"
    echo "Waiting for host $h to be online..."
    while [ "$(mysql_root_exec $h 'select 1')" != "1" ]
    do
        echo "MySQL is not up yet... sleeping ..."
        sleep 1
    done
}

sed -i "s/\"admin:admin\"/\"${PROXY_ADMIN_USER:-admin}:$PROXY_ADMIN_PASSWORD\"/g"       /etc/proxysql/proxysql.cnf
sed -i "s/cluster_username=\"admin\"/cluster_username=\"${PROXY_ADMIN_USER:-admin}\"/g" /etc/proxysql/proxysql.cnf
sed -i "s/cluster_password=\"admin\"/cluster_password=\"$PROXY_ADMIN_PASSWORD\"/g"      /etc/proxysql/proxysql.cnf
sed "s/PROXYSQL_USERNAME='admin'/PROXYSQL_USERNAME='${PROXY_ADMIN_USER:-admin}'/g" /etc/proxysql-admin.cnf 1<> /etc/proxysql-admin.cnf
sed "s/PROXYSQL_PASSWORD='admin'/PROXYSQL_PASSWORD='$PROXY_ADMIN_PASSWORD'/g"      /etc/proxysql-admin.cnf 1<> /etc/proxysql-admin.cnf
sed "s/CLUSTER_USERNAME='admin'/CLUSTER_USERNAME='root'/g"                         /etc/proxysql-admin.cnf 1<> /etc/proxysql-admin.cnf
sed "s/CLUSTER_PASSWORD='admin'/CLUSTER_PASSWORD='$MYSQL_ROOT_PASSWORD'/g"         /etc/proxysql-admin.cnf 1<> /etc/proxysql-admin.cnf
sed "s/MONITOR_USERNAME='monitor'/MONITOR_USERNAME='monitor'/g"                    /etc/proxysql-admin.cnf 1<> /etc/proxysql-admin.cnf
sed "s/MONITOR_PASSWORD='monitor'/MONITOR_PASSWORD='$MONITOR_PASSWORD'/g"          /etc/proxysql-admin.cnf 1<> /etc/proxysql-admin.cnf

## SSL/TLS support
CA=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
if [ -f /var/run/secrets/kubernetes.io/serviceaccount/service-ca.crt ]; then
    CA=/var/run/secrets/kubernetes.io/serviceaccount/service-ca.crt
fi
if [ -f /etc/proxysql/ssl/ca.crt ]; then
    CA=/etc/proxysql/ssl/ca.crt
fi
KEY=/etc/proxysql/ssl/tls.key
CERT=/etc/proxysql/ssl/tls.crt
if [ -f $CA -a -f $KEY -a -f $CERT ]; then
    wait_for_mysql "$PXC_SERVICE"
    cipher=$(mysql_root_exec "$PXC_SERVICE" 'SHOW SESSION STATUS LIKE "Ssl_cipher"' | awk '{print$2}')

    sed -i "s^have_ssl=false^have_ssl=true^"                   /etc/proxysql/proxysql.cnf
    sed -i "s^ssl_p2s_ca=\"\"^ssl_p2s_ca=\"$CA\"^"             /etc/proxysql/proxysql.cnf
    sed -i "s^ssl_p2s_ca=\"\"^ssl_p2s_ca=\"$CA\"^"             /etc/proxysql/proxysql.cnf
    sed -i "s^ssl_p2s_key=\"\"^ssl_p2s_key=\"$KEY\"^"          /etc/proxysql/proxysql.cnf
    sed -i "s^ssl_p2s_cert=\"\"^ssl_p2s_cert=\"$CERT\"^"       /etc/proxysql/proxysql.cnf
    sed -i "s^ssl_p2s_cipher=\"\"^ssl_p2s_cipher=\"$cipher\"^" /etc/proxysql/proxysql.cnf
fi

exec "$@"
