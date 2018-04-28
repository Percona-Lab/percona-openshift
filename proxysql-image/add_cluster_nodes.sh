#!/bin/bash

exec > /tmp/cluster_add.log 2>&1 

# Configs
opt=" -vvv -f "
default_hostgroup_id="10"
reader_hostgroup_id="20"
TIMEOUT="10" # 10 sec timeout to wait for server

# Remote exec hack
if [ "$1" == "remote" ]
then
        remote="oc rsh proxysql-0"
else
        remote=""
fi


# Functions

function mysql_root_exec() {
  local server="$1"
  local query="$2"
  printf "%s\n" \
      "[client]" \
      "user=root" \
      "password=${MYSQL_ROOT_PASSWORD}" \
      "host=${server}" \
      | timeout $TIMEOUT $remote mysql --defaults-file=/dev/stdin --protocol=tcp -s -NB -e "${query}"
}

function wait_for_mysql() {
	local h=$1
	echo "Waiting for host $h to be online..."
	while [ "$(mysql_root_exec $h 'select 1')" != "1" ]
	do
		echo "MySQL is not up yet... sleeping ..."
		sleep 1
	done
}

function wait_for_proxy() {
	local h=127.0.0.1
	echo "Waiting for host $h to be online..."
	while [ "$(MYSQL_PWD=admin mysql -h$h -P6032 -uadmin -s -NB -e 'select 1')" != "1" ]
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

ipaddr=$($remote hostname -i | awk ' { print $1 } ')
IFS=',' read -ra ADDR <<< "$PEERSLIST"     
first_host=${ADDR[0]}

MYSQL_PWD=$MYSQL_ROOT_PASSWORD mysql $opt -h $first_host -uroot -e "GRANT ALL ON *.* TO '$MYSQL_PROXY_USER'@'$ipaddr' IDENTIFIED BY '$MYSQL_PROXY_PASSWORD';GRANT PROCESS ON *.* TO 'clustercheckuser'@'localhost' IDENTIFIED BY 'clustercheckpassword\!';"

# Now prepare sql for proxysql

cleanup_sql=""
servers_sql="REPLACE INTO mysql_servers (hostgroup_id, hostname, port) VALUES ($default_hostgroup_id, '$first_host', 3306);"

for i in "${ADDR[@]}"
do
        echo "Found host: $i" 
	wait_for_mysql $i
        servers_sql="$servers_sql\nREPLACE INTO mysql_servers (hostgroup_id, hostname, port) VALUES ($reader_hostgroup_id, '$i', 3306);"
done

servers_sql="$servers_sql\nLOAD MYSQL SERVERS TO RUNTIME; SAVE MYSQL SERVERS TO DISK;"

users_sql="
REPLACE INTO mysql_users (username, password, active, default_hostgroup, max_connections) VALUES ('root', '$MYSQL_ROOT_PASSWORD', 1, $default_hostgroup_id, 200);
REPLACE INTO mysql_users (username, password, active, default_hostgroup, max_connections) VALUES ('$MYSQL_PROXY_USER', '$MYSQL_PROXY_PASSWORD', 1, $default_hostgroup_id, 200);
LOAD MYSQL USERS TO RUNTIME; SAVE MYSQL USERS TO DISK;
"

scheduler_sql="
UPDATE global_variables SET variable_value='$MYSQL_PROXY_USER' WHERE variable_name='mysql-monitor_username'; 
UPDATE global_variables SET variable_value='$MYSQL_PROXY_PASSWORD' WHERE variable_name='mysql-monitor_password';
LOAD MYSQL VARIABLES TO RUNTIME;SAVE MYSQL VARIABLES TO DISK;
REPLACE INTO scheduler(id,active,interval_ms,filename,arg1,arg2,arg3,arg4,arg5) VALUES (1,'1','3000','/usr/bin/proxysql_galera_checker','$default_hostgroup_id','$reader_hostgroup_id','1','1', '/var/lib/proxysql/proxysql_galera_checker.log'); 
LOAD SCHEDULER TO RUNTIME; SAVE SCHEDULER TO DISK;
"

rw_split_sql="
UPDATE mysql_users SET default_hostgroup=$default_hostgroup_id; 
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

mysql $opt -h127.0.0.1 -P6032 -uadmin -padmin -e "$cleanup_sql $servers_sql $users_sql $scheduler_sql $rw_split_sql"

echo "All done!"
