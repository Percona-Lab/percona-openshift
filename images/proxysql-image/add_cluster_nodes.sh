#!/bin/bash 

exec > /tmp/cluster_add.log 2>&1 

# Configs
opt=" -vvv -f "
writer_hostgroup_id="10"
reader_hostgroup_id="20"
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
	echo "Need to pass PEERS variables in the YAML file or set PEERS env variable. Exiting ..."
	exit
fi

ipaddr=$(hostname -i | awk ' { print $1 } ')
IFS=',' read -ra ADDR <<< "$PEERSLIST"     
first_host=${ADDR[0]}

# Wait for MySQL servers...
servers_sql=""
cleanup_sql=""
pxcdetected=$(check_if_pxc ${first_host})
for i in "${ADDR[@]}"
do
        echo "Found host: $i" 
        wait_for_mysql $i
	### Galera checker will add readers
if [[ -z $pxcdetected ]] ; then
        servers_sql="$servers_sql\nREPLACE INTO mysql_servers (hostgroup_id, hostname, port) VALUES ($reader_hostgroup_id, '$i', $_MYSQL_PORT);"
	MYSQL_PWD=$MYSQL_ROOT_PASSWORD mysql $opt -h $i -uroot -e "GRANT USAGE ON *.* TO '$MYSQL_PROXY_USER'@'$ipaddr' IDENTIFIED BY '$MYSQL_PROXY_PASSWORD';"
fi
done

# Add proxy user to PXC
if [[ ! -z $pxcdetected ]] ; then
  MYSQL_PWD=$MYSQL_ROOT_PASSWORD mysql $opt -h $first_host -uroot -e "GRANT USAGE ON *.* TO '$MYSQL_PROXY_USER'@'$ipaddr' IDENTIFIED BY '$MYSQL_PROXY_PASSWORD';GRANT PROCESS ON *.* TO 'clustercheckuser'@'localhost' IDENTIFIED BY 'clustercheckpassword\!';"
fi

# Now prepare sql for proxysql
cleanup_sql="DELETE FROM mysql_servers;"
servers_sql="REPLACE INTO mysql_servers (hostgroup_id, hostname, port) VALUES ($writer_hostgroup_id, '$first_host', $_MYSQL_PORT);$servers_sql"

custom_scheduler=""

# for PXC we deploy a custom scheduler
if [[ ! -z $pxcdetected ]] ; then
  custom_scheduler="REPLACE INTO scheduler(id,active,interval_ms,filename,arg1,arg2,arg3,arg4,arg5) VALUES (1,'1','10000','/usr/bin/proxysql_galera_checker','$writer_hostgroup_id','$reader_hostgroup_id','1','1', '/var/lib/proxysql/proxysql_galera_checker.log');"
fi

servers_sql="$servers_sql\nLOAD MYSQL SERVERS TO RUNTIME; SAVE MYSQL SERVERS TO DISK;"

users_sql="
REPLACE INTO mysql_users (username, password, active, default_hostgroup, max_connections) VALUES ('root', '$_MYSQL_ROOT_PASSWORD', 1, $writer_hostgroup_id, 200);
REPLACE INTO mysql_users (username, password, active, default_hostgroup, max_connections) VALUES ('$MYSQL_PROXY_USER', '$MYSQL_PROXY_PASSWORD', 1, $writer_hostgroup_id, 200);
LOAD MYSQL USERS TO RUNTIME; SAVE MYSQL USERS TO DISK;
"

scheduler_sql="
UPDATE global_variables SET variable_value='$MYSQL_PROXY_USER' WHERE variable_name='mysql-monitor_username'; 
UPDATE global_variables SET variable_value='$MYSQL_PROXY_PASSWORD' WHERE variable_name='mysql-monitor_password';
LOAD MYSQL VARIABLES TO RUNTIME;SAVE MYSQL VARIABLES TO DISK;
$custom_scheduler
LOAD SCHEDULER TO RUNTIME; SAVE SCHEDULER TO DISK;
"

rw_split_sql="
UPDATE mysql_users SET default_hostgroup=$writer_hostgroup_id; 
LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK; 
REPLACE INTO mysql_query_rules (rule_id,active,match_digest,destination_hostgroup,apply)
VALUES
(1,1,'^SELECT.*FOR UPDATE$',10,1),
(2,1,'^SELECT',20,1);
LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;
"

#echo $servers_sql, $users_sql, $scheduler_sql, $rw_split_sql
wait_for_proxy

MYSQL_PWD=$_PROXY_ADMIN_PASSWORD mysql $opt -h127.0.0.1 -P$_PROXY_ADMIN_PORT -u$_PROXY_ADMIN_USER -e "$cleanup_sql $servers_sql $users_sql $scheduler_sql $rw_split_sql"

echo "All done!"
