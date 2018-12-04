#! /bin/bash

# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script writes out a mysql galera config using a list of newline seperated
# peer DNS names it accepts through stdin.

# /etc/mysql is assumed to be a shared volume so we can modify my.cnf as required
# to keep the config up to date, without wrapping mysqld in a custom pid1.
# The config location is intentionally not /etc/mysql/my.cnf because the
# standard base image clobbers that location.
CFG=/etc/mysql/node.cnf

function join {
    local IFS="$1"; shift; echo "$*";
}

HOSTNAME=$(hostname)
IPADDR=$(hostname -i)
# Parse out cluster name, from service name:
CLUSTER_NAME="$(hostname -f | cut -d'.' -f2)"

[[ `hostname` =~ ^(.*)-([0-9]+)$ ]] || exit 1
ordinal=${BASH_REMATCH[2]}
rsname=${BASH_REMATCH[1]}

while read -ra LINE; do
    if [[ "${LINE}" == *"${HOSTNAME}"* ]]; then
        MY_NAME=$LINE
        continue
    fi
    echo "read line $LINE, cluster name: $CLUSTER_NAME"
    if [[ $LINE =~ ^([^.]*)-([0-9]+) ]]; then
    if [[ "$rsname" == "${BASH_REMATCH[1]}" ]] ; then
      PEERS=("${PEERS[@]}" $LINE)
    fi
    fi
done

if [ "${#PEERS[@]}" = 0 ]; then
    WSREP_CLUSTER_ADDRESS=""
else
    WSREP_CLUSTER_ADDRESS=$(join , "${PEERS[@]}")
fi
echo $WSREP_CLUSTER_ADDRESS > /tmp/cluster_addr.txt

#--wsrep_cluster_name=$CLUSTER_NAME --wsrep_cluster_address="gcomm://$cluster_join" --wsrep_sst_method=xtrabackup-v2 --wsrep_sst_auth="xtrabackup:$XTRABACKUP_PASSWORD" --wsrep_node_address="$ipaddr"

sed -i -e "s|^wsrep_node_address=.*$|wsrep_node_address=${IPADDR}|" ${CFG}
sed -i -e "s|^wsrep_cluster_name=.*$|wsrep_cluster_name=${CLUSTER_NAME}|" ${CFG}
sed -i -e "s|^wsrep_cluster_address=.*$|wsrep_cluster_address=gcomm://${WSREP_CLUSTER_ADDRESS}|" ${CFG}

# don't need a restart, we're just writing the conf in case there's an
# unexpected restart on the node.
