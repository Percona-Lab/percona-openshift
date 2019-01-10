#!/bin/bash
set -x
exec > /tmp/cluster_add.log 2>&1

# Configs
opt=" -vvv -f "
TIMEOUT="600" # X sec timeout, to wait for server
_MYSQL_PORT="3306"
_PROXY_ADMIN_USER="${PROXY_ADMIN_USER:-admin}"
_PROXY_ADMIN_PASSWORD="${PROXY_ADMIN_PASSWORD:-admin}"
_PROXY_ADMIN_PORT="${PROXY_ADMIN_PORT:-6032}"
_MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-root_password}"

# Functions

function _echo() {
	echo $1 | tee -a /tmp/add_nodes.log
}

function mysql_root_exec() {
  local server="$1"
  local query="$2"
  printf "%s\n" \
      "[client]" \
      "user=root" \
      "password=${_MYSQL_ROOT_PASSWORD}" \
      "host=${server}" \
      | timeout $TIMEOUT mysql --defaults-file=/dev/stdin --protocol=tcp -s -NB -e "${query}"
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

function check_if_pxc() {
	local h=$1
	echo $(mysql_root_exec $h "SHOW GLOBAL STATUS LIKE 'wsrep_connected'")
}

function wait_for_proxy() {
	local h=127.0.0.1
	echo "Waiting for host $h to be online..."
	while [ "$(MYSQL_PWD=$_PROXY_ADMIN_PASSWORD mysql -h$h -P$_PROXY_ADMIN_PORT -u$_PROXY_ADMIN_USER -s -NB -e 'select 1')" != "1" ]
	do
		echo "ProxySQL is not up yet... sleeping ..."
		sleep 1
	done
}

echo "Running $0"

while read -ra LINE; do
    if [[ "${LINE}" == *"${HOSTNAME}"* ]]; then
        MY_NAME=$LINE
    fi
    echo "Read line $LINE"
    IP=$(getent hosts $LINE | awk '{ print $1 }')
    PEERS=("${PEERS[@]}" $IP)
done

PEERSLIST=$(IFS=, ; echo "${PEERS[*]}")

echo "Read PEERS $PEERSLIST "

# Check that PEERS are set
if [ "$PEERS" == "" ]
then
	echo "Could not find PEERS ..."
	exit
fi

ipaddr=$(hostname -i | awk ' { print $1 } ')
IFS=',' read -ra ADDR <<< "$PEERSLIST"
first_host=${ADDR[0]}

# Wait for MySQL servers...
for i in "${ADDR[@]}"
do
        echo "Found host: $i"
        wait_for_mysql $i
done

wait_for_proxy

proxysql-admin --config-file=/etc/proxysql-admin.cnf --disable --use-existing-monitor-password --proxysql-username=$_PROXY_ADMIN_USER --proxysql-password=$_PROXY_ADMIN_PASSWORD --proxysql-port=$_PROXY_ADMIN_PORT --proxysql-hostname=127.0.0.1 --cluster-username=root --cluster-password=$_MYSQL_ROOT_PASSWORD --cluster-hostname=$first_host  --cluster-port=3306 --cluster-app-username=$MYSQL_PROXY_USER --cluster-app-password=$MYSQL_PROXY_PASSWORD --monitor-username=monitor --monitor-password=$MONITOR_PASSWORD --mode=singlewrite
proxysql-admin --config-file=/etc/proxysql-admin.cnf --enable --use-existing-monitor-password --proxysql-username=$_PROXY_ADMIN_USER --proxysql-password=$_PROXY_ADMIN_PASSWORD --proxysql-port=$_PROXY_ADMIN_PORT --proxysql-hostname=127.0.0.1 --cluster-username=root --cluster-password=$_MYSQL_ROOT_PASSWORD --cluster-hostname=$first_host  --cluster-port=3306 --cluster-app-username=$MYSQL_PROXY_USER --cluster-app-password=$MYSQL_PROXY_PASSWORD --monitor-username=monitor --monitor-password=$MONITOR_PASSWORD --mode=singlewrite
proxysql-admin --config-file=/etc/proxysql-admin.cnf --use-existing-monitor-password --proxysql-username=$_PROXY_ADMIN_USER --proxysql-password=$_PROXY_ADMIN_PASSWORD --proxysql-port=$_PROXY_ADMIN_PORT --proxysql-hostname=127.0.0.1 --cluster-username=root --cluster-password=$_MYSQL_ROOT_PASSWORD --cluster-hostname=$first_host  --cluster-port=3306 --cluster-app-username=$MYSQL_PROXY_USER --cluster-app-password=$MYSQL_PROXY_PASSWORD --monitor-username=monitor --monitor-password=$MONITOR_PASSWORD --syncusers
echo "All done!"
